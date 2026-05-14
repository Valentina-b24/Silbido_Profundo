function batchdetect_beluga(detext, CorpusBase)
% batchdetect(detext, CorpusBase)
% Run detections on a set of files in directory CorpusBase

if nargin < 1 || ~ ischar(detext)
    error('Must supply extension for detection files')
elseif detext(1) ~= '.'
    detext = ['.', detext];
end

if nargin < 2
    system = getenv('COMPUTERNAME');  % Windows only
    switch system
        case 'IRRAWADDY'
            CorpusBase = 'd:\corpora\dclmmpa2011\devel_data\';
        otherwise
            error('unknown system');
    end
end

% make sure trailing file seperator on the CorpusBase
if CorpusBase(end) ~= filesep && CorpusBase(end) ~= '/'
    CorpusBase(end+1) = '\';
end

start_t = tic;

% find files for which we have ground truth
name = 'all';
switch name
    case 'dclmmpa2011'
        % Files used in Roch et al. paper.
        % Note that at least one sighting spans two files, these
        % results were combined manually in the paper.
        audio = {
            'bottlenose/palmyra092007FS192-070924-205305.wav'
            'bottlenose/palmyra092007FS192-070924-205730.wav'
            'bottlenose/Qx-Tt-SCI0608-N1-060814-121518.wav'
            'spinner/palmyra092007FS192-070927-224737.wav'
            'spinner/palmyra092007FS192-071011-232000.wav'
            'spinner/palmyra102006-061103-213127_4.wav'
            'melon-headed/palmyra092007FS192-070925-023000.wav'
            'melon-headed/palmyra092007FS192-071004-032342.wav'
            'melon-headed/palmyra102006-061020-204327_4.wav'
            'common/QX-Dc-FLIP0610-VLA-061015-165000.wav'
            'common/Qx-Dc-SC03-TAT09-060516-171606.wav'
            'common/Qx-Dc-CC0411-TAT11-CH2-041114-154040-s.wav'
            'common/Qx-Dd-SCI0608-N1-060815-100318.wav'
            'common/Qx-Dd-SCI0608-Ziph-060817-100219.wav'
            'common/Qx-Dd-SCI0608-Ziph-060817-125009.wav'
            };
        detections = strrep(audio, '.wav', detext);
        basedir = CorpusBase;
    otherwise
      % Cerca direttamente i file .wav nella tua cartella
      [gtfiles, ~] = utFindFiles({'*.wav'}, {CorpusBase}, true);
      audio = gtfiles;
      
      % Salva i risultati .mat nella stessa identica cartella dei .wav
      detections = strrep(gtfiles, '.wav', detext);
      basedir = '';
end

N = length(audio);
for idx=1:N
    fprintf('Processing %d/%d %s to\n\t%s\n', idx, N, audio{idx}, detections{idx});
   d = dtTonalsTracking(fullfile(basedir, audio{idx}), 0, Inf, ...
        'Framing', [2 8], ...              % [Avanzamento, Lunghezza] in millisecondi per "affettare" l'audio.
        'Noise', 'median', ...             % Calcola il rumore di fondo medio e lo sottrae per "pulire" l'audio.
        'PeakMethod', 'DeepWhistle', ...   % Usa la rete neurale (Silbido Profundo) per il rilevamento.
        'ConfidenceThresh', 0.5, ...       % Soglia dell'IA (0-1). A 0.5 rileva i fischi di cui è sicura almeno al 50%.
        'Range', [2000 20000], ...         % Range di frequenza in Hz. Cerca fischi solo tra i 2 kHz e i 20 kHz.
        'ActiveSet_s', 0.1);                 % Durata minima in secondi. Scarta i suoni tonali che durano meno di 0.1s.
    % Create subdirectory if it does not exist
    [dname, fname] = fileparts(detections{idx});
    if ~ exist(dname, 'dir')
        mkdir(dname);
    end
    dtTonalsSave(detections{idx}, d);

    fprintf('Elapsed time since start:  %s\n', sectohhmmss(toc(start_t)));

end


