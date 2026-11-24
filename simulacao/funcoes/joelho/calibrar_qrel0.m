function qrel0 = calibrar_qrel0(qc, qs)
%CALIBRAR_QREL0 Orientação relativa de referência (perna estendida e parada).
%   qc, qs: Nx4 com as amostras da coxa e da tíbia durante a calibração.
%   Faz a média simples dos quaternions relativos no mesmo hemisfério,
%   igual ao firmware (04_joelho.cpp, 50 amostras).
qrel = q_mul(q_conj(qc), qs);
soma = [0 0 0 0];
for k = 1:size(qrel, 1)
    if sum(soma .* qrel(k,:)) < 0
        soma = soma - qrel(k,:);
    else
        soma = soma + qrel(k,:);
    end
end
qrel0 = q_normalize(soma);
end
