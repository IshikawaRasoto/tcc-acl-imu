function q = q_nlerp(a, b, t)
%Q_NLERP Interpolação linear normalizada entre a e b, com t em [0, 1].
%   Usa o caminho curto (inverte b se o produto escalar for negativo).
%   Espelha qNlerp(); usada para alinhar amostras dos dois sensores no tempo.
d = sum(a .* b, 2);
s = ones(size(d));
s(d < 0) = -1;
b = b .* s;
q = q_normalize(a + (b - a) .* t);
end
