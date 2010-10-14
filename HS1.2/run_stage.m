function sess_info = run_stage(sess_info,setup_func,setup_id,trial,sess_info_file,subj_data_dir,varargin)

% if sess_info.bNewSession |
if isempty(fieldnames(sess_info.stage(sess_info.stage_idx).info))
    sess_info.stage(sess_info.stage_idx) = setup_func(sess_info.stage(sess_info.stage_idx),setup_id,sess_info.stage_idx,varargin{:});
end

msg_str = pi_messagestr;
toks = upper(trial.token);
if setup_id<5,
    msg = sprintf(msg_str.set,toks{:});
else
    msg = sprintf(msg_str.durset,toks{1});
end
msg = sprintf('%s\n\n%s\n\n%s\n\n%s',msg,sprintf(msg_str.part));
switch(sess_info.stage_idx),
    case 1,
        task = 'label';
        taskstr = 'Labeling test';
        msg1 = sprintf(msg_str.(task).msg,toks{:});
        msg2 = sprintf(msg_str.(task).response,toks{:});
    case {2,3}
        task = 'rate';
        taskstr = 'Rating test';
        toks = repmat({upper(trial.token)},3,1);
        msg1 = sprintf(msg_str.(task).msg,toks{:});
        msg2 = sprintf(msg_str.(task).response);
    case {4,5,6,7,8,9}
        task = 'discrim';
        taskstr = 'Discrimination test';
        msg1 = sprintf(msg_str.(task).msg);
        msg2 = sprintf(msg_str.(task).response);
    otherwise,
end
msg = sprintf('%s\n\n%s\n\n%s\n\n%s\n\n%s',msg,msg1,msg2,sprintf(msg_str.next),msg_str.cont);

displayedmsg = 0;
if sess_info.stage_idx<4,
    % Ask the subject to start the experiment.
    %uiwait(msgbox('Start stage','Experiment Setup','modal'));
    if (sess_info.stage(sess_info.stage_idx).pstart<=sess_info.stage(sess_info.stage_idx).pend)
        if ~displayedmsg,
            uiwait(mymsgbox(msg,taskstr,'modal'));
            displayedmsg = 1;
        end

        % play continuum for rating task
        if (sess_info.stage_idx==2 | sess_info.stage_idx==3) & ~sess_info.stage(sess_info.stage_idx).info.continuum,
            info = sess_info.stage(sess_info.stage_idx).info;
            info.tokenstr = '';
            info.tokenfull = '';

            [val,sort_idx] = sort(sess_info.stage(sess_info.stage_idx).info.porder);
            uiwait(mymsgbox(sprintf(msg_str.setexamples),taskstr));
            for j0=1:2,
                for i0 = 1:numel(sess_info.stage(sess_info.stage_idx).info.porder), %(:)'
                    % Get information about the stimulus to be presented
                    info.token = -i0;
                    feval(info.playfcn,info);
                    pause(.5);
                end
            end
            sess_info.stage(sess_info.stage_idx).info.continuum = 1;
            copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat~'));
            save(sess_info_file,'sess_info');
        end
        uiwait(mymsgbox(sprintf(msg_str.practice),taskstr));
    end

    % Practice phase to accustom subject to the experiment. Although the
    % response is recorded, it will likely not be used for analysis. Practice
    % phase code is reduplicated from experiment phase for sheer laziness.
    info = sess_info.stage(sess_info.stage_idx).info;
    info.tokenstr = '';
    if sess_info.stage_idx==2 | sess_info.stage_idx==3,
        info.tokenfull = upper(trial.token);
    else,
        info.tokenfull = '';
    end

    for i0 = sess_info.stage(sess_info.stage_idx).pstart:sess_info.stage(sess_info.stage_idx).pend,
        % Get information about the stimulus to be presented
        info.token = -i0;
        info.count = [i0,sess_info.stage(sess_info.stage_idx).pend];

        % Run a trial
        pi_trialcb('setup',trial,info,'');

        % Retrieve and store user response
        udata = get(trial.fig,'userdata');
        if isnan(udata.response),
            break;
        end
        sess_info.stage(sess_info.stage_idx).presp(i0,1:2) = udata.response;
        sess_info.stage(sess_info.stage_idx).prespt(i0) = udata.resp;

        % Increment trial counter
        sess_info.stage(sess_info.stage_idx).pstart = i0+1;

        % Save session info on a trial by trial basis
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat~'));
        save(sess_info_file,'sess_info');
    end

    if (sess_info.stage(sess_info.stage_idx).start<=sess_info.stage(sess_info.stage_idx).end),
        if ~displayedmsg,
            uiwait(mymsgbox(msg,taskstr,'modal'));
            displayedmsg = 1;
        end
        uiwait(mymsgbox(sprintf(msg_str.test),taskstr));
    end
    for i0 = sess_info.stage(sess_info.stage_idx).start:sess_info.stage(sess_info.stage_idx).end,
        % Get information about the stimulus to be presented
        info.token = i0;
        info.count = [i0,sess_info.stage(sess_info.stage_idx).end];

        % Run a trial
        pi_trialcb('setup',trial,info,'');

        % Retrieve and store user response
        udata = get(trial.fig,'userdata');
        if isnan(udata.response),
            break;
        end
        sess_info.stage(sess_info.stage_idx).resp(i0,1:2) = udata.response;
        sess_info.stage(sess_info.stage_idx).respt(i0) = udata.resp;

        % Increment trial counter
        sess_info.stage(sess_info.stage_idx).start = i0+1;

        % Save session info on a trial by trial basis
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat~'));
        save(sess_info_file,'sess_info');
    end
