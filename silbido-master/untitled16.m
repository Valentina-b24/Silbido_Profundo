

%% 2. ANALISI FILE AUDIO
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/Fischi_Buoni/'; 
contenuto = dir(fullfile(cartella_audio, '*.wav'));

fprintf('Trovati %d file audio.\n', length(contenuto));
Risultati_Totali = table();

for k = 1:length(contenuto)
    nome_attuale = contenuto(k).name;
    percorso_completo = fullfile(cartella_audio, nome_attuale);
    fprintf('Analizzando: %s...\n', nome_attuale);
    
    try
        info_audio = audioinfo(percorso_completo);
        detections = dtTonalsTracking(percorso_completo, 0, info_audio.Duration - 0.1);
        
        % Conteggio fischi (Filtro > 2 sec)
        totale_fischi = 0;
        for i = 0:(detections.size() - 1)
            if detections.get(i).get_time()(1) > 2.0
                totale_fischi = totale_fischi + 1;
            end
        end
        
        % Aggiungi riga alla tabella
        nuova_riga = table({nome_attuale}, totale_fischi, 'VariableNames', {'File', 'Fischi'});
        Risultati_Totali = [Risultati_Totali; nuova_riga];
        
    catch ME
        fprintf('Errore su %s: %s\n', nome_attuale, ME.message);
    end
end

% Salvataggio Excel finale
if ~isempty(Risultati_Totali)
    writetable(Risultati_Totali, fullfile(cartella_audio, 'Analisi_Finale.xlsx'));
    fprintf('✅ Analisi finita! Excel creato.\n');
end