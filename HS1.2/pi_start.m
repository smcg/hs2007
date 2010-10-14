% PI_START Starts and runs the perceptual experiment

global bDEBUG

bDEBUG = 0;

% Let user select basedir
% basedir = uigetdir(pwd);
basedir = pwd;
cd(basedir);

% The stimuli that each subject will hear has been predetermined for this
% experiment. The subject identifier entered here matches the subject to
% the corresponding stimulus set.
subjno = input('Which subject [1-10]? ');
while (isempty(subjno) | (subjno<1) | (subjno>10))
    subjno = input('Which subject? ');
end

% Create subject data directory if it does not exist
subj_data_dir = fullfile(basedir,'DATA',sprintf('SUBJ_%02d',subjno));
if ~exist(subj_data_dir,'dir'),
    mkdir(fullfile(basedir,'DATA'),sprintf('SUBJ_%02d',subjno));
end

% Subject session information and results file. The session information
% file stores the status of the current session. In the event that the
% program stops working, this information can be used to restart the trials
% at the point at which it stopped. This file also contains the responses
% to the stimuli. The results file is an excel spreadsheet that can be
% opened in excel for analysis.
sess_info_file = fullfile(subj_data_dir,sprintf('session_info_%02d.mat',subjno));
subj_xls_file = fullfile(subj_data_dir,sprintf('results_%02d.xls',subjno));

% Check for existing session
bNewSession = 1;        % A boolean flag that determines whether a new session is created
if exist(sess_info_file,'file'),
    yesorno=questdlg('Load existing session','Session exists','Yes','No','Yes');
    if strcmp(yesorno,'Yes'),
        % load existing session
        load(sess_info_file);
        if ~isfield(sess_info,'snapshot')
            sess_info.snapshot{2} = sess_info;
        else
            sess_info.snapshot{end+1} = sess_info;
        end
        sess_info.timestamp{end+1} = datestr(now);
        bNewSession = 0;
        if str2num(version('-release')) <14,
            save(sess_info_file,'sess_info','-APPEND');
        else,
            save(sess_info_file,'sess_info','-APPEND','-V6');
        end
    else,
        % Make backup of old session and create a newsession
        disp('Making a backup of old_session');
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat.bak'));
    end
end

% create new session if the newsession flag is set
if bNewSession,
    load trial_info;
    practice_idx = practice_idx(:,subjno);
    present_idx  = present_idx(:,subjno);
    
    sess_info.timestamp{1}   = datestr(now);
    sess_info.practice_start = 1;
    sess_info.practice_end   = length(practice_idx);
    sess_info.present_start  = 1;
    sess_info.present_end    = length(present_idx);
    sess_info.snapshot{1}    = sess_info;
    
    if str2num(version('-release')) <14,
        save(sess_info_file,'sess_info','practice_idx','present_idx','present_filelist','practice_filelist');
    else,
        save(sess_info_file,'sess_info','practice_idx','present_idx','present_filelist','practice_filelist','-V6');
    end
end

if bDEBUG,
    sess_info.practice_start = 1;
    sess_info.practice_end   = 0;
end

% Set up the graphical interface. The interface is visually turned off by
% default.
% Setup parameters
trial.ResponseList = {'Good','Fair','Bad','Not'};
trial.QuestionString = 'Rate the vowel you just heard in the word';
trial.NChoices = length(trial.ResponseList);
trial.bAppendToken = 1;
trial = pi_setup(trial);

tokenmap.ee = 'ee';
tokenmap.ea = 'eh';
tokenmap.i  = 'ih';

% Ask the subject to start the experiment.
uiwait(msgbox('Start experiment','Experiment Setup','modal'));

% Practice phase to accustom subject to the experiment. Although the
% response is recorded, it will likely not be used for analysis. Practice
% phase code is reduplicated from experiment phase for sheer laziness.
for i0 = sess_info.practice_start:sess_info.practice_end,
    % Get information about the stimulus to be presented
    [pth,fname] = fileparts(practice_filelist{practice_idx(i0)});
    info.tokenfull = strtok(fname,'_');
    info.token = info.tokenfull(2:(end-1));
    info.fname = fullfile(basedir,practice_filelist{practice_idx(i0)});
    info.count = [i0 length(practice_idx)+length(present_idx)];
    
    % Get information about the condition being presented.
    idx0 = find(fname=='_');
    idx1 = find(fname=='.');
    practice_resp(i0,1:4) = [strmatch(fname(1:(idx0(1)-1)),{'heed','hid','head'}) ...
        str2num(fname(idx0(1)+1:idx0(2)-1)) str2num(fname(idx0(2)+1))...
        str2num(fname(idx0(3)+1:end))];
    
    % Run a trial
    pi_trialcb('setup',trial.fig,info,tokenmap);
    
    % Retrieve and store user response
    udata = get(trial.fig,'userdata');
    practice_resp(i0,5) = udata.response;
    
    % Increment trial counter
    sess_info.practice_start = i0+1;
    
    % Save session info on a trial by trial basis
    if str2num(version('-release')) <14,
        save(sess_info_file,'sess_info','practice_resp','-APPEND');
    else
        save(sess_info_file,'sess_info','practice_resp','-APPEND','-V6');
    end
end

% Testing phase is identical to the practice phase. 
for i0 = sess_info.present_start:sess_info.present_end,
    % Get information about the stimulus to be presented
    [pth,fname] = fileparts(present_filelist(present_idx(i0),:));
    info.tokenfull = strtok(fname,'_');
    info.token = info.tokenfull(2:(end-1));
    info.fname = fullfile(basedir,present_filelist(present_idx(i0),:));
    info.count = length(practice_idx)+[i0 length(present_idx)];
    
    % Get information about the condition being presented.
    idx0 = find(fname=='_');
    idx1 = find(fname=='.');
    present_resp(i0,1:4) = [strmatch(fname(1:(idx0(1)-1)),{'heed','hid','head'}) ...
        str2num(fname(idx0(1)+1:idx0(2)-1)) str2num(fname(idx0(2)+1)) ...
        str2num(fname(idx0(3)+1:end))];

    % Run a trial
    pi_trialcb('setup',trial.fig,info,tokenmap);

    % Retrieve and store user response
    udata = get(trial.fig,'userdata');
    present_resp(i0,5) = udata.response;

    % Increment trial counter
    sess_info.present_start = i0+1;

    % Save session info on a trial by trial basis
    if str2num(version('-release')) <14,
        save(sess_info_file,'sess_info','present_resp','-APPEND');
    else,
        save(sess_info_file,'sess_info','present_resp','-APPEND','-V6');
    end
end

% Write the excel file
if exist('xlswrite')==2,
    xlswrite(subj_xls_file,present_resp,'Experiment phase');
    xlswrite(subj_xls_file,practice_resp,'Practice phase');
end

% Finish experiment
uiwait(msgbox('Thank you','Experiment Setup','modal'));
close all;

%%%%%%%%%%%%%%%%%%%%% DATA INFORMATION %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  UTTERANCES = {'heed','hid','head'};                                  %
%  SUBJECTS = {'CS2','GI3','HC8','JC2','JW2','MC2','ME3','SO3','SP2'};  %
%  CONDITIONS = {{'bb0','n0'},{'bb0','n1'},{'bb2','n0'},{'bb2','n1'}};  %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%