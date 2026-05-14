cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
silbido_init

%% 1. DIAGNOSTICA CARTELLA
cartella_audio = '/Users/valentinabottoni/TESI/Fischi_Beluga/No_fischi_no_rumore/';

% Controlliamo se MATLAB vede almeno la cartella
if ~exist(cartella_audio, 'dir')
    error('ERRORE: MATLAB non trova proprio la cartella! Controlla il percorso.');
end

% Vediamo TUTTO quello che c'è dentro, senza filtri
contenuto = dir(cartella_audio);
fprintf('La cartella contiene in totale %d elementi (inclusi file nascosti).\n', length(contenuto));

% Stampiamo i nomi dei primi file per capire come si chiamano davvero
for i = 1:min(length(contenuto), 5)
    fprintf('Elemento trovato: %s\n', contenuto(i).name);
end

%% 2. FILTRO MANUALE FORZATO
% Cerchiamo i file che finiscono per .wav o .WAV in modo molto aggressivo
lista_file = [];
for i = 1:length(contenuto)
    nome = contenuto(i).name;
    % Se finisce per wav (minuscolo o maiuscolo) e NON è un file nascosto del Mac
    if (strcmpi(nome(end-min(3,length(nome))+1:end), 'wav')) && ~startsWith(nome, '._')
        lista_file = [lista_file; contenuto(i)];
    end
end

fprintf('--- RISULTATO FINALE ---\n');
fprintf('File audio validi trovati: %d\n', length(lista_file));