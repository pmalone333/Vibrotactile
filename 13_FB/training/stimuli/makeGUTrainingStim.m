nStimPerBlock = 60;

tmp = importdata('rsaset.csv');
dm = tmp.data;
load('wordlist.mat');

%% levels 1-5; 2-AFC

thresh = [3.99, 3.49, 3, 2, 0]; %dissimilarity threshold for levels 1-5

stim = {};
label = {};
for l=1:5
    ind = find(dm>thresh(l));
    [rows, columns] = ind2sub(size(dm), ind);
    for w=1:length(wordlist)
        load(['GU/' wordlist{w} '.mat']);
        label{l}{w,1} = wordlist{w};
        stim{l}{w,1} = s;
        stim{l}{w,2} = t;
        % get index of words with > thresh1 dissimilarity
        i = rows(columns==w);
        order = randperm(length(i));
        i = i(order); % randomize order of array
        load(['GU/' wordlist{i(1)} '.mat']);
        label{l}{w,2} = wordlist{i(1)};
%         stim{l}{w,3} = s;
%         stim{l}{w,4} = t;
    end
    %duplicate stimuli
    stim{l} = repmat(stim{l},nStimPerBlock/length(stim{l}),1);
    label{l} = repmat(label{l},nStimPerBlock/length(label{l}),1);
end

%% levels 6-10; 3-AFC

thresh = [3.99, 3.49, 3, 2, 0]; %dissimilarity threshold for levels 1-5

stim2 = {};
label2 = {};
for l=1:5
    ind = find(dm>thresh(l));
    [rows, columns] = ind2sub(size(dm), ind);
    for w=1:length(wordlist)
        load(['GU/' wordlist{w} '.mat']);
        label2{l}{w,1} = wordlist{w};
        stim2{l}{w,1} = s;
        stim2{l}{w,2} = t;
        % get index of words with > thresh1 dissimilarity
        i = rows(columns==w);
        order = randperm(length(i));
        i = i(order); % randomize order of array
        load(['GU/' wordlist{i(1)} '.mat']);
        label2{l}{w,2} = wordlist{i(1)};
        label2{l}{w,3} = wordlist{i(2)};
    end
    %duplicate stimuli
    stim2{l} = repmat(stim2{l},nStimPerBlock/length(stim2{l}),1);
    label2{l} = repmat(label2{l},nStimPerBlock/length(label2{l}),1);
end

stim = [stim stim2];
label = [label label2];

save('stimuli_GU','stim','label')