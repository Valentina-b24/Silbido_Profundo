%% CALCOLO METRICHE - LETTURA DIRETTA DA EXCEL (CORRETTA)
clear all; clc;

% 1. CARICAMENTO DEL FILE EXCEL
nome_file = '/Users/valentinabottoni/Desktop/Analisi_fischi_2025_85%.xlsx';
T = readtable(nome_file);

% --- PULIZIA DATI ---
% 1. Forziamo le colonne a essere numeriche (se Excel le avesse lette come testo)
if iscell(T.presence) || isstring(T.presence)
    T.presence = str2double(string(T.presence));
end
if iscell(T.Fischi_Trovati) || isstring(T.Fischi_Trovati)
    T.Fischi_Trovati = str2double(string(T.Fischi_Trovati));
end

% 2. Rimuoviamo le righe dove non c'è scritto nulla (i NaN fantasma di Excel)
righe_valide = ~isnan(T.presence) & ~isnan(T.Fischi_Trovati);
T = T(righe_valide, :);

% 3. Rimuoviamo i duplicati causati dal vecchio effetto "append"
[~, indici_unici] = unique(T.file_name, 'last');
T = T(indici_unici, :);

% --- CALCOLO METRICHE ---
rilevamenti_software = T.Fischi_Trovati > 0; 
ground_truth = T.presence > 0; 

TP = sum(rilevamenti_software & ground_truth);  % True Positives (Corretti rilevamenti)
TN = sum(~rilevamenti_software & ~ground_truth);% True Negatives (Corrette reiezioni)
FP = sum(rilevamenti_software & ~ground_truth); % False Positives (Falsi allarmi)
FN = sum(~rilevamenti_software & ground_truth); % False Negatives (Rilevamenti mancati) 

totale_positivi_reali = sum(ground_truth); 
totale_negativi_reali = sum(~ground_truth); 
totale_file_analizzati = height(T); 

% --- VERIFICA DI CONTROLLO ---
fprintf('📊 --- VERIFICA EXCEL DIRETTA --- 📊\n');
fprintf('File analizzati in totale: %d\n', totale_file_analizzati);
fprintf('File che segnati come positivi (1): %d\n', totale_positivi_reali);
fprintf('-------------------------------------------\n\n');

% 2. CALCOLO PERCENTUALI
Precision = TP / (TP + FP);
Recall = TP / totale_positivi_reali; % Noto anche come True Positive Rate (TPR) o Sensibilità
FPR = FP / totale_negativi_reali;    % False Positive Rate (Tasso di falsi allarmi)   
Accuracy = (TP + TN) / totale_file_analizzati;

% 3. STAMPA FINALE
fprintf('--- RISULTATI VALUTAZIONE DETECTOR ---\n');
fprintf('True Positives (TP) : %d\n', TP);
fprintf('True Negatives (TN) : %d\n', TN);
fprintf('False Positives (FP): %d (FPR: %.2f%%)\n', FP, FPR*100);
fprintf('False Negatives (FN): %d\n', FN);
fprintf('--------------------------------------\n');
fprintf('RECALL (Sensibilità) : %.2f%%\n', Recall * 100);
fprintf('PRECISION            : %.2f%%\n', Precision * 100);
fprintf('ACCURACY GLOBALE     : %.2f%%\n', Accuracy * 100);