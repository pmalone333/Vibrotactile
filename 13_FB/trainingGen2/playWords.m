%
% playWords - play the tactile stimuli for the various words
%
global SportH;
recordLoad = 0;

dirs = {'.\gen2words\','.\gen2wordsGeneralization\'};
fileList = {};
% make list of words and locations
for i=1:numel(dirs)
    inDir = dirs{i};

    % get input file list for this directory set
    [status, list] = system(['dir /B /S ',inDir]);
    result = textscan( list, '%s', 'delimiter', '\n' );
    fileList = [fileList,result{1}];
end

% remove all waveformSpecs instances
for j = 1:2 %2 instances
    id = strfind(fileList,'waveformSpecs');
    for i=1:numel(id)
        if numel(id(i)) >0
            fileList(i) = [];
            break;
        end
    end
end

lastWordIndex = numel(fileList);

fprintf('playWords: use the right/left arrow keys to move to next/last word\n');
fprintf('Space bar to repeat, shift/digit to set the digit key to that word,\n');
fprintf('and the digit key (without shift) to play the stimulus associated with it\n');
fprintf('Push x, X or ESC to quit\n');
% initialize the waveforms for digits
digits = zeros(1,10); % indices for 0...9

% load waveforms for these stimuli
fprintf('\n\n loading stimuli:\n');
load([dirs{1},'waveformSpecs']);

% open COM port and send reset to master
piezoDriverGen2('open');
fwrite(SportH,uint8([00, 01, 23])); % reset
if recordLoad == 1
    SportH.RecordDetail = 'verbose';
    SportH.RecordName = 'piezoLog.txt';
    record(SportH,'on');
end
    
loadWave(waveformSpecs); 

if recordLoad == 1
    record(SportH,'off');
end

% now ready to play first stimulus to get going
wordIndex = 1;
load(fileList{wordIndex});
fprintf('playing "%s"\n',word);
rawGesture = gen2ConvertGesture(eventFile);
piezoDriverGen2('loadGesture',rawGesture);
piezoDriverGen2('start');

while 1
    % wait for keypress (blocking)
    w = waitforbuttonpress;
    p = get(gcf, 'CurrentCharacter');
    %fprintf('got %d, array=[%d %d %d %d %d %d %d %d %d %d]\n',double(p),digits(1),digits(2),digits(3),...
    %    digits(4),digits(5),digits(6),digits(7),digits(8),digits(9),digits(10));
try
    switch(double(p))
        case 88 % 'x'
            piezoDriverGen2('close');
            close all;
            return;
        case 120 % 'X'
            piezoDriverGen2('close');
            close all;
            return;
        case 27 % 'esc'
            piezoDriverGen2('close');
            close all;
            return;
            
        case 32 % space bar, repeat
            fprintf('playing "%s"\n',word);
            piezoDriverGen2('start');
            
        case 29 % right arrow, get next word
            if wordIndex < numel(fileList);
                wordIndex = wordIndex + 1;
                load(fileList{wordIndex});
                fprintf('playing "%s"\n',word);
                rawGesture = gen2ConvertGesture(eventFile);
                piezoDriverGen2('loadGesture',rawGesture);
                piezoDriverGen2('start');
            else
                fprintf('At end of word list\n');
            end
            
        case 28 % left arrow
            if wordIndex > 1
                wordIndex = wordIndex - 1;
                load(fileList{wordIndex});
                fprintf('playing "%s"\n',word);
                rawGesture = gen2ConvertGesture(eventFile);
                piezoDriverGen2('loadGesture',rawGesture);
                piezoDriverGen2('start');
            else
                fprintf('At start of word list\n');
            end
            
        case 33 % shift 1
            digits(2) = wordIndex;
            fprintf('digit 1 set to current word\n');
            
        case 64 % shift 2
            digits(3) = wordIndex;
            fprintf('digit 2 set to current word\n');
            
        case 35 % shift 3
            digits(4) = wordIndex;
            fprintf('digit 3 set to current word\n');
            
        case 36 % shift 4
            digits(5) = wordIndex;
            fprintf('digit 4 set to current word\n');
            
        case 37 % shift 5
            digits(6) = wordIndex;
            fprintf('digit 5 set to current word\n');
            
        case 94 % shift 6
            digits(7) = wordIndex;
            fprintf('digit 6 set to current word\n');
            
        case 38 % shift 7
            digits(8) = wordIndex;
            fprintf('digit 7 set to current word\n');
            
        case 42 % shift 8
            digits(9) = wordIndex;
            fprintf('digit 8 set to current word\n');
            
        case 40 % shift 9
            digits(10) = wordIndex;
            fprintf('digit 9 set to current word\n');
            
        case 41 % shift 9
            digits(1) = wordIndex;
            fprintf('digit 0 set to current word\n');
            
        otherwise
            p = double(p);
            if p>=48 && p<=57
                if digits(-(47-p)) > 0
                    idx = digits(-(47-p));                
                    load(fileList{idx});
                    fprintf('playing "%s"\n',word);
                    rawGesture = gen2ConvertGesture(eventFile);
                    piezoDriverGen2('loadGesture',rawGesture);
                    piezoDriverGen2('start');
                else
                    fprintf('That digit not programmed with stimulus\n');
                end
            else
                fprintf('Unknown key!\n');
            end
    end
catch
    foo = 1; % strange char1acters
end
end





