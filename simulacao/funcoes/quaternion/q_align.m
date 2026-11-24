function q = q_align(a, b)
%Q_ALIGN Menor rotação que leva o vetor a até o vetor b (ambos 1x3).
a = a(:)' / norm(a);
b = b(:)' / norm(b);
c = dot(a, b);
if c > 1 - 1e-12
    q = [1 0 0 0];
elseif c < -1 + 1e-12
    % 180°: qualquer eixo perpendicular a a serve
    p = cross(a, [1 0 0]);
    if norm(p) < 1e-6
        p = cross(a, [0 1 0]);
    end
    q = [0, p / norm(p)];
else
    q = q_normalize([1 + c, cross(a, b)]);
end
end
