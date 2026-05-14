function [predicted_blk, Indices] = dtDeepWhistle(handle, header,...
    channel, blkstart_s, blklength_s, Shift, Framing, Range)
% [predicted_blk, Indices] = dtDeepWhistle(handle, header,...
%    channel, blkstart_s, blklength_s, Shift, Framing, Range)
% Given a start time and length in seconds, framing
% information in samples ([Length, Advance]), and any optional
% arguments, read in a data block and perform spectral processing.
%
% Returns a confidence map of detected whistles and framing information.
%

%since blklength is shorter on the last block it does not fit our current
%restrictions of input size

% This function is called repeatedly for every block
% We load the neural network only once
persistent net
if isempty(net)
    % Determine where neural net library is stored
    libdir = fullfile(fileparts(which('silbido_init')), ...
        'src/matlab/lib/DeepWhistle');
    % Neural network name
    netname = 'Li_et_al_2020_deep_silbido_361x1500';
    
    % The ONNX network is not needed, it has already been converted
    % to a DAG network. The oriignal network was called this:
    onnx = fullfile(libdir, [netname, '.onnx']);
    % The DAG network was produced by using the function onnx2dag that
    % is in the libdir
    dagfname = fullfile(libdir, [netname, '.mat']);
    net = load(dagfname);
end

Length_s = Framing(1)/1000;
advance_s = Framing(2)/1000;
Length_samples = round(header.fs * Length_s)+1;
Advance_samples = round(header.fs * advance_s);
blkend_s = blkstart_s + blklength_s;

%energy normalization
max_clip = 6;
min_clip = 0;

% todo:  these need to be rounded
start_sample = floor(blkstart_s * header.fs)+1;
end_sample = floor(blkend_s * header.fs);

Signal = ioReadWav(handle, header, start_sample, end_sample, ...
    'Channels', channel, 'Normalize', 'unscaled');


%Normalization
if header.samp.byte > 2
    Signal = Signal / 2^(8*(header.samp.byte- 2));
end


frames_per_s = header.fs/Advance_samples;

% Check if Signal length is smaller than the frame size
if length(Signal) < Length_samples
    warning('Signal length is smaller than Length_samples. Adjusting frame count.');
    % Set last_frame to 1, or handle accordingly
    last_frame = 1;  % Process as one frame (or other logic depending on your needs)

% Ensure Signal is a row vector (1D)
    Signal = Signal(:)';  % Convert to a row vector if necessary

% Pad the signal with zeros to match Length_samples if necessary
    Signal = [Signal, zeros(1, Length_samples - length(Signal))]; % Padding with zeros


% Create Indices manually for the short signal case
    Indices.idx = [1, length(Signal)];  % Just one frame
    Indices.FrameCount = 1;
    Indices.FrameLastComplete = 0;  % Only one frame, no incomplete frames
    Indices.FrameLength = length(Signal);  % Entire signal as the frame length
    Indices.FrameShift = 0;  % No shifting needed for one frame
    Indices.timeidx = 1;  % Only one time index for the single frame

% Define FrameExtractSize for short signal case
   Indices.FrameExtractSize = 1;  % Only one frame
else
    
% Generate frame indices as usual for longer signals
    Indices = spFrameIndices(length(Signal) - Shift, Length_samples, ...
        Advance_samples, Length_samples, frames_per_s, Shift);

% Ensure valid FrameLastComplete
    if Indices.FrameLastComplete < 0
        error('Invalid FrameLastComplete: %d', Indices.FrameLastComplete);
    end

% Calculate last_frame
last_frame = Indices.FrameLastComplete + 1;

end


% Continue with the frame extraction and processing
if last_frame <= 0
    error('last_frame has an invalid value: %d', last_frame);
end


% Figure out number of linear bins.
binHz = header.fs/Length_samples;
nyquistBin = floor(Length_samples);

highCutoffBin = min(ceil(Range(2)/binHz), nyquistBin);
lowCutoffBin= ceil(Range(1)/binHz);



% Compute dft for current block
audio = zeros(last_frame, Length_samples);

for frameidx = 1:last_frame
    frame = spFrameExtract(Signal,Indices,frameidx);

% Ensure frame is a row vector of the correct length
    if size(frame, 1) > 1
        frame = frame';  % Transpose if necessary to ensure it's a row vector
    end
    
    % Pad the frame with zeros if it's shorter than Length_samples
    if length(frame) < Length_samples
        frame = [frame, zeros(1, Length_samples - length(frame))]; % Pad with zeros
    end

% Assign frame to the audio matrix
    audio(frameidx,:) = frame;
end


dftN = size(audio, 2);  % samples in frame & frequencies
fft_spec = abs(fft(audio, dftN,2));

%Entered by Marie
% Nyquist rate is half the sample rate.
% This signal is sampled at 50000, Fs/2 = 50000 / 2
% This translates into half of the frequency bins
NyquistN = ceil((dftN+1) / 2);
fft_spec(: ,NyquistN+1:end) = [];% Removes frequencie above Nyquist


fft_spec = transpose(fft_spec);
fft_spec([1:lowCutoffBin-1,highCutoffBin+1:end],:) = [];

% Check the size of fft_spec
if any(size(fft_spec) <= 0)
    error('FFT spec has invalid dimensions.');
end

normalized_blk = log10(fft_spec);




%normalize3_PuLi - a normalization function created for our model
normalized_blk(normalized_blk>max_clip)=max_clip;
normalized_blk(normalized_blk<min_clip)=min_clip;
normalized_blk = (normalized_blk - min_clip) / (max_clip - min_clip);

try
    inputsize = net.network.Layers(1).InputSize;
catch exception
    if strcmp(exception.identifier, 'MATLAB:structRefFromNonStruct')
        error('silbido:missing_onyx_importer', ...
            ['The ONYX neural network importer has not been installed.\n', ...
            'Type importONNXNetwork and click on the link to install']);
    end
end

blksize = size(normalized_blk);

blksize = size(normalized_blk);
if any(blksize <= 0)
    error('Spectrogram size is invalid. It must have positive dimensions.');
end


%If the spectrogram size is different from the inputsize of our model,
%we create a new input layer to match the spectrogram
if ~all(blksize == inputsize(1:2))
    connections = net.network.Connections;
    layer = imageInputLayer([blksize,1], 'Name', 'Input_input.1',...
        'Normalization', 'none', 'NormalizationDimension', 'auto');
    layers = net.network.Layers;
    layers(1) = layer;
    lgraph = layerGraph(layers);
    %layerGraph does not connect all layers
    %LayerConnect reconnects any missed layers
    net.network = LayerConnect(lgraph,connections);
end


predicted_blk = predict(net.network,normalized_blk);


% relative to file rather than block
Indices.timeidx = Indices.timeidx + blkstart_s;
end

function net = LayerConnect(lgraph, connections)
%Connects layers that were missed by layerGraph. Given the original
%connections
%lgraph- the new layer graph
%connections- old connections
n = 1;

%When layerGraph builds, all inputs set to 'in1'.
%To determine where connections are lost we normalize
%all 'Desitination' strings to 'in1'
for i = 1 : size(connections,1)
    connections{i,2} = cellstr(regexprep(string(...
        connections{i,2}),'in2','in1'));
end
diffconct = setdiff(connections, lgraph.Connections);

for i = 1 : size(diffconct,1)
    %We change input ports to 'in2' 
    source = string(diffconct{i,1});
    destination = regexprep(string(diffconct{i,2}),'in1', 'in2');
    lgraph = connectLayers(lgraph,string(source),...
        destination);
end
net = assembleNetwork(lgraph);
end

