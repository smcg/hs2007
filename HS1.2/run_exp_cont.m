function sess_info = run_exp_dt(subjid,tokens,setup_id,basedir,stage_number);
% PI_START Starts and runs the perceptual experiment

global bDEBUG bDEBUGVISUAL

bDEBUG = 0;
bDEBUGVISUAL = 0;
NUMPRACTICE = 11;

% Let user select basedir
% basedir = uigetdir(pwd);
%basedir = pwd;
%cd(basedir);

% Subject identifier
% if bDEBUG,
%     subjid = 'M06dt';
% else
%     subjid = input('Enter subject identifier? ','s');
% end

% Create subject data directory if it does not exist
subj_data_dir = fullfile(basedir,'DATA',subjid);
if ~exist(subj_data_dir,'dir'),
    mkdir(fullfile(basedir,'DATA'),subjid);
end

% Subject session information and results file. The session information
% file stores the status of the current session. In the event that the
% program stops working, this information can be used to restart the trials
% at the point at which it stopped. This file also contains the responses
% to the stimuli. The results file is an excel spreadsheet that can be
% opened in excel for analysis.
sess_info_file = fullfile(subj_data_dir,sprintf('session_info_%s.mat',subjid));
subj_xls_file = fullfile(subj_data_dir,sprintf('results_%s.xls',subjid));

% Check for existing session
sess_info.bNewSession = 1;        % A boolean flag that determines whether a new session is created
if exist(sess_info_file,'file'),
    yesorno='Yes';%questdlg('Load existing session','Session exists','Yes','No','Yes');
    if strcmp(yesorno,'Yes'),
        % load existing session
        load(sess_info_file);
        sess_info.snapshot = {};
%         if ~isfield(sess_info,'snapshot')
%             sess_info.snapshot{2} = sess_info;
%         else
%             sess_info.snapshot{end+1} = sess_info;
%         end
        sess_info.timestamp{end+1} = datestr(now);
        sess_info.bNewSession = 0;
%         if str2num(version('-release')) <14,
            save(sess_info_file,'sess_info','-APPEND');
%         else,
%             save(sess_info_file,'sess_info','-APPEND','-V6');
%         end
    else,
        % Make backup of old session and create a newsession
        disp('Making a backup of old_session');
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat.bak'));
    end
end

% create new session if the newsession flag is set
if sess_info.bNewSession,
    sess_info.timestamp{1}  = datestr(now);
    sess_info.stage_idx     = [];
%     if setup_id<5,
        sess_info.stages        = 9;
        sess_info.stage_order   = 1:9; %[1 1+randperm(2),3+randperm(3)];
%     else
%         sess_info.stages        = 7;
%         sess_info.stage_order   = 1:7; %[3+randperm(4)];
%     end
    for i0=sort(sess_info.stage_order), %1:sess_info.stages,
        sess_info.stage(i0).pstart   = 1;
        sess_info.stage(i0).pend     = NUMPRACTICE;
        sess_info.stage(i0).start    = 1;
        sess_info.stage(i0).end      = 0;
        sess_info.stage(i0).done     = 0;
        sess_info.stage(i0).presp    = [];
        sess_info.stage(i0).resp     = [];
        sess_info.stage(i0).info     = struct();
    end
    sess_info.snapshot{1}   = sess_info;
    
%     if str2num(version('-release')) <14,
        save(sess_info_file,'sess_info');
%     else,
%         save(sess_info_file,'sess_info','-V6');
%     end
end

if bDEBUG,
%     NUMPRACTICE = 0;
%     sess_info.practice_start = 1;
%     sess_info.practice_end   = NUMPRACTICE;
end

if isempty(sess_info.stage_idx)
    stage_start = 1;
else,
    stage_start = find(sess_info.stage_order == sess_info.stage_idx);
end
% msg_str = pi_messagestr;
% toks = upper(tokens);
% if setup_id<5,
%     msg = sprintf(msg_str.set,toks{:});
% else
%     msg = sprintf(msg_str.durset,toks{1});
% end
% msg = sprintf('%s\n\n%s\n\n%s\n\n%s',msg,sprintf(msg_str.part),sprintf(msg_str.response),msg_str.cont);
% uiwait(mymsgbox(msg,'','modal'));

for s0=stage_number, %stage_start:sess_info.stages,
    sess_info.stage_idx = s0; %sess_info.stage_order(s0);
    switch sess_info.stage_idx,
        case 1,
            % labeling
            % Set up the graphical interface. The interface is visually turned off by
            % default.
            % Setup parameters
            trial.ResponseList = strcat(tokens',' (',{'1','2'}',') ');
            trial.QuestionString = 'Select the the word you just heard';
            trial.token = tokens;
            trial.NChoices = length(trial.ResponseList);
            trial.Nkey = {'1','2'};
            trial.breaks = [];
            trial.bAppendToken = 0;
            trial = pi_setup(trial);
            set(trial.enable_repeat,'Value',0);
            sess_info = run_stage(sess_info,@label_setup,setup_id,trial,sess_info_file,subj_data_dir);
        case {2,3},
            % rating
            % Set up the graphical interface. The interface is visually turned off by
            % default.
            % Setup parameters
            trial.ResponseList = {'1 worst','2','3','4','5','6','7 best'};
            trial.QuestionString = cat(2,'How good an example of the word ',tokens{sess_info.stage_idx-1},' did you hear');
            trial.token = tokens{sess_info.stage_idx-1};
            trial.NChoices = length(trial.ResponseList);
            trial.Nkey = {'1','2','3','4','5','6','7'};
            trial.breaks = [];
            trial.bAppendToken = 0;
            trial = pi_setup(trial);
            set(trial.enable_repeat,'Value',0);
            sess_info = run_stage(sess_info,@rate_setup,setup_id,trial,sess_info_file,subj_data_dir,sess_info_file);
        case {4,5,6,7,8,9},
            % discrimination
            % Set up the graphical interface. The interface is visually turned off by
            % default.
            % Setup parameters
            trial.ResponseList = {'2 (2nd is different)','3 (3rd is different)'};
            trial.QuestionString = 'Was the second word or the third word different from the rest?';
            trial.NChoices = length(trial.ResponseList);
            trial.token = tokens;
            trial.Nkey = {'2','3'};
            trial.breaks = [];
            trial.bAppendToken = 0;
            trial = pi_setup(trial);

            set(trial.enable_repeat,'Value',0);
            sess_info = run_stage(sess_info,@discrim_setup,setup_id,trial,sess_info_file,subj_data_dir,sess_info_file);
        otherwise,
            error('Unknown stage');
    end
%     msg = sprintf('%s',sprintf(msg_str.finishedpart,s0,sess_info.stages));
%     uiwait(mymsgbox(msg,'','modal'));
end


% Finish experiment
%uiwait(msgbox('Thank you','Experiment Setup','modal'));
%close all;