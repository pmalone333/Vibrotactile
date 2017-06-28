
function trialOutput = VT_VCV_OB_experiment_screeningTask(name,exptdesign)
%dbstop if error;
try
%     dbstop if error;
    KbName('UnifyKeyNames');
    Priority(1)

    %settings so that Psychtoolbox doesn't display annoying warnings--DON'T CHANGE
    oldLevel = Screen('Preference', 'VisualDebugLevel', 1);
    if ~exptdesign.debug
        HideCursor;
    end

    WaitSecs(1); % make sure it is loaded into memory;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %		INITIALIZE EXPERIMENT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % open a screen and display instructions
    screens = Screen('Screens');
    screenNumber = min(screens);

    % Open window with default settings:
    if exptdesign.debug
        [w windowRect] = Screen('OpenWindow', screenNumber,[128 128 128], [0 0 800 800]); %for debugging
    else
        [w windowRect] = Screen('OpenWindow', screenNumber,[128 128 128]);
    end

    % Select specific text font, style and size, unless we're on Linux
    % where this combo is not available:
    if IsLinux==0
        Screen('TextFont',w, 'Courier New');
        Screen('TextSize',w, 14);
        Screen('TextStyle', w, 1+2);
    end;
    
    % Load fixation image from file
    fixationImage = imread(exptdesign.fixationImage);

    % generate fixation texture from image
    fixationTexture = Screen('MakeTexture', w, double(fixationImage));

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %		INTRO EXPERIMENT
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if exptdesign.responseBox
        %flush event queue
        evt=1;
        
        %%while there is no event continue to flush queue
        while ~isempty(evt)
            evt = CMUBox('GetEvent', exptdesign.boxHandle); %empty queue 
        end
        
        % Get the responses keyed in from subject
        drawAndCenterText(w,'Please press the button.',0);
        evt = CMUBox('GetEvent', exptdesign.boxHandle, 1); % get event for button pressed
        responseMapping.button1 = evt.state; % stores button box in variable
      
        % Let the scanner signal the scan to start
        drawAndCenterText(w,'Please get ready.\n\nThe experiment will begin shortly.',0);
        % WARNING: TRRIGGER CORRESPONDS TO A PRESS OF BUTTON 3!!!
        triggername=4; %4 == button press on box 3
        trigger=0; %set equal to a different value 
        
        %while loop that continues to iterate until trigger is pressed at
        %which point triggername == trigger
        while ~isequal(triggername,trigger)
            evt       = CMUBox('GetEvent', exptdesign.boxHandle, 1);
            trigger   = evt.state;
            starttime = evt.time;
        end
        
        %store start time and response mapping in exptdesign struct
        exptdesign.scanStart       = starttime;
        exptdesign.responseMapping = responseMapping;
    else
        %checks for in between runs so that experminter can control run
        %start
        %responseMapping = exptdesign.responseKeyChange;
        drawAndCenterText(w,'Hit Enter to Continue...',1);
        exptdesign.scanStart = GetSecs;
    end
    
    %marks the number of runs passed in from exptdesign struct
    runCounter           = exptdesign.iRuns;
    numBlocks            = exptdesign.numBlocks;
    numTrialsPerSession  = exptdesign.numTrialsPerSession;
    stimulusPresentation = exptdesign.stimulusPresentation;

    %Display experiment instructions
    drawAndCenterText(w,['\nInstructions: press the button whenever you feel the "oddball" vibration \n'],1)
   
    %passes in response profile from wrapper function
    response = exptdesign.response;

    %load training stimuli
    load('VTspeechStim_OBscan.mat');
    stimuli = stim{runCounter};
    label = labels{runCounter};
    %randomize order of stimuli
    order = randperm(size(stimuli,1));
    stimuli = stimuli(order,:);
    label = label(order,:);
    
    totalTrialCounter = 1;
    for iBlock = 1:numBlocks %how many blocks to run this training session
        blockStart = GetSecs;
        for i = 1:size(stimuli,2)
            stimuliBlock{i} = stimuli{iBlock,i};
            labelsBlock{i} = label{iBlock,i};
        end
        
         withinTrialCounter = 1;
        
%         %clear event responses stored in queue
%         while ~isempty(evt)
%             evt = CMUBox('GetEvent', exptdesign.boxHandle);
%         end
        
        %% iterate over trials
        for iTrial = 1:numTrialsPerSession
            
           %call function that generates stimuli for driver box
           if withinTrialCounter == 1
               stimLoadTime = loadStimuli(stimuliBlock, iTrial);
           end
           
           %draw fixation
           Screen('DrawTexture', w, fixationTexture);
           [FixationVBLTimestamp, FixationOnsetTime, FixationFlipTimestamp, FixationMissed] = Screen('Flip',w, exptdesign.scanStart + 10*(iBlock) + 2*(totalTrialCounter-1)); 
           
           stimulusOnset = GetSecs;
           rtn=-1; % why do we still have this?... 
           while rtn==-1
               rtn = stimGenPTB('start');
           end
           stimulusFinished = GetSecs;
           stimulusDuration = stimulusFinished     - stimulusOnset;
           stimulusOffset   = stimulusPresentation - stimulusDuration;
           WaitSecs(stimulusOffset)
           
           responseStartTime = GetSecs;
           
           % Load stimuli
           if withinTrialCounter ~= numTrialsPerSession
                [stimLoadTime] = loadStimuli(stimuliBlock ,iTrial + 1);
           end
           
           waitTime = exptdesign.interTrialInterval - stimLoadTime;
           WaitSecs(waitTime);
           
           if strcmp(labelsBlock{iTrial},'OB')
                correctResponse = 1;
           else
                correctResponse = 0;
           end
        
           
            %record parameters for the trial and block       
           trialOutput(iBlock,1).correctResponse(iTrial)       = correctResponse;
           trialOutput(iBlock,1).stimulusLoadTime(iTrial)      = stimLoadTime;
           trialOutput(iBlock,1).stimulusOnset(iTrial)         = stimulusOnset;
           trialOutput(iBlock,1).stimulusDuration(iTrial)      = stimulusFinished-stimulusOnset;
           trialOutput(iBlock,1).stimulusFinished(iTrial)      = stimulusFinished;
           trialOutput(iBlock,1).responseStartTime(iTrial)     = responseStartTime;
           trialOutput(iBlock,1).FixationVBLTimestamp(iTrial)  = FixationVBLTimestamp;
           trialOutput(iBlock,1).FixationOnsetTime(iTrial)     = FixationOnsetTime;
           trialOutput(iBlock,1).FixationFlipTimestamp(iTrial) = FixationFlipTimestamp;
           trialOutput(iBlock,1).FixationMissed(iTrial)        = FixationMissed;
           trialOutput(iBlock,1).waitTime(iTrial)              = waitTime;
           
           withinTrialCounter = withinTrialCounter + 1;
           totalTrialCounter = totalTrialCounter + 1;
        end % end of trial loop
        %set variables == 0 if no response
        responseFinishedTime = 0;
        sResp=0;
        
        if iTrial == numTrialsPerSession
            WaitSecs(2);
        end
        
