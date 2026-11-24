function c = gerar_cenario_ideal(op)
%GERAR_CENARIO_IDEAL Perna rígida (coxa + tíbia) com joelho em dobradiça
%   ideal e dois sensores virtuais montados em orientações arbitrárias.
%
%   op (struct, todos os campos opcionais):
%     fs            taxa de amostragem em Hz             (100)
%     duracao       duração em s                         (12)
%     t_calib       tempo inicial com a perna estendida  (1)
%     flex_max      flexão máxima do joelho em graus     (120)
%     periodo       período de um ciclo de flexão em s   (5)
%     mov_coxa      true = coxa se move em 3D            (true)
%     eixo_sensor   eixo do sensor da tíbia paralelo ao joelho, 1x3 ([1 0 0])
%     qm_coxa       montagem do sensor da coxa  (sorteada se vazia)
%     qm_tibia      montagem do sensor da tíbia (sorteada se vazia)
%     inverter_sinal true = sorteia o sinal de cada quaternion (q ou -q),
%                   como um sensor real pode entregar         (true)
%
%   Referenciais: mundo com z para cima. Segmento: x anterior, y lateral
%   (eixo do joelho), z ao longo do segmento. Perna estendida = segmento
%   alinhado ao mundo. Os dois sensores usam o mesmo referencial de mundo
%   (cenário ideal; diferenças de guinada entram na etapa 5).
%
%   Saída c: t, flex_ref, q_coxa, q_tibia (sensores, Nx4), qm_coxa,
%   qm_tibia, eixo_sensor, idx_calib (amostras de calibração).

if nargin < 1, op = struct(); end
op = preencher(op, 'fs', 100);
op = preencher(op, 'duracao', 12);
op = preencher(op, 't_calib', 1);
op = preencher(op, 'flex_max', 120);
op = preencher(op, 'periodo', 5);
op = preencher(op, 'mov_coxa', true);
op = preencher(op, 'eixo_sensor', [1 0 0]);
op = preencher(op, 'qm_coxa', []);
op = preencher(op, 'qm_tibia', []);
op = preencher(op, 'inverter_sinal', true);

t = (0:1/op.fs:op.duracao)';
N = numel(t);
tm = max(t - op.t_calib, 0);              % tempo de movimento

% Flexão de referência: 0 durante a calibração, depois ciclos 0 -> max -> 0
flex_ref = op.flex_max / 2 * (1 - cos(2*pi*tm/op.periodo));

% Movimento da coxa em 3D (quadril), independente do joelho
if op.mov_coxa
    quadril = 30 * sin(2*pi*t/7);         % flexão do quadril
    abducao = 10 * sin(2*pi*t/3.3);
    guinada = 45 * sin(2*pi*t/11);        % giro do corpo
else
    quadril = zeros(N,1); abducao = zeros(N,1); guinada = zeros(N,1);
end
Q_coxa = q_mul(q_mul(q_from_eixo_angulo([0 0 1], guinada), ...
                     q_from_eixo_angulo([0 1 0], quadril)), ...
               q_from_eixo_angulo([1 0 0], abducao));

% Joelho: dobradiça em torno do eixo y da coxa
Q_tibia = q_mul(Q_coxa, q_from_eixo_angulo([0 1 0], flex_ref));

% Montagens: coxa totalmente arbitrária; tíbia arbitrária, mas com
% eixo_sensor paralelo ao eixo do joelho (como pede o firmware)
if isempty(op.qm_coxa)
    op.qm_coxa = q_normalize(randn(1,4));
end
if isempty(op.qm_tibia)
    op.qm_tibia = q_mul(q_from_eixo_angulo([0 1 0], 360*rand), ...
                        q_align(op.eixo_sensor, [0 1 0]));
end

q_coxa = q_mul(Q_coxa, op.qm_coxa);
q_tibia = q_mul(Q_tibia, op.qm_tibia);

if op.inverter_sinal
    q_coxa = q_coxa .* sign(rand(N,1) - 0.5);
    q_tibia = q_tibia .* sign(rand(N,1) - 0.5);
end

c.t = t;
c.fs = op.fs;
c.flex_ref = flex_ref;
c.q_coxa = q_coxa;
c.q_tibia = q_tibia;
c.qm_coxa = op.qm_coxa;
c.qm_tibia = op.qm_tibia;
c.eixo_sensor = op.eixo_sensor(:)' / norm(op.eixo_sensor);
c.idx_calib = find(t < op.t_calib);
c.idx_calib = c.idx_calib(max(1, end-49):end);   % últimas 50 amostras
end

function op = preencher(op, campo, valor)
if ~isfield(op, campo)
    op.(campo) = valor;
end
end
