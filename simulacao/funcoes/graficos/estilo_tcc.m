function estilo_tcc(fig)
%ESTILO_TCC Força cores claras e legíveis em todos os eixos e legendas:
%   fundo branco, texto e eixos pretos, grade cinza.
set(fig, 'Color', 'w');
eixos = findall(fig, 'Type', 'axes');
for k = 1:numel(eixos)
    a = eixos(k);
    set(a, 'Color', 'w', 'XColor', 'k', 'YColor', 'k', ...
        'GridColor', [0.6 0.6 0.6], 'GridAlpha', 0.5, 'FontSize', 11);
    set(get(a, 'Title'), 'Color', 'k');
    set(get(a, 'XLabel'), 'Color', 'k');
    set(get(a, 'YLabel'), 'Color', 'k');
end
legendas = findall(fig, 'Type', 'legend');
for k = 1:numel(legendas)
    set(legendas(k), 'Color', 'w', 'TextColor', 'k', 'EdgeColor', [0.6 0.6 0.6]);
end
end
