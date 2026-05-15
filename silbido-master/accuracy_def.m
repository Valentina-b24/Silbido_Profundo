%% CALCOLO METRICHE - LETTURA DIRETTA DA EXCEL (VERSIONE FINALE)
clear all; clc;

% 1. CARICAMENTO DEL FILE EXCEL
nome_file = '/Users/valentinabottoni/Desktop/Analisi_fischi_2021_85%(200ms).xlsx';

% Questo comando analizza il file e capisce da solo dove sono i titoli
opts = detectImportOptions(nome_file); 
opts.VariableNamesRange = 'A1'; % Forza MATLAB a cercare i nomi nella prima riga
opts.DataRange = 'A2';          % Forza i dati a partire dalla seconda riga

T = readtable(nome_file, opts);
% --- PULIZIA DATI ---
% 1. Forziamo le colonne a essere numeriche
if iscell(T.presence) || isstring(T.presence)
    T.presence = str2double(string(T.presence));
end
if iscell(T.Fischi_Trovati) || isstring(T.Fischi_Trovati)
    T.Fischi_Trovati = str2double(string(T.Fischi_Trovati));
end

% 2. Rimuoviamo le righe prive di dati (NaN)
righe_valide = ~isnan(T.presence) & ~isnan(T.Fischi_Trovati);
T = T(righe_valide, :);

% 3. Rimozione duplicati (mantiene l'ultima occorrenza per ogni file_name)
[~, indici_unici] = unique(T.file_name, 'last');
T = T(indici_unici, :);

% --- CALCOLO METRICHE ---
rilevamenti_software = T.Fischi_Trovati > 0; 
ground_truth = T.presence > 0; 

% Parametri Matrice di Confusione
TP = sum(rilevamenti_software & ground_truth);  
TN = sum(~rilevamenti_software & ~ground_truth); 
FP = sum(rilevamenti_software & ~ground_truth); 
FN = sum(~rilevamenti_software & ground_truth);  

% Totali Ground Truth
totale_positivi_reali = sum(ground_truth); 
totale_negativi_reali = sum(~ground_truth); 
totale_file_analizzati = height(T); 

% --- VERIFICA DI CONTROLLO ---
fprintf('📊 --- VERIFICA DATASET E RISULTATI --- 📊\n');
fprintf('Totale file unici analizzati        : %d\n', totale_file_analizzati);
fprintf('-------------------------------------------\n');
fprintf('POSITIVI REALI (Ground Truth = 1)   : %d\n', totale_positivi_reali);
fprintf(' -> Veri Positivi individuati (TP)  : %d\n', TP);
fprintf('-------------------------------------------\n');
fprintf('NEGATIVI REALI (Ground Truth = 0)   : %d\n', totale_negativi_reali);
fprintf(' -> Veri Negativi individuati (TN)  : %d\n', TN);
fprintf('-------------------------------------------\n\n');

% 2. CALCOLO METRICHE PRESTAZIONALI
Precision = TP / (TP + FP);
Recall = TP / totale_positivi_reali;    
FPR = FP / totale_negativi_reali;       
Accuracy = (TP + TN) / totale_file_analizzati;

% 3. REPORT FINALE
fprintf('--- REPORT PRESTAZIONI DETECTOR ---\n');
fprintf('True Positives (TP)           : %d\n', TP);
fprintf('True Negatives (TN)           : %d\n', TN);
fprintf('False Positives (FP)          : %d (Falsi Allarmi)\n', FP);
fprintf('False Negatives (FN)          : %d (Omissioni)\n', FN);
fprintf('-----------------------------------\n');
fprintf('RECALL (Sensibilità)          : %.2f%%\n', Recall * 100);
fprintf('PRECISION                     : %.2f%%\n', Precision * 100);
fprintf('FALSE POSITIVE RATE (FPR)     : %.2f%%\n', FPR * 100);
fprintf('ACCURACY GLOBALE              : %.2f%%\n', Accuracy * 100);
fprintf('-----------------------------------\n');