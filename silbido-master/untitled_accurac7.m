%% CALCOLO DELLA MATRICE DI CONFUSIONE E DELLE METRICHE DI VALUTAZIONE
clear all; clc;

% 1. Caricamento del dataset
nome_file = '/Users/valentinabottoni/Desktop/Analisi_fischi_2014_86%.csv';
T = readtable(nome_file);

% 2. Binarizzazione dei dati
% Conversione dei conteggi del software in classificazione binaria (presenza/assenza)
rilevamenti_software = T.Fischi_Trovati > 0; 
% Lettura delle annotazioni manuali (Ground Truth)
ground_truth = T.presence == 1;        

% 3. Calcolo degli elementi della Matrice di Confusione
TP = sum(rilevamenti_software & ground_truth);   % True Positives (Corretti rilevamenti)
TN = sum(~rilevamenti_software & ~ground_truth); % True Negatives (Corrette reiezioni)
FP = sum(rilevamenti_software & ~ground_truth);  % False Positives (Falsi allarmi)
FN = sum(~rilevamenti_software & ground_truth);  % False Negatives (Rilevamenti mancati)

% 4. Calcolo dei totali di riferimento per le frequenze relative
totale_positivi_reali = TP + FN; 
totale_negativi_reali = TN + FP; 
totale_file_analizzati = TP + TN + FP + FN; 

% 5. Calcolo delle metriche di performance
Precision = TP / (TP + FP);
Recall = TP / totale_positivi_reali;    % Noto anche come True Positive Rate (TPR) o Sensibilità
FPR = FP / totale_negativi_reali;       % False Positive Rate (Tasso di falsi allarmi)
Accuracy = (TP + TN) / totale_file_analizzati;

% 6. Stampa dei risultati a terminale
fprintf('--- RISULTATI DELLA VALUTAZIONE DEL DETECTOR ---\n\n');

fprintf('Campione analizzato:\n');
fprintf('- Totale file analizzati             : %d\n', totale_file_analizzati);
fprintf('- Positivi reali (Ground Truth = 1)  : %d\n', totale_positivi_reali);
fprintf('- Negativi reali (Ground Truth = 0)  : %d\n\n', totale_negativi_reali);

fprintf('Matrice di Confusione:\n');
fprintf('- True Positives (TP) : %d\t(Rilevato il %.2f%% dei positivi reali)\n', TP, (TP / totale_positivi_reali) * 100);
fprintf('- False Negatives (FN): %d\t(Mancato il %.2f%% dei positivi reali)\n', FN, (FN / totale_positivi_reali) * 100);
fprintf('- True Negatives (TN) : %d\t(Confermato il %.2f%% dei negativi reali)\n', TN, (TN / totale_negativi_reali) * 100);
fprintf('- False Positives (FP): %d\t(Falsi allarmi sul %.2f%% dei negativi reali)\n\n', FP, FPR * 100);

fprintf('Metriche di Performance:\n');
fprintf('- Precision                     : %.2f%%\n', Precision * 100);
fprintf('- Recall (True Positive Rate)   : %.2f%%\n', Recall * 100);
fprintf('- False Positive Rate (FPR)     : %.2f%%\n', FPR * 100);
fprintf('- Accuracy Globale              : %.2f%%\n', Accuracy * 100);
fprintf('------------------------------------------------\n');