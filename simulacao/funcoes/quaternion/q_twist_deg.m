function ang = q_twist_deg(q, eixo)
%Q_TWIST_DEG Decomposição swing-twist: ângulo (com sinal, em graus) da parte
%   da rotação em torno do eixo unitário eixo = [ax ay az].
%
%   Diferença em relação a qTwistDeg() do firmware: aqui o quaternion é
%   levado antes ao hemisfério w >= 0 (q e -q são a mesma rotação). Sem isso,
%   um q com w < 0 dá, por exemplo, -330° em vez de +30°. Ver testar_quaternion.
p = q(:,2:4) * eixo(:);
w = q(:,1);
s = ones(size(w));
s(w < 0) = -1;
ang = 2 * atan2(p .* s, w .* s) * 180 / pi;
end
