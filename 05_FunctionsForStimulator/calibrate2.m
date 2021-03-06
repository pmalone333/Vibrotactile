% Calibrate the stimulator
function calibrate(stimDur)

%% What is the stimulus duration?
if (nargin < 1) stimDur = 400; end
pauseDur = 0.50;


%% close/open the right ports
try
stimGenPTB('CloseAll');
catch
end
stimGenPTB('open','COM1')

%% Define stimulus
stimuli = [];
allFreqs = 2.^([0:.1:2]+log2(25));
testFreqs = [allFreqs(1), allFreqs(8), allFreqs(14), allFreqs(21)];
stimuli(1,:) = 1:14;
% stimuli(1,:) = 4*ones(1,14);
for currentFreq = testFreqs
    stimuli(2,:) = currentFreq*ones(1,14);
for iChannel = 1:14
    iChannel

constructStimuli(stimuli(:,iChannel));
pause(pauseDur);

end

end
%% Stimulate  
function constructStimuli(stimulus)
    f = stimulus(2);
    p = stimulus(1);

    stim = {...
        {'fixed',f,1,stimDur},...
        {'fixchan',p},...
        };

    [t,s]=buildTSM_nomap(stim);

    stimGenPTB('load',s,t);
    rtn=-1;
    while rtn==-1
        rtn=stimGenPTB('start');
    end
end


end
