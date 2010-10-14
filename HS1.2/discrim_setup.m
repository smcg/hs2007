function stage = discrim_setup(stage,id,stageid,varargin)

global sdir
%[pth,fn] = fileparts(which(mfilename));
datadir = fullfile(sdir,sprintf('S%02d',id));
%datadir = fullfile('E:\RESEARCH\EXPERIMENTS\CS04_D.1.2\STIMULI\',sprintf('S%02d',id));
if ~isfield(stage.info,'setup')
    load(fullfile(datadir,sprintf('discrim_CONTINUUM_%02d',id)));

    stage.pstart     = 1;
    stage.pend       = 5;
    stage.start     = 1;
    stage.end       = inf;
    stage.resp      = [];
    stage.info.numreversals = 0;
    stage.info.maxreversals = 14;
    
    stage.info.files   = labelfiles;
    stage.info.playfcn = @playdiscrimtoken;
    stage.info.iii     = 0.7;

    % Play noise for 2 of the 4 discrim runs for sibilants
    %     if id==4 & stageid>5,
    %         stage.info.play_noise = 1;
    %     else
%     if stageid==6 | stageid==7,
%             stage.info.play_noise = 1;
%     else
            stage.info.play_noise = 0;
%     end
    %     end

%     if stageid == 4,
%         stage.info.standard= 1;
%     elseif stageid == 5,
%         stage.info.standard= 500;
%     elseif stageid == 6,
%         stage.info.standard= 1000;
%     elseif stageid == 7,
        sess_file = varargin{1};
        labelidx = str2num(char(regexprep(labelfiles,'\D','')));
        if id<5,
			try
            standard = get_boundary(sess_file);
            standard = find(standard==str2num(char(regexprep(labelfiles,'\D',''))));
            if standard<(0.2*numel(labelidx)) || standard>(0.8*numel(labelidx))
                warning(sprintf('NOTE: Boundary too close to edge %d.', standard));
				standard = round(numel(labelidx)/2);
                fprintf('Setting it to middle: %d',standard);
            end
            stage.info.standard = standard;
			catch
				stage.info.standard = round(numel(labelidx)/2);
				warning(sprintf('Couldn''t find boundary. Setting it to: %d',stage.info.standard));
			end
		else
            stage.info.standard = round(numel(labelidx)/2);
        end            
%     end

    stage.info.jnd     = 250;
    stage.info.stepsize= 1;
    stage.info.pos     = 2;
    stage.info.correct = 0;
    stage.info.feedback= 1;
    
    stage.info.min     = 1;
    stage.info.max     = 5;
    stage.info.setup   = 1;
    stage.info.dummy   = [];
end