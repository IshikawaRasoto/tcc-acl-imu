%SETUP_SIMULACAO Prepara o ambiente das simulações do TCC.
%   Rode uma vez ao abrir o MATLAB, com a pasta simulacao/ como pasta atual:
%       >> setup_simulacao
%   Adiciona as funções ao path e mostra se o MATLAB tem o que precisamos.

raiz = fileparts(mfilename('fullpath'));
addpath(genpath(fullfile(raiz, 'funcoes')));
addpath(fullfile(raiz, 'testes'));
addpath(fullfile(raiz, 'modelos'));
addpath(fullfile(raiz, 'etapas'));

fprintf('\n== Simulações TCC: ambiente ==\n');
fprintf('Versão: %s\n', version);

% Simulink: usado para visualizar os sinais (Scope, Data Inspector).
% A matemática fica em funções .m, que rodam iguais no script e no Simulink.
temSimulink = license('test', 'Simulink') && ~isempty(ver('simulink'));
if temSimulink
    fprintf('Simulink: disponível\n');
else
    fprintf('Simulink: NÃO encontrado (as simulações em script funcionam mesmo assim)\n');
end

% Toolboxes que ajudam, mas que NÃO são obrigatórias.
opcionais = {'nav', 'Navigation Toolbox';
             'fusion', 'Sensor Fusion and Tracking Toolbox';
             'aero', 'Aerospace Toolbox';
             'simscape', 'Simscape';
             'sm', 'Simscape Multibody';
             'signal', 'Signal Processing Toolbox'};
for k = 1:size(opcionais, 1)
    if ~isempty(ver(opcionais{k,1}))
        estado = 'sim';
    else
        estado = 'não';
    end
    fprintf('  %-36s %s\n', opcionais{k,2}, estado);
end
fprintf('Rode "testar_quaternion" para conferir as funções.\n\n');
clear raiz temSimulink opcionais k estado
