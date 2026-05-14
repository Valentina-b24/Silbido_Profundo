cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
silbido_init

%% 1. IMPOSTA LE CARTELLE E TROVA I FILE 
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/No_fischi_rumore/';

contenuto = dir(cartella_audio);
lista_file = [];
for i = 1:length(contenuto)
    nome = contenuto(i).name;
    % Se il nome è lungo almeno 4 caratteri, finisce per .wav e NON è un file nascosto
    if length(nome) > 4 && strcmpi(nome(end-3:end), '.wav') && ~startsWith(nome, '._')
        lista_file = [lista_file; contenuto(i)];
    end
end

fprintf('Trovati %d file audio pronti per l''analisi.\n', length(lista_file));

%% 2. CICLO DI ANALISI E METADATI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA DAL NOME ---
    parti = strsplit(nome_attuale, '.');
    timestamp = parti{2}; % Prende i numeri centrali
    
    anno_corto = timestamp(1:2);
    mese    = timestamp(3:4);
    giorno  = timestamp(5:6);
    ora     = timestamp(7:8);
    minuti  = timestamp(9:10);
    secondi = timestamp(11:12);
    
    % Crea la stringa formattata
    anno_lungo = ['20', anno_corto];
    data_ora_completa = sprintf('%s-%s-%s %s:%s:%s', anno_lungo, mese, giorno, ora, minuti, secondi);
    % --------------------------------------

    fprintf('Analizzando: %s (%d di %d)...\n', nome_attuale, k, length(lista_file));
    
    % Lancia il detector
    detections = dtTonalsTracking(percorso_completo, 2, Inf);
    totale_fischi = detections.size(); 
    
    % CREA LA TABELLA EXCEL
    Tabella_Risultati = table({nome_attuale}, {data_ora_completa}, {anno_lungo}, {mese}, {giorno}, {ora}, {minuti}, {secondi}, totale_fischi, ...
        'VariableNames', {'file_name', 'datetime', 'year', 'month', 'day', 'hour', 'min', 'sec', 'Fischi_Trovati'});
    
    % SALVA NELL'EXCEL 
    % (Ho cambiato il nome in "Analisi_No_Fischi.xlsx" per non mischiarlo coi dati di prima!)
    writetable(Tabella_Risultati, 'Analisi_No_Fischi.xlsx', 'WriteMode', 'append');
end

fprintf('\n✅ MISSIONE COMPIUTA! Il file Analisi_No_Fischi.xlsx è pronto.\n');