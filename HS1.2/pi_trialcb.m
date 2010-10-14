function varargout = pi_trial(trial_info,varargin)
% PI_TRIAL Sets up and executes each trial

global bDEBUG

switch(lower(trial_info)),
    case 'setup',
        % Setup each trial
        % Input: varargin{1} dialog handle used to retrieve remaining
        %                    handles
        %        varargin{2} token info
        %        varargin{3} a map from token to representation [see
        %                    pi_start]
        trial = varargin{1};
        data = get(trial.fig,'userdata');
        data.started  = 1;
        data.selected = 0;
        data.response = '';
        data.enablerepeat = get(trial.enable_repeat,'Value');
        info     = varargin{2};
        tokenmap = varargin{3};
        tokenstr = info.tokenstr;
        data.info = info;

        % If token information needs to be appended to reponse prompts
        if data.bAppendToken,
            for ch0=1:data.NChoices,
                if ~isempty(tokenmap),
                    responsestring = cat(2,data.ResponseList{ch0},' "',tokenmap.(tokenstr),'"  (',num2str(ch0),')');
                else
                    responsestring = cat(2,data.ResponseList{ch0},' "',tokenstr,'"  (',num2str(ch0),')');
                end
                set(data.(sprintf('btn%s',data.Nkey{ch0})),'string',responsestring);
            end
        end

        if ~get(data.enable_next,'Value'),
            set(data.next_btn,'visible','off');
        end
        
        %Display prompt for word being played
        set(data.str01,'ForegroundColor',[1 1 0]);
        set(data.str01,'visible','on','String',sprintf('%s',['Now playing: ',info.tokenfull]));
        set(data.fig,'visible','on');
        if info.count(1)==0,
            set(data.progressbar,'position',[0 0 eps 1]);
        else,
            set(data.progressbar,'position',[0 0 info.count(1)/info.count(2) 1]);
        end
        % Pause for a short while
        pause(get(data.play_delay,'value'));
        
        % Present the stimulus
        data.resp.timing   = [];
        data.resp.key      = [];
        set(trial.fig,'userdata',data);
        
        tic;
        pi_trialcb('play',info);

        if ~get(data.enable_repeat,'Value'),
            set(data.repeat_btn,'visible','off');
        else
            set(data.repeat_btn,'visible','on');
        end
        
        % Do whatever you want here.
        %[y,fs] = wavread(info.fname);
%         set(data.str01,'String',cat(2,data.QuestionString,': ',info.tokenfull));
        set(data.str01,'String',data.QuestionString);
        
        for ch0=1:data.NChoices,
            set(data.(sprintf('btn%s',data.Nkey{ch0})),...
                'visible','on');
        end

        uiwait(data.fig);
    case 'response',
        %  A mouse click on a response button triggers this option
        tend = toc;
        data = get(gcbf,'userdata');
        if bDEBUG,
            fprintf('Response: [%s]\n',varargin{1});
        end
        data.response = sub_addresponse(data,varargin{1});
        data.resp_val = varargin{1};
        if ~any(data.response =='!')
            if get(data.enable_next,'Value')
                set(data.next_btn,'visible','on');
            end
        end
        if any(data.response ~='!')
            pi_trialcb('setbtn',data);
        end
        %  pi_trialcb('trialend',data);
    case 'keypress',
        %  A key press on the window triggers this option
        tend = toc;
        data = get(gcbf,'userdata');
        keypressval = get(gcbf,'CurrentCharacter');
        
        switch (lower(keypressval))
            case data.Nkey', %cellstr(num2str([0:9]'))',
                if data.started,
                    data.response = sub_addresponse(data,keypressval);
                    data.resp_val = keypressval;
                    tend
                    data.resp.timing   = [data.resp.timing,tend];
                    data.resp.key      = [data.resp.key,keypressval];
                    if any(data.response ~='!')
                        pi_trialcb('setbtn',data);
                        pause(0.2);
                        data.selected = 1;
                        set(data.fig,'userdata',data);
                    end
                    if ~any(data.response =='!')
                        if get(data.enable_next,'Value')
                            set(data.next_btn,'visible','on');
                        end
                    end
                end
            case 'r',
                if data.started & data.enablerepeat,
                    data.resp.timing   = [data.resp.timing,tend];
                    data.resp.key      = [data.resp.key,keypressval];
                    set(data.fig,'userdata',data);
                    pi_trialcb('repeat');
                end
            case {'n','z','/'},
                if data.started & data.selected,
                    pi_trialcb('next');
                end
            case 'p',
                if data.started,
