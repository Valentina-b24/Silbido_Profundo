%% 0. INIZIALIZZAZIONE AMBIENTE
clear all; clc;
cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master

% --- CARICAMENTO MOTORE JAVA (Fondamentale per M2) ---
addpath(genpath(pwd)); 
java_root = fullfile(pwd, 'java');
javaaddpath(fullfile(java_root, 'bin')); 
lib_dir = fullfile(java_root, 'lib');
if exist(lib_dir, 'dir')
    jar_files = dir(fullfile(lib_dir, '*.jar'));
    for i = 1:length(jar_files)
        javaaddpath(fullfile(lib_dir, jar_files(i).name));
    end
end
silbido_init; 
fprintf('✅ Motore pronto.\n');

%% 1. SELEZIONE MANUALE DELLA CARTELLA AUDIO
% Si apre la finestra del Mac per scegliere la cartella
fprintf('📂 Seleziona la cartella contenente i file .wav...\n');
cartella_audio = uigetdir('/Users/valentinabottoni/TESI/', 'Seleziona cartella con i file .wav');

% Controllo se hai premuto "Annulla"
if cartella_audio == 0
    error('❌ Operazione annullata: nessuna cartella selezionata.');
end

% Cerchiamo i file .wav nella cartella scelta
contenuto = dir(fullfile(cartella_audio, '*.wav'));
lista_file = contenuto(~[contenuto.isdir]); 

fprintf('📊 Trovati %d file audio in: %s\n', length(lista_file), cartella_audio);

%% 2. CICLO DI ANALISI E METADATI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA (Tua logica NYA/Timestamp) ---
    try
        if startsWith(nome_attuale, 'NYA')
            parti = strsplit(nome_attuale, '_');
            if length(parti) >= 3
                data_str = parti{2}; ora_str = parti{3};
                anno_lungo = data_str(1:4); mese = data_str(5:6); giorno = data_str(7:8);
                ora = ora_str(1:2); minuti = ora_str(3:4); secondi = ora_str(5:6);
            else, continue; end
        else
            parti = strsplit(nome_attuale, '.');
            if length(parti) >= 2
                timestamp = parti{2}; 
                if length(timestamp) >= 12
                    anno_lungo = ['20', timestamp(1:2)]; mese = timestamp(3:4); giorno = timestamp(5:6);
                    ora = timestamp(7:8); minuti = timestamp(9:10); secondi = timestamp(11:12);
                else, continue; end
            else, continue; end
        end
        data_ora_completa = sprintf('%s-%s-%s %s:%s:%s', anno_lungo, mese, giorno, ora, minuti, secondi);
    catch
        data_ora_completa = 'N/A';
    end

    fprintf('🔎 Analizzando: %s (%d/%d)...\n', nome_attuale, k, length(lista_file));
    
    try
        % 1. Analisi Silbido
        info_audio = audioinfo(percorso_completo);
        fine_sicura = info_audio.Duration - 0.1;
        detections = dtTonalsTracking(percorso_completo, 0, fine_sicura);
        
        % 2. SALVATAGGIO FILE .MAT (nella stessa cartella scelta)
        nome_mat = [nome_attuale(1:end-4), '_risultati.mat'];
        save(fullfile(cartella_audio, nome_mat), 'detections');
        
        % 3. CONTEGGIO FISCHI (Fix M2)
        totale_fischi = 0;
        for i = 0:(detections.size() - 1)
            f = detections.get(i);
            t = double(f.get_time()); 
            if ~isempty(t) && min(t) > 2.0
                totale_fischi = totale_fischi + 1;
            end
        end
        
        % 4. SCRITTURA EXCEL (Append)
        Tabella = table({nome_attuale}, {data_ora_completa}, totale_fischi, ...
            'VariableNames', {'file_name', 'datetime', 'Fischi_Trovati'});
        
        % L'Excel verrà creato dentro la cartella che hai selezionato
        nome_excel = fullfile(cartella_audio, 'Risultati_Analisi_Beluga.xlsx');
        writetable(Tabella, nome_excel, 'WriteMode', 'append');
        
    catch ME 
        fprintf('⚠️ Errore su %s: %s\n', nome_attuale, ME.message);
    end
end
fprintf('\n🎉 ANALISI COMPLETATA! Trovi tutto in: %s\n', cartella_audio);