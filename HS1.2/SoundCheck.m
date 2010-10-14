function SoundCheck
%SOUNDCHECK  - sound level check for NU6
%
%	usage:  SoundCheck
%
% Use this procedure to set the levels for an NU-6 test:  Within the displayed 
% window, click the left button to output the example utterance as many times
% as necessary to set a volume level appropriate to the subject.  Click the 
% right button to output 10 seconds of speech shaped noise for calibration.
% Exit the procedure by closing the window.
%
% Note:  assumes that "example.wav" and "noise.wav" are available within the same
% directory as this procedure.

% mkt 10/07

% find files
try,
	[example,sr] = wavread('example.wav');
catch,
	error('example.wav not found');
end;

try,
	noise = wavread('noise.wav');
catch,
	error('noise.wav not found');
end;

% construct noise signal 10 secs in length
ns = sr * 10;
while size(noise,1) < ns, noise = [noise ; noise]; end;
noise = noise(1:ns,:);


% set up figure
fh = figure('name','SOUND CHECK', ...
			'numberTitle','off');
pos = get(fh,'position');
width = pos(3); height = pos(4);
bw = 100; bh = 50;
uicontrol(fh, ...
	'position',[width/2-bw-60 height/2 bw bh], ...
	'string','EXAMPLE', ...
	'userData', example, ...
	'Callback',sprintf('sound(get(gcbo,''userData''),%d)',sr));
	
uicontrol(fh, ...
	'position',[width/2+60 height/2 bw bh], ...
	'string','NOISE', ...
	'userData', noise, ...
	'Callback',sprintf('sound(get(gcbo,''userData''),%d)',sr));
