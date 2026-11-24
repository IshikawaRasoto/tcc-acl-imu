function fig = nova_figura(nome, posicao)
%NOVA_FIGURA Figura com fundo branco e tema claro, para o texto do TCC.
%   Independe do tema do MATLAB (no tema escuro, as figuras sairiam com
%   eixos escuros). Depois de plotar, chame estilo_tcc(fig).
if nargin < 2, posicao = [100 100 1000 600]; end
fig = figure('Name', nome, 'Color', 'w', 'Position', posicao);
try
    theme(fig, 'light');   % MATLAB R2025a ou mais novo
catch
end
end
