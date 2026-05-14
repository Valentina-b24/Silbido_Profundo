%% 0. INIZIALIZZAZIONE E AGGANCIO MOTORE
clear all; clc;

% 1. Ci assicuriamo di essere nella cartella corretta
cd '/Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master'
addpath(genpath(pwd));

% 2. --- INIEZIONE AUTOMATICA DEL MOTORE JAVA ---
javaaddpath(fullfile(pwd, 'java', 'src')); % La tana del LinearBank
cartella_lib = fullfile(pwd, 'java', 'lib');
lista_jar = dir(fullfile(cartella_lib, '*.jar'));
for i = 1:length(lista_jar)
    javaaddpath(fullfile(cartella_lib, lista_jar(i).name));
end
silbido_init;
% -----------------------------------------------
