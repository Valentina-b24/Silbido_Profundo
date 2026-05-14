%% CALCOLO MATRICE DI CONFUSIONE (TP, TN, FP, FN)
clear all; clc;

% 1. LEGGI IL TUO FILE
nome_file = '/Users/valentinabottoni/Desktop/Analisi_fischi_2025_88%.csv';
T = readtable(nome_file);

% 2. ESTRAZIONE DATI
% Trasformiamo i fischi di Silbido in binario: 1 se ha trovato qualcosa (>0), 0 se non ha trovato nulla
silbido_rilevato = T.Fischi_Trovati > 0; 
presenza_umana = T.presence == 1;        

% 3. CALCOLO DEI PARAMETRI
% True Positives (Silbido: Sì, Umano: Sì)
TP = sum(silbido_rilevato & presenza_umana);

% True Negatives (Silbido: No, Umano: No)
TN = sum(~silbido_rilevato & ~presenza_umana);

% False Positives (Silbido: Sì, Umano: No -> Falso Allarme)
FP = sum(silbido_rilevato & ~presenza_umana);

% False Negatives (Silbido: No, Umano: Sì -> Fischio Perso)
FN = sum(~silbido_rilevato & presenza_umana);

% 4. STAMPA DEI RISULTATI
fprintf('📊 --- MATRICE DI ANALISI --- 📊\n');
fprintf('True Positives (TP): %d\n', TP);
fprintf('True Negatives (TN): %d\n', TN);
fprintf('False Positives (FP): %d\n', FP);
fprintf('False Negatives (FN): %d\n', FN);
fprintf('-----------------------------------\n');

% Calcoli extra utili per la Tesi!
Precision = TP / (TP + FP);
Recall = TP / (TP + FN);
Accuracy = (TP + TN) / (TP + TN + FP + FN);

fprintf('🎯 PRECISION: %.2f%%\n', Precision * 100);
fprintf('🔍 RECALL (Sensibilità): %.2f%%\n', Recall * 100);
fprintf('⭐ ACCURACY GLOBALE: %.2f%%\n', Accuracy * 100);