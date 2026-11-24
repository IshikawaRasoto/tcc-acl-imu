function flex = calcular_flexao(qc, qs, qrel0, eixo)
%CALCULAR_FLEXAO Ângulo de flexão do joelho (graus), como no firmware.
%   qc, qs : orientação dos sensores da coxa e da tíbia (1x4 ou Nx4)
%   qrel0  : orientação relativa na calibração (calibrar_qrel0)
%   eixo   : eixo do joelho no referencial do sensor da tíbia (1x3)
%
%   qRel   = conj(qc) * qs           orientação da tíbia vista pela coxa
%   qDelta = conj(qrel0) * qRel      quanto mudou desde a calibração
%   flex   = twist(qDelta, eixo)     só a parte em torno do eixo do joelho
%   Compatível com blocos MATLAB Function do Simulink.
qrel = q_mul(q_conj(qc), qs);
qdelta = q_mul(q_conj(qrel0), qrel);
flex = q_twist_deg(qdelta, eixo);
end
