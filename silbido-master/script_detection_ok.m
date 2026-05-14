cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
%%
silbido_init

%% 1. IMPOSTA IL FILE DA ANALIZZARE
nome_audio = '5498.250617082504.wav';

%% 2. LANCIA IL DETECTOR
detections = dtTonalsTracking(nome_audio, 0, Inf);
%%   3. GUARDA I RISULTATI SUL GRAFICO (Opzionale)
dtTonalAnnotate('Filename', nome_audio)

%% 4. SALVA IL CONTEGGIO SU EXCEL
% Conta quanti fischi ci sono nella variabile detections
numero_fischi = detections.size();

% Crea una piccola tabella con il nome del file e il numero
Tabella_Risultati = table({nome_audio}, numero_fischi, 'VariableNames', {'Nome_File', 'Fischi_Trovati'});

% Salva su Excel con gli altri dati
writetable(Tabella_Risultati, 'Conteggio_Beluga.xlsx', 'WriteMode', 'append');

fprintf('Finito! Trovati %d fischi. Riga aggiunta al file Excel.\n', numero_fischi);
%% Cambia il nome con quello del file che vuoi controllare
dtTonalAnnotate('Filename', '/Users/valentinabottoni/TESI/Fischi_Beluga/Fischi_Buoni/5498.250617062504.wav');