cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
silbido_init

%% 1. IMPOSTA LE CARTELLE E TROVA I FILE
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/No_fischi_rumore/';
nome_excel = 'Analisi_No_fischi_rumore88.xlsx';

contenuto = dir(cartella_audio);
lista_file = [];
for i = 1:length(contenuto)
    nome = contenuto(i).name;
    if length(nome) > 4 && strcmpi(nome(end-3:end), '.wav') && ~startsWith(nome, '._')
        lista_file = [lista_file; contenuto(i)];
    end
end

fprintf('Perfetto! Trovati %d file audio pronti per l''analisi.\n', length(lista_file));

% Contatori per le statistiche finali
contatore_zero = 0;
contatore_fischi = 0;

%% 2. CICLO DI ANALISI E METADATI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA (BILINGUE) ---
    if startsWith(nome_attuale, 'NYA')
        parti = strsplit(nome_attuale, '_');
        if length(parti) >= 3
            data_str = parti{2}; ora_str = parti{3};
            anno_lungo = data_str(1:4); mese = data_str(5:6); giorno = data_str(7:8);
            ora = ora_str(1:2); minuti = ora_str(3:4); secondi = ora_str(5:6);
        else; continue; end
    else
        parti = strsplit(nome_attuale, '.');
        if length(parti) >= 2
            timestamp = parti{2}; 
            if length(timestamp) >= 12
                anno_lungo = ['20', timestamp(1:2)]; mese = timestamp(3:4); giorno = timestamp(5:6);
                ora = timestamp(7:8); minuti = timestamp(9:10); secondi = timestamp(11:12);
            else; continue; end
        else; continue; end
    end
    data_ora_completa = sprintf('%s-%s-%s %s:%s:%s', anno_lungo, mese, giorno, ora, minuti, secondi);

    % --- ANALISI ---
    fprintf('Analizzando: %s (%d di %d)...\n', nome_attuale, k, length(lista_file));
    try
        info_audio = audioinfo(percorso_completo);
        fine_sicura = info_audio.Duration - 0.1;
        
        detections = dtTonalsTracking(percorso_completo, 0, fine_sicura);
        
        nome_mat = [nome_attuale(1:end-4), '_risultati.mat'];
        save(fullfile(cartella_audio, nome_mat), 'detections');
        
        totale_fischi = 0;
        for i = 0:(detections.size() - 1)
            fischio = detections.get(i);
            tempi = fischio.get_time(); 
            if min(tempi) > 2.0; totale_fischi = totale_fischi + 1; end
        end
        
        % Aggiorna i contatori per le statistiche
        if totale_fischi == 0
            contatore_zero = contatore_zero + 1;
        else
            contatore_fischi = contatore_fischi + 1;
        end
        
        % SCRIVE EXCEL - Foglio 1: Dati Dettagliati (Aggiunge sempre righe nuove)
        Tabella_Risultati = table({nome_attuale}, {data_ora_completa}, {anno_lungo}, {mese}, {giorno}, {ora}, {minuti}, {secondi}, totale_fischi, ...
            'VariableNames', {'file_name', 'datetime', 'year', 'month', 'day', 'hour', 'min', 'sec', 'Fischi_Trovati'});
        
        writetable(Tabella_Risultati, nome_excel, 'Sheet', 'Dati_Dettagliati', 'WriteMode', 'append');
        
    catch
        fprintf('⚠️ ATTENZIONE: Silbido non riesce a leggere il file %s. Salto al prossimo!\n', nome_attuale);
    end
end

%% 3. CALCOLO STATISTICHE E SECONDO FOGLIO EXCEL
if (contatore_zero + contatore_fischi) > 0
    file_totali = contatore_zero + contatore_fischi; 
    perc_zero = (contatore_zero / file_totali) * 100;
    perc_fischi = (contatore_fischi / file_totali) * 100;
    
    Tabella_Statistiche = table(file_totali, contatore_zero, contatore_fischi, perc_zero, perc_fischi, ...
        'VariableNames', {'File_Analizzati', 'File_ZERO_Fischi', 'File_CON_Fischi', 'Percentuale_ZERO', 'Percentuale_CON_Fischi'});
    
    % Scrive le statistiche nel Foglio 2 (Sovrascrive solo la tabellina riassuntiva per mantenerla aggiornata all'ultimo giro)
    writetable(Tabella_Statistiche, nome_excel, 'Sheet', 'Riassunto_Statistiche', 'WriteMode', 'overwritesheet');
end

fprintf('\n✅ MISSIONE COMPIUTA! Il file Excel è pronto con entrambi i fogli.\n');