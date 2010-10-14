function stage = rate_setup(stage,id,stageid,varargin)

global sdir
%[pth,fn] = fileparts(which(mfilename));
datadir = fullfile(sdir,sprintf('S%02d',id));
if ~isfield(stage.info,'setup')
    load(fullfile(datadir,sprintf('rate_CONTINUUM_%02d',id)));
    
    sess_file = varargin{1};
    [standard,bndry,fileidx] = get_boundary(sess_file);
    bndry = find(fileidx==str2num(char(regexprep(labelfiles,'\D',''))));
    if isempty(bndry),
        error('No boundary found');
    end
    if stageid == 2,
%         bndry = min(floor(bndry)+2,numel(labelfiles));
        bndry = min(floor(bndry),numel(labelfiles));
        numfiles = bndry;
    else
%         bndry = max(1,ceil(bndry)-2);
        bndry = max(1,ceil(bndry));
        numfiles = numel(labelfiles)-bndry+1;
    end
    
    numreps            = 10;
    stage.start        = 1;
    stage.end          = numreps*numfiles;
    %    idx                = repmat([1:length(labelfiles)]',1,numreps);
    %    idx                = idx(:);
    idx = sub_block_random(numfiles,numreps);
    if stageid == 3,
        idx = idx + bndry - 1;
    end
    stage.info.files   = labelfiles;
    stage.info.playfcn = @playlabeltoken;
%     stage.info.porder  = [[1:length(labelfiles)]';idx((end-stage.pend+1):end)];
    stage.info.porder  = unique(idx); %idx((end-numfiles+1):end);
    stage.pstart        = 1;
    stage.pend          = numel(stage.info.porder);
    stage.info.order   = idx;
    stage.info.token   = 1;
    stage.info.setup   = 1;
    stage.info.feedback= 0;
    
    stage.info.continuum= 0;
end

function idx = sub_block_random(N,numreps)
idx = zeros(N,numreps);
for n0=1:numreps,
    idx(:,n0) = randperm(N)';
end
idx = idx(:);