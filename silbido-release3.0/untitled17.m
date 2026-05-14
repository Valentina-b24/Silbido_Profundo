%% 0. INIZIALIZZAZIONE (NELLA TUA CARTELLA MASTER)
clear all; clear java; clc; 
cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master

% --- AGGANCIO MOTORE AUTOMATICO (Così non dobbiamo scrivere i nomi dei file!) ---
addpath(genpath(pwd)); 

% 1. Carichiamo la cartella bin
javaaddpath(fullfile(pwd, 'java', 'bin')); 

% 2. Carichiamo TUTTI i file .jar presenti nella lib senza doverne scrivere i nomi
folder_lib = fullfile(pwd, 'java', 'lib');
if exist(folder_lib, 'dir')
    elenco_jar = dir(fullfile(folder_lib, '*.jar'));
    for i = 1:length(elenco_jar)
        javaaddpath(fullfile(folder_lib, elenco_jar(i).name));
    end
else
    error('❌ Non trovo la cartella java/lib! Controlla di averla incollata dentro silbido-master.');
end

silbido_init; 
fprintf('✅ MOTORE PRONTO! Ora Silbido sa cosa fare.\n');

%% 1. IMPOSTA LE CARTELLE E TROVA I FILE
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/Fischi_Buoni/'; 

if ~exist(cartella_audio, 'dir')
    cartella_audio = pwd; 
end

contenuto = dir(fullfile(cartella_audio, '*.wav'));
lista_file = contenuto(~[contenuto.isdir]); 

fprintf('Trovati %d file audio pronti.\n', length(lista_file));

%% 2. CICLO DI ANALISI
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA ---
    data_ora_completa = 'Data non estratta';
    try
        parti = strsplit(nome_attuale, '.');
        if length(parti) >= 2 && length(parti{2}) >= 12
            ts = parti{2};
            data_ora_completa = sprintf('20%s-%s-%s %s:%s:%s', ts(1:2), ts(3:4), ts(5:6), ts(7:8), ts(9:10), ts(11:12));
        end
    catch
    end

    fprintf('Analizzando: %s (%d di %d)...\n', nome_attuale, k, length(lista_file));
    
    try
        % 1. Analisi Silbido
        info_audio = audioinfo(percorso_completo);
        detections = dtTonalsTracking(percorso_completo, 0, info_audio.Duration - 0.1);
        
        % 2. Salvataggio .mat
        nome_mat = [nome_attuale(1:end-4), '_risultati.mat'];
        save(fullfile(cartella_audio, nome_mat), 'detections');
        
        % 3. Conteggio fischi (Fix fondamentale per M2)
        totale_fischi = 0;
        for i = 0:(detections.size() - 1)
            f = detections.get(i);
            t = double(f.get_time()); 
            if ~isempty(t) && t(1) > 2.0
                totale_fischi = totale_fischi + 1;
            end
        end
        
        % 4. Scrittura Excel (Append mode)
        Tabella = table({nome_attuale}, {data_ora_completa}, totale_fischi, ...
            'VariableNames', {'file_name', 'datetime', 'Fischi_Trovati'});
        
        % Salviamo l'Excel direttamente nella cartella dei fischi
        writetable(Tabella, fullfile(cartella_audio, 'Analisi_fischi_buoni88.xlsx'), 'WriteMode', 'append');
        
    catch ME 
        fprintf('⚠️ Errore su %s: %s\n', nome_attuale, ME.message);
    end
end
fprintf('\n✅ ANALISI COMPLETATA! Controlla la cartella dei fischi, trovi tutto lì. 💪\n');