%% 0. INIZIALIZZAZIONE (PULIZIA E AGGANCIO ALLA RELEASE 3.0)
clear all; clc;

% 1. ANDIAMO NELLA CARTELLA SICURA
cd '/Users/valentinabottoni/TESI/Silbido_Profundo/silbido-release3.0'
addpath(genpath(pwd));

% 2. CARICHIAMO IL MOTORE JAVA (Senza complicazioni)
javaaddpath(fullfile(pwd, 'java', 'bin'));
javaaddpath(fullfile(pwd, 'java', 'lib', 'Jama-1.0.3.jar'));
javaaddpath(fullfile(pwd, 'java', 'lib', 'joda-time-2.10.1.jar'));
javaaddpath(fullfile(pwd, 'java', 'lib', 'tritonus_share.jar'));

silbido_init;
fprintf('✅ MOTORE ATTIVATO: Silbido è pronto all''uso!\n');

%% 1. IMPOSTA LE CARTELLE E TROVA I FILE
% La cartella che avevi nel tuo script perfetto
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/Fischi_Buoni/';

% Controllo salvavita: se per caso hai spostato la cartella, te la fa cercare
if ~exist(cartella_audio, 'dir')
    fprintf('⚠️ Cartella non trovata al percorso fisso, selezionala col mouse...\n');
    cartella_audio = uigetdir('/Users/valentinabottoni/TESI/', 'Seleziona la cartella con i file .wav');
end

contenuto = dir(fullfile(cartella_audio, '*.wav'));
lista_file = contenuto(~[contenuto.isdir]);
fprintf('📊 Trovati %d file audio pronti per l''analisi.\n', length(lista_file));

%% 2. CICLO DI ANALISI E METADATI (Identico a ieri)
for k = 1:length(lista_file)
    nome_attuale = lista_file(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    
    % --- ESTRAZIONE DATA E ORA (Il tuo codice esatto) ---
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

    fprintf('🔎 Analizzando: %s (%d di %d)...\n', nome_attuale, k, length(lista_file));
    
    try
        % 1. Calcola fine sicura
        info_audio = audioinfo(percorso_completo);
        fine_sicura = info_audio.Duration - 0.1;
        
        % 2. Detection (Silbido in azione)
        detections = dtTonalsTracking(percorso_completo, 0, fine_sicura);
        
        % 3. SALVATAGGIO FILE .MAT 
        nome_mat = [nome_attuale(1:end-4), '_risultati.mat'];
        save(fullfile(cartella_audio, nome_mat), 'detections');
        
        % 4. FILTRO ANTI-IDROFONO E CONTEGGIO (Con la cura per il chip M2)
        totale_fischi = 0;
        for i = 0:(detections.size() - 1)
            fischio = detections.get(i);
            tempi = double(fischio.get_time()); % Il "double" che salva il Mac dal crash
            if ~isempty(tempi) && min(tempi) > 2.0
                totale_fischi = totale_fischi + 1;
            end
        end
        
        % 5. SCRIVE EXCEL (Le tue colonne esatte)
        Tabella_Risultati = table({nome_attuale}, {data_ora_completa}, {anno_lungo}, {mese}, {giorno}, {ora}, {minuti}, {secondi}, totale_fischi, ...
            'VariableNames', {'file_name', 'datetime', 'year', 'month', 'day', 'hour', 'min', 'sec', 'Fischi_Trovati'});
        
        writetable(Tabella_Risultati, fullfile(cartella_audio, 'Analisi_fischi_buoni88.xlsx'), 'WriteMode', 'append');
        
    catch ME 
        fprintf('⚠️ Errore sul file %s.\n ❌ MOTIVO: %s\n', nome_attuale, ME.message);
    end
end
fprintf('\n🎉 ANALISI COMPLETATA! Tutto è andato liscio come ieri.\n');