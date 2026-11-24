function q = q_conj(q)
%Q_CONJ Conjugado (inverso para quaternion unitário). Espelha qConj().
q = [q(:,1), -q(:,2), -q(:,3), -q(:,4)];
end
