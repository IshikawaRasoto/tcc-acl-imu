function q = q_from_eixo_angulo(eixo, ang_deg)
%Q_FROM_EIXO_ANGULO Quaternion de uma rotação de ang_deg graus em torno de eixo.
%   eixo: 1x3 (é normalizado aqui). ang_deg: escalar ou vetor coluna Nx1.
%   Usada para gerar as orientações da coxa e da tíbia na simulação.
e = eixo(:)' / norm(eixo);
h = ang_deg(:) * pi / 360;   % metade do ângulo, em rad
q = [cos(h), sin(h) * e];
end
