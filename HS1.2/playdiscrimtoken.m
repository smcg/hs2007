function playdiscrimtoken(info)

global sdir stimdate
N = numel(info.files);
% straddle the test point if the test point is not at the boundaries
% ceil and floor temporary to deal with current stimulus set
info.jnd = round(info.jnd);
info.standard = round(info.standard);
if info.standard == 1
    stim1 = info.standard;
    stim2 = min(N,info.standard+2*info.jnd(end));
elseif info.standard == N
    stim1 = info.standard;
    stim2 = max(1,info.standard-2*info.jnd(end));
else,
    stim1 = max(1,info.standard-info.jnd(end));
    stim2 = min(N,info.standard+info.jnd(end));
end

if rand<0.5,
    fname_s = info.files{stim1};
    fname_t = info.files{stim2};
else
    fname_s = info.files{stim2};
    fname_t = info.files{stim1};
end

[s,fs] = wavread(fullfile(sdir,stimdate,fname_s));
t = wavread(fullfile(sdir,stimdate,fname_t));
% t1 = 1756:3313;f=2187;
% [b,a] = butter(21,f/(fs/2),'low');
% 
% s(t1) = filtfilt(b,a,s(t1));
% foo = s;
% foo(t1) = filtfilt(b,a,t(t1));
% t = foo;
% s = filtfilt(b,a,s(t1));
% t = filtfilt(b,a,t(t1));


sil_wind = round(50*1e-3*fs);
iii = zeros(round(info.iii*fs),1);
if info.play_noise,
    rms_s = sqrt(mean(s.^2));
    noise = (rand(round(info.iii*fs)-2*sil_wind,1)-0.5);
    rms_n = sqrt(mean(noise.^2));
    noise = noise/rms_n*0.01*rms_s;
    iii = [zeros(sil_wind,1);noise;zeros(sil_wind,1)];
end

fprintf('Playing sound: %s,%s\n',fname_s,fname_t);

if info.pos==2,
    y = [s(:);iii;t(:);iii;s(:);iii;s(:)];
else,
    y = [s(:);iii;s(:);iii;t(:);iii;s(:)];
end
    
mywavplay(y,fs);
