% =========================================================================
% SCRIPT DI ANALISI BELUGA - VERSIONE CORRETTA (Senza errori di indexing)
% =========================================================================

%% 1. CONFIGURAZIONE DIRECTORY
path_master = 'C:\Users\Bioacustica\Desktop\silbido_valentina\silbido-master'; 
path_audio  = 'C:\Users\Bioacustica\Desktop\silbido_valentina\fischi\';       

%% 2. INIZIALIZZAZIONE SISTEMA E FIX JAVA
cd(path_master);
addpath(genpath(pwd)); 
silbido_init;

% Ricarichiamo Java (il nostro numero 8!)
javaaddpath(path_master);
import tonals.*;

%% 3. RICERCA FILE AUDIO
contenuto = dir(path_audio);
lista_file = [];
for i = 1:length(contenuto)
    nome = contenuto(i).name;
    if length(nome) > 4 && strcmpi(nome(end-3:end), '.wav') && ~startsWith(nome, '._')
        lista_file = [lista_file; contenuto(i)];
    end
end
fprintf('Trovati %d file audio pronti.\n', length(lista_file));

%% 4. CICLO DI ANALISI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(path_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA ---
    if startsWith(nome_attuale, 'NYA')
        parti = strsplit(nome_attuale, '_');
        if length(parti) >= 3
            data_str = parti{2}; ora_str = parti{3};
            anno_lungo = data_str(1:4); mese = data_str(5:6); giorno = data_str(7:8);
            ora = ora_str(1:2); minuti = ora_str(3:4); secondi = ora_str(5:6);
        else; continue; end
    elseif startsWith(nome_attuale, 'REC-B')
        numeri = regexp(nome_attuale, '\d+', 'match');
        stringa_numeri = strjoin(numeri, '');
        if length(stringa_numeri) >= 14
            anno_lungo = stringa_numbers(1:4); mese = stringa_numeri(5:6); giorno = stringa_numeri(7:8);
            ora = stringa_numeri(9:10); minuti = stringa_numeri(11:12); secondi = stringa_numeri(13:14);
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
        
        % DETECTION
        detections = dtTonalsTracking(percorso_completo, 0, fine_sicura);
        
        % SALVATAGGIO .MAT
        nome_mat = [nome_attuale(1:end-4), '_risultati.mat'];
        save(fullfile(path_audio, nome_mat), 'detections');
        
        % --- CONTEGGIO FISCHI (Versione corretta per MATLAB) ---
        totale_fischi = 0;
        if ~isempty(detections)
            for i = 0:(detections.size() - 1)
                fischio = detections.get(i);
                tempi = fischio.get_time(); % Questo restituisce un array Java
                
                % FIX: In MATLAB gli array Java si leggono con (1) per il primo elemento
                if tempi(1) > 2.0 
                    totale_fischi = totale_fischi + 1;
                end
            end
        end
        
        % SCRITTURA EXCEL
        Tabella_Risultati = table({nome_attuale}, {data_ora_completa}, {anno_lungo}, {mese}, {giorno}, {ora}, {minuti}, {secondi}, totale_fischi, ...
            'VariableNames', {'file_name', 'datetime', 'year', 'month', 'day', 'hour', 'min', 'sec', 'Fischi_Trovati'});
        
        writetable(Tabella_Risultati, 'Analisi_Risultati_Beluga.xlsx', 'WriteMode', 'append');
        fprintf('✅ Completato: %d fischi trovati (escludendo i primi 2s).\n', totale_fischi);
        
    catch ME 
        fprintf('⚠️ Errore sul file %s.\n ❌ MOTIVO: %s\n', nome_attuale, ME.message);
    end
end

fprintf('\n🎯 ANALISI COMPLETATA CON SUCCESSO!\n');