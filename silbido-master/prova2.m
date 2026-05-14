cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
silbido_init

%% 1. IMPOSTA LE CARTELLE
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/Fischi_Buoni/';
lista_file = dir(fullfile(cartella_audio, '*.wav'));

fprintf('Inizio analisi batch di %d file...\n', length(lista_file));

%% 2. CICLO DI ANALISI (Senza filtri manuali)
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    fprintf('Analizzando: %s (%d/%d)\n', nome_attuale, k, length(lista_file));
    
    % Esegue la detection basandosi SOLO sul file XML
    detections = dtTonalsTracking(percorso_completo, 0, Inf);
    
    % Conteggio totale dei fischi trovati dal detector
    totale_fischi = detections.size(); 
    
    % SCRIVE NELL'EXCEL
    Tabella_Risultati = table({nome_attuale}, totale_fischi, 'VariableNames', {'Nome_File', 'Fischi_Trovati'});
    writetable(Tabella_Risultati, 'Risultati_Batch_Tesi.xlsx', 'WriteMode', 'append');
    
    % SALVA IL FILE .MAT (Ti serve per l'interfaccia grafica dei colori)
    nome_mat = strrep(nome_attuale, '.wav', '_risultati.mat');
    save(fullfile(cartella_audio, nome_mat), 'detections');
end

fprintf('\n✅ ANALISI COMPLETATA!\n');
fprintf('Trovi tutto nel file: Risultati_Batch_Tesi.xlsx\n');