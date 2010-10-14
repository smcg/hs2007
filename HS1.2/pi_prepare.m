%PI_PREPARE Generates the stimulus list for the experiment for each subject

%ones(7,4,15)
% randomize into number of subjects 
NSubj = 10;     % Number of subjects
Ntokens = 5;    % Number of times each token should be used across all subjects

% DATA identifiers
SUBJECTS = {'CS2','GI3','HC8','JC2','JW2','MC2','ME3','SO3','SP2'};
CONDITIONS = {{'bb0','n0'},{'bb0','n1'},{'bb2','n0'},{'bb2','n1'}};
UTTERANCES = {'heed','hid','head'};

% generate all filenames. This code is based on extract_data.m. It creates
% a cell array of filenames of size (#repetition[20] x [#condition*#subjects*#utterances][108])
Nrepetition = 20;
Nnonrepeatedstimuli = length(SUBJECTS)*length(CONDITIONS)*length(UTTERANCES);
count= 0;
for subj = 1:length(SUBJECTS),
    for cond = 1:length(CONDITIONS),
        for utter = 1:length(UTTERANCES),
            count = count+1;
            % extract and write each file out
            for i0=1:Nrepetition,
                %filename = fullfile(pwd,'STIMULI',sprintf('%s_%02d_%d_%03d.mat',UTTERANCES{utter},subj,cond,i0));
                filename = fullfile('STIMULI',sprintf('%s_%02d_%d_%03d.mat',UTTERANCES{utter},subj,cond,i0));
                filenames{i0,count} = filename;
            end
        end
    end
end

% Create a random selection from each column for each subject.
practice_idx = sub2ind(size(filenames),round((Nrepetition-1)*rand(Nnonrepeatedstimuli,NSubj))+1,repmat([1:Nnonrepeatedstimuli]',1,NSubj));
% Since the generated index is in the order of filename creation, randomize
% the indices
for i=1:NSubj,
    idx = randperm(Nnonrepeatedstimuli);
    practice_idx(:,i) = practice_idx(idx,i);
end
practice_filelist = filenames;

% generate testing list
sounddir = fullfile(pwd,'STIMULI');
data = dir(fullfile(sounddir,'*.mat'));
data = char({data(:).name}');

% create a list of indices that repeats each stimulus the appropriate
% number (Ntokens) of times
idxlist = repmat([1:size(data,1)]',1,Ntokens);
idxlist = idxlist(:);

% set the filenames
present_filelist = strcat('STIMULI',filesep,data);

for i0 = 1:length(present_filelist),
    % Get information about the stimulus to be presented
    [pth,fname] = fileparts(present_filelist(i0,:));
   
    % Get information about the condition being presented.
    idx0 = find(fname=='_');
    idx1 = find(fname=='.');
    present_resp(i0,1:4) = [strmatch(fname(1:(idx0(1)-1)),{'heed','hid','head'}) ...
        str2num(fname(idx0(1)+1:idx0(2)-1)) str2num(fname(idx0(2)+1)) ...
        str2num(fname(idx0(3)+1:end))];
end

present_idx = [];
for subj = 1:length(SUBJECTS),
    for cond = 1:length(CONDITIONS),
        for utter = 1:length(UTTERANCES),
            idx = find(...
                (present_resp(:,1)==utter) & ...
                (present_resp(:,2)==subj) & ...
                (present_resp(:,3)==cond));
            idx = repmat(idx,1,Ntokens);
            idx1 = idx(:);
            bRepeat = 1;
            while bRepeat
            idx = reshape(idx1(randperm(length(idx1))),length(idx1)/NSubj,NSubj);
                bRepeat = 0;
%                 for i0=1:size(idx,2),
%                     if length(idx(:,i0))~=length(unique(idx(:,i0)))
%                         bRepeat = 1;
%                         break;
%                     end
%                 end
            end
            present_idx = [present_idx;idx];
        end
    end
end

for i=1:NSubj,
    idx = randperm(size(present_idx,1));
    present_idx(:,i) = present_idx(idx,i);
end

% save the information
if str2num(version('-release')) <14,
    save trial_info practice_filelist practice_idx present_filelist present_idx
else
    save trial_info practice_filelist practice_idx present_filelist present_idx -v6
end