%         %collect event queue
%         eventCount=0;
%         evt = CMUBox('GetEvent', exptdesign.boxHandle);
        
%         while ~isempty(evt)
%             eventCount = eventCount + 1;
%             %sResp ==1 if button pressed
%             sResp(eventCount) = 1;
%             %record end time of response
%             responseFinishedTime(eventCount)=evt.time;
%             
%             %load next event in the queue
%             evt = CMUBox('GetEvent', exptdesign.boxHandle);
%         end

            [nx, ny, bbox] = DrawFormattedText(w, ['Did you feel an oddball vibration?'], 'center', 'center', 1);
            [RespVBLTimestamp RespOnsetTime RespFlipTimestamp RespMissed] = Screen('Flip', w);
            while 1
                % Check the state of the keyboard.
                [ keyIsDown, seconds, keyCode ] = KbCheck;
                if keyIsDown
                    sResp = KbName(keyCode);
                    break
                    while KbCheck; end
                end
            end
        
        if (strcmp(sResp,'y') && strcmp(labelsBlock{1},'OB')) || ...
           (strcmp(sResp,'y') && strcmp(labelsBlock{2},'OB')) || ...
           (strcmp(sResp,'y') && strcmp(labelsBlock{3},'OB')) || ...
           (strcmp(sResp,'n') && ~strcmp(labelsBlock{1},'OB')) || ...
           (strcmp(sResp,'n') && ~strcmp(labelsBlock{2},'OB')) || ...
           (strcmp(sResp,'n') && ~strcmp(labelsBlock{3},'OB'))
            accuracy = 1;
            drawAndCenterText(w, 'Correct!',1)
        else
            accuracy = 0;
            drawAndCenterText(w, 'Incorrect.',1)
        end
    
        
        blockFinished = GetSecs;
        
        trialOutput(iBlock,1).sResp                 = sResp;
        trialOutput(iBlock,1).accuracy              = accuracy;
        trialOutput(iBlock,1).responseFinishedTime  = responseFinishedTime;
        trialOutput(iBlock,1).stimuli               = stimuliBlock;
        trialOutput(iBlock,1).labels                = labelsBlock;
        trialOutput(iBlock,1).blockStart            = blockStart;
        trialOutput(iBlock,1).blockFinished         = blockFinished;
    end
    
    sum = 0;
    sum_sResp = 0;
    for i = 1:length(trialOutput)
        sum = sum + trialOutput(i).accuracy;
        sum_sResp = sum_sResp + trialOutput(i).sResp;
    end
    Screen('DrawTexture', w, fixationTexture);
    Screen('Flip',w)
    WaitSecs(10);
     
    ShowCursor;
  
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %		END
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %save the session data in the data directory
    save([exptdesign.saveDir '/' name '_block' num2str(iBlock) '.run' num2str(exptdesign.iRuns) '.mat'], 'trialOutput', 'exptdesign');
    
    % End of experiment, close window:
    Screen('CloseAll');
    Priority(0);
    handle = errordlg(['Subject Responses: ' num2str(sum_sResp)]);
    disp(handle)
    % At the end of your code, it is a good idea to restore the old level.
    %     Screen('Preference','SuppressAllWarnings',oldEnableFlag);
    
    catch
    % This "catch" section executes in case of an error in the "try"
    % section []
    if exptdesign.responseBox
        CMUBox('Close',exptdesign.boxHandle);
    end
    
    % above.  Importantly, it closes the onscreen window if it's open.
    disp('Caught error and closing experiment nicely....');
    Screen('CloseAll');
    Priority(0);
    fclose('all');
    psychrethrow(psychlasterror);

end
end

function drawAndCenterText(window,message,wait, time)
    if nargin < 3
        wait = 1;
    end
    
    if nargin <4
        time =0;
    end
    
    % Now horizontally and vertically centered:
    [nx, ny, bbox] = DrawFormattedText(window, message, 'center', 'center', 0);
    black = BlackIndex(window); % pixel value for black               
    Screen('Flip',window, time);
%     if wait, KbWait(); end
end

function [loadTime] = loadStimuli(stimuliBlock, iTrial)
    
tm = stimuliBlock{1,iTrial}{1};
ch = stimuliBlock{1,iTrial}{2};

startTime = tic;
stimGenPTB('load',ch,tm);
loadTime = toc(startTime);

end