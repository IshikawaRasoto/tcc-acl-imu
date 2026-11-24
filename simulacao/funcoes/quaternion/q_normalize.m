function q = q_normalize(q)
%Q_NORMALIZE Normaliza cada linha. Norma ~0 vira a identidade [1 0 0 0],
%   como qNormalize() do firmware.
for k = 1:size(q, 1)
    n = sqrt(sum(q(k,:).^2));
    if n < 1e-9
        q(k,:) = [1 0 0 0];
    else
        q(k,:) = q(k,:) / n;
    end
end
end
