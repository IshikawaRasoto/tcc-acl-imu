function v = q_rotate(q, v)
%Q_ROTATE Gira o vetor v (1x3 ou Nx3) pelo quaternion q: v' = q * [0 v] * conj(q).
p = q_mul(q_mul(q, [zeros(size(v,1),1), v]), q_conj(q));
v = p(:,2:4);
end
