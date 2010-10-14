function stage = label_setup(stage,id,stageid)

global sdir
%[pth,fn] = fileparts(which(mfilename));
datadir = fullfile(sdir,sprintf('S%02d',id));
%datadir = fullfile('E:\RESEARCH\EXPERIMENTS\CS04_D.1.2\STIMULI\',sprintf('S%02d',id));
if ~isfield(stage.info,'setup')
    load(fullfile(datadir,sprintf('label_CONTINUUM_%02d',id)));

    numreps            = 10;
    stage.start     = 1;
    stage.end       = numreps*length(labelfiles);
    %     idx                = repmat([1:length(labelfiles)]',1,numreps);
    %     idx                = idx(:);
    idx = sub_block_random(length(labelfiles),numreps);
    stage.info.files   = labelfiles;
    stage.info.playfcn = @playlabeltoken;
    stage.info.porder  = idx((end-stage.pend+1):end);
	
	idx = idx(randperm(numel(idx))); % completely randomize order. Block random not good.
    stage.info.order   = idx(:);
    stage.info.token   = 1;
    stage.info.setup   = 1;
    stage.info.feedback= 0;
end

function idx = sub_block_random(N,numreps)
idx = zeros(N,numreps);
for n0=1:numreps,
    idx(:,n0) = randperm(N)';
end
idx = idx(:);