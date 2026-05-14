cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
%%
silbido_init

%% 1. IMPOSTA IL FILE
nome_audio = '5498.250617072504.wav';

%% 2. LANCIA IL DETECTOR (Guarda ovunque)
detections = dtTonalsTracking(nome_audio, 0, Inf);

%% 3. FILTRA E CONTA SOLO I BELUGA (Tra 1500 e 20000 Hz)
numero_fischi_beluga = 0;
for i = 0:(detections.size() - 1)
    fischio = detections.get(i);
    % Se il fischio è nel range giusto, contalo!
    % Riga 16 corretta: estrae le frequenze dall'oggetto Java e le confronta
frequenze = fischio.get_freq(); 
if min(frequenze) >= 1500 && max(frequenze) <= 20000
    numero_fischi_beluga = numero_fischi_beluga + 1;
end
end

%% 4. SALVA RISULTATI PER L'INTERFACCIA
nome_salvataggio = strrep(nome_audio, '.wav', '_risultati.mat');
save(nome_salvataggio, 'detections');

%% 5. AGGIORNA EXCEL CON IL NUMERO FILTRATO
Tabella_Risultati = table({nome_audio}, numero_fischi_beluga, 'VariableNames', {'Nome_File', 'Fischi_Beluga'});
writetable(Tabella_Risultati, 'Conteggio_Beluga.xlsx', 'WriteMode', 'append');

%% 6. APRI IL GRAFICO NITIDO
dtTonalAnnotate('Filename', nome_audio);
fprintf('Finito! Trovati %d fischi di beluga.\n', numero_fischi_beluga);