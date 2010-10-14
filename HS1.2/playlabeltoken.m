function playlabeltoken(info)

global sdir stimdate

if info.token<0,
    fname = info.files{info.porder(abs(info.token))};
else
    fname = info.files{info.order(info.token)};
end

%load(fname);
[y,fs] = wavread(fullfile(sdir,stimdate,fname));
fprintf('Playing sound: %s\n',fname);
mywavplay(y,fs);
