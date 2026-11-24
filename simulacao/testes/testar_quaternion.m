%TESTAR_QUATERNION Confere as funções de quaternion contra resultados conhecidos.
%   Rode setup_simulacao antes (ou rode este script direto: ele chama o setup).
%   Termina com "Todos os testes passaram" ou para no primeiro erro.

if ~exist('q_mul', 'file')
    run(fullfile(fileparts(mfilename('fullpath')), '..', 'setup_simulacao.m'));
end

tol = 1e-9;
I = [1 0 0 0];
qx30 = q_from_eixo_angulo([1 0 0], 30);
qx60 = q_from_eixo_angulo([1 0 0], 60);
qx90 = q_from_eixo_angulo([1 0 0], 90);
qy20 = q_from_eixo_angulo([0 1 0], 20);

% 1. Identidade e conjugado
assert(max(abs(q_mul(I, qx30) - qx30)) < tol, 'identidade');
assert(max(abs(q_mul(qx30, q_conj(qx30)) - I)) < tol, 'q * conj(q) = identidade');

% 2. Composição de rotações no mesmo eixo: 30° + 60° = 90°
assert(max(abs(q_mul(qx30, qx60) - qx90)) < tol, 'composição 30+60');

% 3. Produto de Hamilton: i*j = k
assert(max(abs(q_mul([0 1 0 0], [0 0 1 0]) - [0 0 0 1])) < tol, 'i*j = k');

% 4. Normalização (inclui o caso de norma zero, que vira identidade)
assert(max(abs(q_normalize([2 0 0 0]) - I)) < tol, 'normalizar');
assert(max(abs(q_normalize([0 0 0 0]) - I)) < tol, 'norma zero');

% 5. Ângulo total
assert(abs(q_angle_deg(qx90) - 90) < 1e-6, 'ângulo total 90');
assert(abs(q_angle_deg(-qx90) - 90) < 1e-6, 'ângulo total com -q');

% 6. Swing-twist: rotação composta, só a parte em torno de X é medida
qx40 = q_from_eixo_angulo([1 0 0], 40);
assert(abs(q_twist_deg(q_mul(qy20, qx40), [1 0 0]) - 40) < 1e-6, 'twist com swing');
assert(abs(q_twist_deg(qx30, [1 0 0]) - 30) < 1e-6, 'twist simples');
assert(abs(q_twist_deg(q_conj(qx30), [1 0 0]) + 30) < 1e-6, 'twist negativo');

% 7. Mesmo ângulo com -q (o sensor pode entregar qualquer dos dois sinais).
%    A fórmula sem a correção de hemisfério (igual ao firmware atual) erra:
assert(abs(q_twist_deg(-qx30, [1 0 0]) - 30) < 1e-6, 'twist com -q');
ingenuo = 2 * atan2(-qx30(2), -qx30(1)) * 180 / pi;
fprintf('  Fórmula do firmware com -q de 30°: %.1f° (deveria ser 30°)\n', ingenuo);

% 8. Interpolação: no meio de 0° e 90° está 45°, e o caminho curto é usado
assert(abs(q_angle_deg(q_nlerp(I, qx90, 0.5)) - 45) < 1e-6, 'nlerp meio');
assert(abs(q_angle_deg(q_nlerp(I, -qx90, 0.5)) - 45) < 1e-6, 'nlerp caminho curto');

% 9. Versão vetorizada (N amostras de uma vez), usada nas séries temporais
angs = (0:15:120)';
qs = q_from_eixo_angulo([1 0 0], angs);
assert(max(abs(q_twist_deg(qs, [1 0 0]) - angs)) < 1e-6, 'vetorizado');

% 10. Euler: rotação só em Z aparece só no yaw
e = q_to_euler_deg(q_from_eixo_angulo([0 0 1], 45));
assert(max(abs(e - [0 0 45])) < 1e-6, 'euler yaw');

fprintf('Todos os testes passaram.\n');
