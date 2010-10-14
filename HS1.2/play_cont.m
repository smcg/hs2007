function play_cont(id,bfor)

if nargin<2,
    bfor = 1;
end

bd = fullfile('STIMULI','060717')

% load(sprintf('STIMULI\S%02d\label_CONTINUUM_%02d.mat',id));
load(sprintf('STIMULI\\S%02d\\rate_CONTINUUM_%02d.mat',id,id));
N = numel(labelfiles);

yfor =[];yrev=[];
for i0=1:N,
    [y1,fs] = wavread(fullfile(bd,labelfiles{i0}));
    [y2,fs] = wavread(fullfile(bd,labelfiles{N+1-i0}));
    yfor = [yfor;zeros(.3*fs,1);y1(:)];
    yrev = [yrev;zeros(.3*fs,1);y2(:)];
end

if bfor,
    wavplay(yfor,fs);
else,
    wavplay(yrev,fs);
end