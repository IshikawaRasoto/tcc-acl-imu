%ETAPA1_MODELO_IDEAL Confere o algoritmo do ângulo do joelho num cenário ideal.
%   Perna rígida, joelho em dobradiça perfeita, sensores sem ruído, sem
%   atraso e sem perda. O algoritmo é o mesmo do firmware (calibração com a
%   perna estendida + swing-twist). O erro esperado é zero (só arredondamento).
%
%   Parte A: um ensaio de 12 s com a coxa se movendo em 3D, em gráfico.
%   Parte B: 300 montagens sorteadas dos sensores para cada eixo X, Y e Z.

if ~exist('calcular_flexao', 'file')
    run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup_simulacao.m'));
end
pasta_res = fullfile(fileparts(which('setup_simulacao')), 'resultados');
rng(1);   % resultados reprodutíveis

%% Parte A: um ensaio
c = gerar_cenario_ideal();
qrel0 = calibrar_qrel0(c.q_coxa(c.idx_calib,:), c.q_tibia(c.idx_calib,:));
flex = calcular_flexao(c.q_coxa, c.q_tibia, qrel0, c.eixo_sensor);
erro = flex - c.flex_ref;

% Mesma conta com a fórmula atual do firmware (sem correção de sinal)
qd = q_mul(q_conj(qrel0), q_mul(q_conj(c.q_coxa), c.q_tibia));
flex_fw = 2 * atan2(qd(:,2:4) * c.eixo_sensor', qd(:,1)) * 180 / pi;
n_errados = sum(abs(flex_fw - c.flex_ref) > 1);

fprintf('\n== Etapa 1: modelo ideal ==\n');
fprintf('Parte A (12 s, %d Hz, coxa em movimento 3D):\n', c.fs);
fprintf('  RMSE = %.2e graus, erro máximo = %.2e graus\n', ...
        sqrt(mean(erro.^2)), max(abs(erro)));
fprintf('  Fórmula atual do firmware: %d de %d amostras com erro > 1 grau\n', ...
        n_errados, numel(c.t));

fig = nova_figura('Etapa 1: modelo ideal', [100 100 1000 750]);
subplot(3,1,1);
plot(c.t, c.flex_ref, 'k', 'LineWidth', 2); hold on;
plot(c.t, flex, 'r--', 'LineWidth', 1.2);
ylabel('Flexão (°)'); grid on;
legend('Referência', 'Calculado', 'Location', 'northeast');
title('Ângulo do joelho: referência x algoritmo');
subplot(3,1,2);
plot(c.t, erro, 'b'); ylabel('Erro (°)'); grid on;
title('Erro do algoritmo (só arredondamento numérico)');
subplot(3,1,3);
plot(c.t, flex_fw, '.', 'Color', [0.85 0.33 0.1], 'MarkerSize', 4); hold on;
plot(c.t, c.flex_ref, 'k', 'LineWidth', 1);
ylabel('Flexão (°)'); xlabel('Tempo (s)'); grid on;
title('Fórmula atual do firmware (sem correção do sinal do quaternion)');
estilo_tcc(fig);
saveas(fig, fullfile(pasta_res, 'etapa1_ensaio.png'));

%% Parte B: montagens sorteadas
n = 300;
eixos = eye(3);
nomes = 'XYZ';
fprintf('Parte B (%d montagens sorteadas por eixo):\n', n);
for e = 1:3
    pior = 0;
    for k = 1:n
        op = struct('eixo_sensor', eixos(e,:));
        ck = gerar_cenario_ideal(op);
        q0 = calibrar_qrel0(ck.q_coxa(ck.idx_calib,:), ck.q_tibia(ck.idx_calib,:));
        fk = calcular_flexao(ck.q_coxa, ck.q_tibia, q0, ck.eixo_sensor);
        pior = max(pior, max(abs(fk - ck.flex_ref)));
    end
    fprintf('  Eixo %c: erro máximo = %.2e graus\n', nomes(e), pior);
end
fprintf('Figura salva em resultados/etapa1_ensaio.png\n\n');