else,
    % Ask the subject to start the experiment.
    if (sess_info.stage(sess_info.stage_idx).pstart<=sess_info.stage(sess_info.stage_idx).pend)
        if ~displayedmsg,
            uiwait(mymsgbox(msg,taskstr,'modal'));
            displayedmsg = 1;
        end
        uiwait(mymsgbox(sprintf(msg_str.practice),taskstr));
    end

    % Practice phase to accustom subject to the experiment. Although the
    % response is recorded, it will likely not be used for analysis. Practice
    % phase code is reduplicated from experiment phase for sheer laziness.
    info = sess_info.stage(sess_info.stage_idx).info;
    info.tokenstr = '';
    info.tokenfull = '';
    for i0 = sess_info.stage(sess_info.stage_idx).pstart:sess_info.stage(sess_info.stage_idx).pend,
        % Get information about the stimulus to be presented
        info.token = -i0;
        info.count = [i0,sess_info.stage(sess_info.stage_idx).pend];
        info.pos   = randperm(2)+1;
        info.pos   = info.pos(1);

        % Run a trial
        pi_trialcb('setup',trial,info,'');

        % Retrieve and store user response
        udata = get(trial.fig,'userdata');
        if isnan(udata.response),
            break;
        end
        sess_info.stage(sess_info.stage_idx).presp(i0,1) = udata.response;
        sess_info.stage(sess_info.stage_idx).prespt(i0) = udata.resp;

        % Increment trial counter
        sess_info.stage(sess_info.stage_idx).pstart = i0+1;

        % Save session info on a trial by trial basis
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat~'));
        save(sess_info_file,'sess_info');
    end

    if (info.numreversals<info.maxreversals),
        if ~displayedmsg,
            uiwait(mymsgbox(msg,taskstr,'modal'));
            displayedmsg = 1;
        end
        uiwait(mymsgbox(sprintf(msg_str.test),taskstr));
    end
    i0 = sess_info.stage(sess_info.stage_idx).start;
    last_i0 = i0;
    while (info.numreversals<info.maxreversals) & numel(sess_info.stage(sess_info.stage_idx).info.jnd) < 80,
        % Get information about the stimulus to be presented
        perc_reverse = (info.maxreversals-info.numreversals)/info.maxreversals;
        info.count = [info.numreversals+i0*perc_reverse,info.maxreversals+80*perc_reverse];
        info.pos   = randperm(2)+1;
        info.pos   = info.pos(1);
        dummy =  ((i0-last_i0) > 5) & rand<0.5;
        if ~dummy
            % Run a trial
            pi_trialcb('setup',trial,info,'');

            % Retrieve, check and store user response
            udata = get(trial.fig,'userdata');
            if isnan(udata.response),
                break;
            end
            sess_info.stage(sess_info.stage_idx).resp(i0,1) = str2num(udata.response); %actual answer
            sess_info.stage(sess_info.stage_idx).resp(i0,2) = info.pos; %correct answer
            sess_info.stage(sess_info.stage_idx).respt(i0) = udata.resp;
            i0 = i0+1;
            sess_info.stage(sess_info.stage_idx).start = i0;

            % adjust JND
            info = discrim_adjust_jnd(info,sess_info.stage(sess_info.stage_idx).resp);
        else,
            info2 = info;
            info2.jnd = 250;
            last_i0 = i0;

            % Run a trial
            pi_trialcb('setup',trial,info2,'');

            % Retrieve, check and store user response
            udata = get(trial.fig,'userdata');
            if isnan(udata.response),
                break;
            end

            % Increment trial counter
            info.dummy = [info.dummy; i0 str2num(udata.response) info.pos];
            sess_info.stage(sess_info.stage_idx).drespt(i0) = udata.resp;
        end

        % Increment trial counter
        sess_info.stage(sess_info.stage_idx).info = info;

        % Save session info on a trial by trial basis
        copyfile(sess_info_file,fullfile(subj_data_dir,'session_info.mat~'));
        save(sess_info_file,'sess_info');
    end
end

%         info.numreversals = 0;
%         last_i0 = 0;
%         val = [];
%         for i0=0:80,
%             dummy =  ((i0-last_i0) > 3) & rand<0.5;
%             if dummy 
%                 last_i0 = i0;
%                 info.numreversals = min(info.numreversals + 1,info.maxreversals);
%             end
%             perc_reverse = (info.maxreversals-info.numreversals)/info.maxreversals;
%             val(i0+1) = (info.numreversals+i0*perc_reverse)/(info.maxreversals+80*perc_reverse);
%         end
%         all(diff(val)>=0)
%         plot(val,'.-');
