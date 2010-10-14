function level = pi_check_level

global sdir mon_left
if isempty(sdir),
    sdir = fullfile(pwd,'STIMULI'); %uigetdir(pwd,'Select the directory containing the stimuli [the STIMULI folder]');
end
if isempty(mon_left),
    mon_left = -1;
end

allfiles = {};
for id = [2,4],
    datadir = fullfile(sdir,sprintf('S%02d',id));
    load(fullfile(datadir,sprintf('label_CONTINUUM_%02d',id)));
    allfiles = cat(1,allfiles,labelfiles([1,end]));
end

allfiles = allfiles(randperm(numel(allfiles)));

concat_y = [];
rmsmax = -inf;
for i0=1:numel(allfiles),
    [y,fs] = wavread(fullfile(sdir,'060717',allfiles{i0}));
	rmsmax = max(rmsmax,sqrt(mean(y.^2)));
    concat_y = [concat_y;zeros(.3*fs,1);resample(y(:),16000,fs)];
end
% fs = 16000;
% concat_y = 2*rand(5*fs,1)-1;
% concat_y = rmsmax*concat_y/(sqrt(mean(concat_y.^2)));

[concat_y,fs] = wavread('noise.wav');
concat_y = rmsmax*concat_y/mean((sqrt(mean(concat_y.^2))));
concat_y = concat_y(:,1);
[rmsmax,(sqrt(mean(concat_y.^2)))] 
save concat_data concat_y fs

% setup ui with Repeat and Done
figh = figure('Menu','none','units','normalized','position',[mon_left+0 0 1 1],'userdata',concat_y);
repeat_btn = uicontrol(figh,...
    'units','normalized',...
    'position',[0.1 0.4 0.3 0.1],...
    'Fontsize',14,...
    'Fontweight','bold',...
    'string','Repeat',...
    'callback',sprintf('foo = get(%d,''userdata'');mywavplay(foo,%d,''sync'');',figh,fs));

done_btn = uicontrol(figh,...
    'units','normalized',...
    'position',[0.6 0.4 0.3 0.1],...
    'Fontsize',14,...
    'Fontweight','bold',...
    'string','Done',...
    'callback',sprintf('close(%d);',figh));

uiwait(figh);

level = [];
