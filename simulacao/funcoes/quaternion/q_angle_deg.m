function ang = q_angle_deg(q)
%Q_ANGLE_DEG Ângulo total de rotação, em graus (0 a 180). Espelha qAngleDeg().
w = min(abs(q(:,1)), 1);
ang = 2 * acos(w) * 180 / pi;
end
