cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
silbido_init

%% 1. IMPOSTA LE CARTELLE
cartella_audio ='Users/valentinabottoni/TESI/Fischi_Beluga/No_fischi_no_rumore/';
lista_file = dir(fullfile(cartella_audio, '*.wav'));

fprintf('Inizio analisi batch di %d file con estrazione metadati...\n', length(lista_file));

%% 2. CICLO DI ANALISI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA DAL NOME (Esempio: 5498.250607092504.wav) ---
    parti = strsplit(nome_attuale, '.');
    timestamp = parti{2}; % Prende '250607092504'
    
    anno_corto = timestamp(1:2);
    mese    = timestamp(3:4);
    giorno  = timestamp(5:6);
    ora     = timestamp(7:8);
    minuti  = timestamp(9:10);
    secondi = timestamp(11:12);
    
    % Creiamo le stringhe per l'Excel come nella tua foto
    anno_lungo = ['20', anno_corto];
    data_ora_completa = sprintf('%s-%s-%s %s:%s:%s', anno_lungo, mese, giorno, ora, minuti, secondi);
    % -----------------------------------------------------------------------

    fprintf('Analizzando: %s...\n', nome_attuale);
    
    % Detection (senza filtri extra, comanda l'XML)
    detections = dtTonalsTracking(percorso_completo, 0, Inf);
    totale_fischi = detections.size(); 
    
    % CREA LA TABELLA CON TUTTE LE COLONNE CHE HAI CHIESTO
    Tabella_Risultati = table({nome_attuale}, {data_ora_completa}, {anno_lungo}, {mese}, {giorno}, {ora}, {minuti}, {secondi}, totale_fischi, ...
        'VariableNames', {'file_name', 'datetime', 'year', 'month', 'day', 'hour', 'min', 'sec', 'Fischi_Trovati'});
    
    % SALVA NELL'EXCEL
    writetable(Tabella_Risultati, 'Analisi_Finale_Tesi.xlsx', 'WriteMode', 'append');
end

fprintf('\n✅ MISSIONE COMPIUTA! Il file Analisi_Finale_Tesi.xlsx è pronto.\n');