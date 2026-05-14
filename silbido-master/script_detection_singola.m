cd /Users/valentinabottoni/TESI/Silbido_Profundo/silbido-master
%% 
silbido_init
%% 
 detections = dtTonalsTracking('5498.211104060008.wav',0,Inf);
 
 %% 
 dtTonalAnnotate('Filename', '5498.211103190008.wav');
 %% 
 total_values = 0; % Inizializza il contatore

 for i = 1:tonals.size() % Scorri ogni elemento della LinkedList
     sublist = tonals.get(i-1); % Ottieni la sottolista (indice Java, quindi i-1)
     total_values = total_values + numel(sublist); % Conta gli elementi della sottolista
 end

 disp(['Numero totale di valori: ', num2str(total_values)]);




