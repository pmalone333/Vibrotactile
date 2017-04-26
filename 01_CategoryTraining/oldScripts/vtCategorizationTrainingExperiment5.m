%vibrotactile categorization training! called by vtCategorizationTraining.m
%Clara A. Scholl, cas243@georgetown.edu
function vtCategorizationTrainingExperiment5(name, exptdesign)
try
    rand('twister',sum(100*clock))

    % Open a screen and display instructions
    screens = Screen('Screens');
    screenNumber = min(screens);

    % Open window with default settings:
    %[w windowRect] = Screen('OpenWindow', screenNumber,[128 128 128], [0 0 200 200]);
    [w windowRect] = Screen('OpenWindow', screenNumber,[128 128 128]);

    %HideCursor;
    %load images
    fixationImage = imread(exptdesign.fixationImage);
    % BLANK IMAGE
    blankImage = imread(exptdesign.blankImage);
    %load the images and pngs
    response1 = imread(exptdesign.cat1label, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    response2 = imread(exptdesign.cat2label, 'png', 'BackgroundColor', [0.5 0.5 0.5]);

    %feedback for incorrect trials
    fb1=imread(exptdesign.fb1, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    fb2=imread(exptdesign.fb2, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    fb3=imread(exptdesign.fb3, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    fb4=imread(exptdesign.fb4, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    correct1=imread(exptdesign.correct1, 'png', 'BackgroundColor', [0.5 0.5 0.5]);
    correct2=imread(exptdesign.correct2, 'png', 'BackgroundColor', [0.5 0.5 0.5]);

    fixationTexture=Screen('MakeTexture', w, double(fixationImage));
    blankTexture=Screen('MakeTexture', w, double(blankImage));
    response1Texture=Screen('MakeTexture', w, double(response1));
    response2Texture=Screen('MakeTexture', w, double(response2));

    fb1Texture=Screen('MakeTexture', w, double(fb1));
    fb2Texture=Screen('MakeTexture', w, double(fb2));
    fb3Texture=Screen('MakeTexture', w, double(fb3));
    fb4Texture=Screen('MakeTexture', w, double(fb4));
    correct1Texture=Screen('MakeTexture', w, double(correct1));
    correct2Texture=Screen('MakeTexture', w, double(correct2));
    %Display experiment instructions
    drawAndCenterText(w, ['Please review instructions \n'...
        'Please click a mouse button to advance at each screen'],1)

    drawAndCenterText(w,['\nOn each trial, you will feel a vibration \n'...
        'You will indicate the correct category label for the vibration\n'...
        'by clicking the mouse (left or right) according to the correct label\n'...
        'presented on the screen.'  ],1)

    drawAndCenterText(w, ['If you are correct, the next trial will begin.\n'...
        'If you are inccorect, you will see the CORRECT label for the vibration\n'...
        'and have the opportunity to review the stimulus while you view the correct label.\n'...
        'When you click the mouse, you will feel the vibration again'], 1)

    %load training stimuli
    load('trainingStimuli6.mat');
    level=exptdesign.level;

    for iBlock=1:exptdesign.numSessions %how many blocks to run this training session
        drawAndCenterText(w,['Training Block #' num2str(iBlock) ' of ' num2str(exptdesign.numSessions) '\n\n\n\n'...
            'You are on Level ' num2str(level) '\n\n\n\n' 'Click the mouse to continue'],0);
        KbWait(1);
        if level > 5 && (exist(['./history/' name ], 'dir') == 7)
            clear trainingStimuli;
            filename = dir(['./history/' name '/training*']);
            filename = filename(length(filename)).name;
            load(['./history/' name '/' filename]);
            %randomize the stimuli for this level
            order = randperm(size(trainingStimuli{:},2));
            stimuli = trainingStimuli{1}(:,order);
        elseif level > 5
            order = randperm(size(trainingStimuli{5},2));
            stimuli = trainingStimuli{5}(:,order);
        else
            order = randperm(size(trainingStimuli{level},2));
            stimuli = trainingStimuli{level}(:,order);
        end

        %lower and upper limit of fixation before stimulus is presented
        ll=.3;
        ul=.8;

        %iterate over trials
        for iTrial=1:exptdesign.numTrialsPerSession
            %draw fixation
            Screen('DrawTexture', w, fixationTexture);
            [FixationVBLTimestamp FixationOnsetTime FixationFlipTimestamp FixationMissed] = Screen('Flip',w);
            %after 300-800 ms, present the vibrotactile stimulus
            wait1 = ll + (ul-ll).*rand(1);
            WaitSecs(wait1);
            constructCategoryTrainingStimulus(stimuli(:,iTrial));

            %show the two arm images at a latency of .6+wait1 seconds
            if mod(iBlock,2)
                Screen('DrawTexture', w, response1Texture);
                %what is the correct answer? (left or right?)
                %on odd blocks, lower frequency @top is on left of screen
                if stimuli(1,iTrial)<stimuli(2,iTrial)
                    correctResponse=1;
                    errorTexture=fb4Texture;
                    correctionTexture=correct1Texture;
                else
                    correctResponse=2;
                    errorTexture=fb3Texture;
                    correctionTexture=correct2Texture;
                end
            else
                Screen('DrawTexture', w, response2Texture);
                %what is the correct answer? (left or right?)
                %on even blocks, lower frequency @top is on right of screen
                if stimuli(1,iTrial)<stimuli(2,iTrial)
                    correctResponse=2;
                    errorTexture=fb1Texture;
                    correctionTexture=correct1Texture;
                else
                    correctResponse=1;
                    errorTexture=fb2Texture;
                    correctionTexture=correct2Texture;
                end
            end
            [RespVBLTimestamp RespOnsetTime RespFlipTimestamp RespMissed] = Screen('Flip', w, 0.6+wait1);
            responseStartTime=GetSecs;
            sResp=getResponseMouse(100);
            responseFinishedTime=GetSecs;

            %score the answer -- is sResp(iTrial)==correctResponse?
            if sResp==correctResponse
                accuracy=1;
            else
                accuracy=0;
            end

            %replay stimulus, show correct label, whether correct or
            %incorrect
            if accuracy==0
                %these 200 ms pauses prevent the code from skipping steps on
                %the Dell Windows XP machine
                %what was the correct answer?
                Screen('DrawTexture', w, errorTexture);
                WaitSecs(.1);
                [CorrectionVBLTimestamp CorrectionOnsetTime CorrectionFlipTimestamp CorrectionMissed]=Screen('Flip', w);
                %wait 2 seconds then march straight on to show the
                %correct label and replay stimulus
                WaitSecs(2);
                Screen('DrawTexture', w, correctionTexture);
                WaitSecs(.1);
                [FeedbackVBLTimestamp FeedbackOnsetTime FeedbackFlipTimestamp FeedbackMissed]=Screen('Flip', w);
                KbWait(1);
                constructCategoryTrainingStimulus(stimuli(:,iTrial));
                KbWait(1);
                WaitSecs(.02);
                %stimulusTracking records f1, f2, p1, p2, category, whether the
                %response to the stimulus was correct (1), incorrect (0) or
                %feedback (2); and what the response RT was (in ms, or
                %NaN).
            end


            %record parameters for the trial
            trialOutput(iBlock).responseStartTime(iTrial)=responseStartTime;
            trialOutput(iBlock).responseFinishedTime(iTrial)=responseFinishedTime;
            trialOutput(iBlock).RT(iTrial)=responseFinishedTime-responseStartTime;
            trialOutput(iBlock).sResp(iTrial)=sResp;
            trialOutput(iBlock).accuracy(iTrial)=accuracy;
            trialOutput(iBlock).correctResponse(iTrial)=correctResponse;
            trialOutput(iBlock).wait1(iTrial)=wait1;

            %save stimulus presentation timestamps
            trialOutput(iBlock).FixationVBLTimestamp(iTrial)=FixationVBLTimestamp;
            trialOutput(iBlock).FixationOnsetTime(iTrial)=FixationOnsetTime;
            trialOutput(iBlock).FixationFlipTimestamp(iTrial)=FixationFlipTimestamp;
            trialOutput(iBlock).FixationMissed(iTrial)=FixationMissed;
            trialOutput(iBlock).RespVBLTimestamp(iTrial)=RespVBLTimestamp;
            trialOutput(iBlock).RespOnsetTime(iTrial)=RespOnsetTime;
            trialOutput(iBlock).RespFlipTimestamp(iTrial)=RespFlipTimestamp;
            trialOutput(iBlock).RespMissed(iTrial)=RespMissed;

            if accuracy==0
                %[CorrectionVBLTimestamp CorrectionOnsetTime CorrectionFlipTimestamp CorrectionMissed]
                trialOutput(iBlock).CorrectionVBLTimestamp(iTrial)=CorrectionVBLTimestamp;
                trialOutput(iBlock).CorrectionOnsetTime(iTrial)=CorrectionOnsetTime;
                trialOutput(iBlock).CorrectionFlipTimestamp(iTrial)=CorrectionFlipTimestamp;
                trialOutput(iBlock).CorrectionMissed(iTrial)=CorrectionMissed;
                trialOutput(iBlock).FeedbackVBLTimestamp(iTrial)=FeedbackVBLTimestamp;
                trialOutput(iBlock).FeedbackOnsetTime(iTrial)=FeedbackOnsetTime;
                trialOutput(iBlock).FeedbackFlipTimestamp(iTrial)=FeedbackFlipTimestamp;
                trialOutput(iBlock).FeedbackMissed(iTrial)=FeedbackMissed;
            else
                trialOutput(iBlock).CorrectionVBLTimestamp(iTrial)=NaN;
                trialOutput(iBlock).CorrectionOnsetTime(iTrial)=NaN;
                trialOutput(iBlock).CorrectionFlipTimestamp(iTrial)=NaN;
                trialOutput(iBlock).CorrectionMissed(iTrial)=NaN;
                trialOutput(iBlock).FeedbackVBLTimestamp(iTrial)=NaN;
                trialOutput(iBlock).FeedbackOnsetTime(iTrial)=NaN;
                trialOutput(iBlock).FeedbackFlipTimestamp(iTrial)=NaN;
                trialOutput(iBlock).FeedbackMissed(iTrial)=NaN;
            end

            %tell subject how they did on last trial
            if iTrial==exptdesign.numTrialsPerSession && iBlock < exptdesign.numSessions
                %calculate accuracy
                accuracyForLevel=mean(trialOutput(iBlock).accuracy);
                drawAndCenterText(w, ['Your accuracy was ' num2str(round(accuracyForLevel.*100)) '%\n\n\n'...
                    'Click mouse to continue' ],1)
                KbWait(1)

            elseif iTrial==exptdesign.numTrialsPerSession && iBlock == exptdesign.numSessions
                %calculate accuracy
                accuracyForLevel=mean(trialOutput(iBlock).accuracy);
                drawAndCenterText(w, ['Your accuracy was ' num2str(round(accuracyForLevel.*100)) '%\n\n\n'...
                    'You have completed this training session.  Thank you for your work!' ],1)
                KbWait(1)
                Screen('CloseAll')
            end

            %duration of gap between fixation onset and VT stimulus onset
            clear correctResponse correctionTexture;

            %record stimuli the participant has experienced
        end %end of trial
        %record parameters for the block
        %stimuli, order
        trialOutput(iBlock).order=order;
        trialOutput(iBlock).stimuli=stimuli;
        trialOutput(iBlock).accuracyForLevel=accuracyForLevel;
        trialOutput(iBlock).level = level;

        %check if they pass level and increase level if they do;
        levelAccuracy = [repmat(.75, [1 3]) .70 .75 .775 .80 .825 .85 .875 .9 .925 .95];
        if accuracyForLevel >= levelAccuracy(level);
            level = level + 1;
        end

        if level > 5 && level ~= exptdesign.maxLevel
            %call function that generates a weighted training stimuli file
            makeWeightedTrainingStimuli(trialOutput(iBlock).accuracy, trialOutput(iBlock).stimuli, name);
        end

        %save the session data in the data directory
        save(['./data/' exptdesign.subNumber '/' datestr(now, 'yyyymmdd_HHMM') '-' exptdesign.subName '_block' num2str(iBlock) '.mat'], 'trialOutput', 'exptdesign');
        %save the history data (stimuli, last level passed
        history = [exptdesign.training.history];
        exptdesign.training.history = history;
        lastLevelPassed = level;
        save(['./history/SUBJ' exptdesign.subNumber 'training.mat'], 'history', 'lastLevelPassed');

        if level == exptdesign.maxLevel% && (accuracyForLevel >= levelAccuracy(level))
            accuracyForLevel=mean(trialOutput(iBlock).accuracy);
            drawAndCenterText(w, ['Great Job! You have completed training! \n\n\n'...
                'Your final accuracy was ' num2str(round(accuracyForLevel.*100))])
            Screen('CloseAll')
            break
        end

    end %end of block
    ShowCursor;
    
catch
    ShowCursor;
    save(['./data/' exptdesign.subNumber '/' datestr(now, 'yyyymmdd_HHMM') '-' exptdesign.subName '_block' num2str(iBlock) '.mat'], 'trialOutput', 'exptdesign');
end

end

function drawAndCenterText(window,message,wait)
    if nargin < 3
        wait = 1;
    end
    
    % Now horizontally and vertically centered:
    [nx, ny, bbox] = DrawFormattedText(window, message, 'center', 'center', 0);
    black = BlackIndex(window); % pixel value for black               
    Screen('Flip',window);
    %KbWait(1) waits for a MOUSE click to continue
    KbWait(1);
    WaitSecs(0.2); %this is necessary on the windows XP machine to wait for mouse response -- DOES delay timing!
end

function numericalanswer = getResponseMouse(waitTime)

  %Wait for a response
  numericalanswer = -1;
  mousePressed = 0;
  startWaiting=clock;
  while etime(clock,startWaiting) < waitTime && mousePressed == 0
      %check to see if a button is pressed
       [x,y,buttons] = GetMouse();
       if (~buttons(1) && ~buttons(3))
           continue;
       else
           if buttons(1)
               numericalanswer = 1;
           elseif buttons(3)
               numericalanswer = 2;
           else
               numericalanswer = 0;
           end
          if numericalanswer ~= -1
              %stop checking for a button press
              mousePressed = 1;
          end
       end

  end
  if numericalanswer == -1
      numericalanswer =0;
  end
end