%                     pi_trialcb('trialquit');
                end
            otherwise,
        end
    case 'trialend',
        data = varargin{1};
        if data.info.feedback,
            if num2str(data.info.pos) == data.response,
                set(data.str01,'visible','on','ForegroundColor',[0 1 0],'String','CORRECT');
            else
                set(data.str01,'visible','on','ForegroundColor',[1 0 0],'String','WRONG');
            end

            pause(0.5);
        end
        for ch0=1:data.NChoices,
            set(data.(sprintf('btn%s',data.Nkey{ch0})),...
                'visible','off',...
                'foregroundcolor',[0 0 0],...
                'backgroundcolor',[0.831373 0.815686 0.784314]);
        end
        data.started = 0;
        set(data.fig,'userdata',data);
        figure(data.fig);
        set(data.str01,'visible','off');
        set(data.repeat_btn,'visible','off');

%        if get(data.enable_next,'Value')
%            set(data.next_btn,'visible','on');
%        else,
%            uiresume(data.fig);
%        end
    case 'trialquit',
        data = get(gcbf,'userdata');
        for ch0=1:data.NChoices,
            set(data.(sprintf('btn%s',data.Nkey{ch0})),...
                'visible','off',...
                'foregroundcolor',[0 0 0],...
                'backgroundcolor',[0.831373 0.815686 0.784314]);
        end
        data.started = 0;
        data.response = NaN;
        set(data.fig,'userdata',data);
        figure(data.fig);
        set(data.str01,'visible','off');
        set(data.repeat_btn,'visible','off');
        % End current trial
        set(data.next_btn,'visible','off');
        uiresume(data.fig);
    case 'repeat',
        % repeat the current stimulus
        data = get(gcbf,'userdata');
        pi_trialcb('play',data.info);
        figure(data.fig);
    case 'next',
        % End current trial
        data = get(gcbf,'userdata');
        pi_trialcb('trialend',data);
        set(data.next_btn,'visible','off');
        uiresume(data.fig);
    case 'play',
        % Present the current stimulus
        info = varargin{1};
        feval(info.playfcn,info);
    case 'setbtn',
        data = varargin{1};
        if ~isfield(data,'breaks'),
            Ntiers = 1;
        else,
            Ntiers = numel(data.breaks)+1;
        end
        t0 = find(data.response==data.resp_val);
        if Ntiers == 1,
            start_id = 1;
            end_id = data.NChoices;
        elseif t0 == 1
            start_id = 1;
            end_id = data.breaks(t0)-1;
        elseif t0 == Ntiers
            start_id = data.breaks(t0-1);
            end_id = data.NChoices;
        else
            start_id = data.breaks(t0-1);
            end_id = data.breaks(t0)-1;
        end
        for ch0=start_id:end_id,
            set(data.(sprintf('btn%s',data.Nkey{ch0})),...
                'foregroundcolor',[0 0 0],...
                'backgroundcolor',[0.831373 0.815686 0.784314]);
        end
        set(data.(sprintf('btn%s',data.resp_val)),...
            'foregroundcolor',[1 0 0],...
            'backgroundcolor',[0 0 0]);
%             'foregroundcolor',[0.831373 0.815686 0.784314],...
        figure(data.fig);
end

function response = sub_addresponse(data,keypressval)
idx = strmatch(lower(keypressval),lower(data.Nkey));
response = data.response;
if isempty(idx),
    keypressval = '!';
end
if ~isfield(data,'breaks'),
    Ntiers = 1;
else,
    Ntiers = numel(data.breaks)+1;
end
if isempty(response),
    response = char('!'*ones(1,Ntiers));
end
if Ntiers == 1,
    response = keypressval;
else,
    % get tier_idx
    idx = find(([1 data.breaks]-idx)<=0);
    tier_idx = idx(end);
    response(tier_idx) = keypressval;
end
response