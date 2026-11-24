%CRIAR_MODELO_ETAPA1 Gera, salva e roda o modelo Simulink da etapa 1.
%   Cria modelos/etapa1_joelho.slx a partir do cenário ideal:
%     From Workspace (quaternions da coxa e da tíbia, flexão de referência)
%       -> MATLAB Function que chama calcular_flexao (mesmo código do script)
%       -> Scopes com referência x calculado e com o erro.
%   O modelo é refeito toda vez que este script roda, então edite o script,
%   não o .slx. Os sinais também vão para o Simulation Data Inspector.

if ~exist('calcular_flexao', 'file')
    run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup_simulacao.m'));
end

%% Dados do cenário (variáveis sim_* no workspace base, lidas pelo modelo)
rng(1);
c = gerar_cenario_ideal();
sim_Ts = 1 / c.fs;
sim_T = c.t(end);
sim_q_coxa = [c.t, c.q_coxa];
sim_q_tibia = [c.t, c.q_tibia];
sim_flex_ref = [c.t, c.flex_ref];
sim_qrel0 = calibrar_qrel0(c.q_coxa(c.idx_calib,:), c.q_tibia(c.idx_calib,:));
sim_eixo = c.eixo_sensor;

%% Modelo
nome = 'etapa1_joelho';
pasta = fileparts(mfilename('fullpath'));
if bdIsLoaded(nome), close_system(nome, 0); end
arq = fullfile(pasta, [nome '.slx']);
if exist(arq, 'file'), delete(arq); end   % evita o aviso de nome duplicado
new_system(nome);
set_param(nome, 'Solver', 'FixedStepDiscrete', 'FixedStep', 'sim_Ts', ...
          'StopTime', 'sim_T');

b = @(n) [nome '/' n];
fw = {'SampleTime', 'sim_Ts', 'Interpolate', 'off', ...
      'OutputAfterFinalValue', 'Holding final value'};
add_block('simulink/Sources/From Workspace', b('q_coxa'), ...
          'VariableName', 'sim_q_coxa', fw{:}, 'Position', [40 40 140 70]);
add_block('simulink/Sources/From Workspace', b('q_tibia'), ...
          'VariableName', 'sim_q_tibia', fw{:}, 'Position', [40 100 140 130]);
add_block('simulink/Sources/Constant', b('qrel0'), ...
          'Value', 'sim_qrel0', 'Position', [40 160 140 190]);
add_block('simulink/Sources/Constant', b('eixo'), ...
          'Value', 'sim_eixo', 'Position', [40 220 140 250]);
add_block('simulink/Sources/From Workspace', b('flex_ref'), ...
          'VariableName', 'sim_flex_ref', fw{:}, 'Position', [40 300 140 330]);

fn = b('Angulo do joelho');
add_block('simulink/User-Defined Functions/MATLAB Function', fn, ...
          'Position', [230 60 380 240]);
cfg = get_param(fn, 'MATLABFunctionConfiguration');
cfg.FunctionScript = sprintf([ ...
    'function flex = angulo_joelho(q_coxa, q_tibia, qrel0, eixo)\n' ...
    '%% Mesmo cálculo do firmware: calibração + swing-twist\n' ...
    'flex = calcular_flexao(reshape(q_coxa, 1, 4), reshape(q_tibia, 1, 4), ...\n' ...
    '                       reshape(qrel0, 1, 4), reshape(eixo, 1, 3));\n']);

add_block('simulink/Signal Routing/Mux', b('Mux'), 'Inputs', '2', ...
          'Position', [470 120 475 200]);
add_block('simulink/Math Operations/Sum', b('Erro'), 'Inputs', '+-', ...
          'Position', [470 260 500 290]);
add_block('simulink/Sinks/Scope', b('Angulo'), 'Position', [560 145 600 175]);
add_block('simulink/Sinks/Scope', b('Scope erro'), 'Position', [560 260 600 290]);

ln = @(de, para) add_line(nome, de, para, 'autorouting', 'on');
ln('q_coxa/1', 'Angulo do joelho/1');
ln('q_tibia/1', 'Angulo do joelho/2');
ln('qrel0/1', 'Angulo do joelho/3');
ln('eixo/1', 'Angulo do joelho/4');
h_ref = ln('flex_ref/1', 'Mux/1');
h_calc = ln('Angulo do joelho/1', 'Mux/2');
ln('Angulo do joelho/1', 'Erro/1');
ln('flex_ref/1', 'Erro/2');
ln('Mux/1', 'Angulo/1');
h_erro = ln('Erro/1', 'Scope erro/1');

% Nomes dos sinais (legenda dos Scopes) e registro no Data Inspector
set_param(h_ref, 'Name', 'Referencia');
set_param(h_calc, 'Name', 'Calculado');
set_param(h_erro, 'Name', 'Erro');
for h = [h_ref, h_calc, h_erro]
    set_param(get_param(h, 'SrcPortHandle'), 'DataLogging', 'on');
end

sc = get_param(b('Angulo'), 'ScopeConfiguration');
sc.ShowLegend = true;
sc.Title = 'Flexao do joelho (graus)';
sc.YLimits = [-10 130];
sc = get_param(b('Scope erro'), 'ScopeConfiguration');
sc.Title = 'Erro (graus)';

save_system(nome, arq);

%% Simulação
out = sim(nome);
open_system(b('Angulo'));
open_system(b('Scope erro'));
%% Figura dos sinais registrados (mesmo conteúdo dos Scopes), salva em resultados/
try
    ref = out.logsout.get('Referencia').Values;
    calc = out.logsout.get('Calculado').Values;
    err = out.logsout.get('Erro').Values;
    e = squeeze(err.Data);
    fprintf('Simulink: RMSE = %.2e graus, erro máximo = %.2e graus\n', ...
            sqrt(mean(e.^2)), max(abs(e)));

    fig = nova_figura('Etapa 1: Simulink', [100 100 1100 420]);
    subplot(1,2,1);
    plot(ref.Time, squeeze(ref.Data), 'k', 'LineWidth', 2); hold on;
    plot(calc.Time, squeeze(calc.Data), 'r--', 'LineWidth', 1.2);
    grid on; ylim([-10 130]);
    xlabel('Tempo (s)'); ylabel('Flexão (°)');
    title('Flexão do joelho (Simulink)');
    legend('Referência', 'Calculado', 'Location', 'northeast');
    subplot(1,2,2);
    plot(err.Time, e, 'Color', [0 0.35 0.75]);
    grid on; xlabel('Tempo (s)'); ylabel('Erro (°)');
    title('Erro (Simulink)');
    estilo_tcc(fig);
    arq_fig = fullfile(pasta, '..', 'resultados', 'etapa1_simulink.png');
    exportgraphics(fig, arq_fig, 'Resolution', 200);
    fprintf('Figura salva em resultados/etapa1_simulink.png\n');
catch me
    fprintf('Não consegui gerar a figura: %s\n', me.message);
    fprintf('Os sinais continuam nos Scopes e no Data Inspector.\n');
end
