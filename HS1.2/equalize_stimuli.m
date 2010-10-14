OLDSTIMDIR = 'E:\Satra\HS1.2\STIMULI\060717\';
NEWSTIMDIR = 'E:\Satra\HS1.2\STIMULI\080830\';

folders = {'pappep','peppip','saidshed'};

for f0=1:numel(folders),
    oldfolder = fullfile(OLDSTIMDIR,folders{f0});
    newfolder = fullfile(NEWSTIMDIR,folders{f0});
    mkdir(newfolder);
    fl = gfl(fullfile(oldfolder,'*.wav'),1);
    [ref,ref_fs] = wavread(fullfile(oldfolder,fl{end}));
    for y0=1:numel(fl),
        infile = fullfile(oldfolder,fl{y0});
        outfile = fullfile(newfolder,fl{y0});
        [in,in_fs] = wavread(infile);
        [out,pk1,pk2] = peak_equalize(ref,ref_fs,in,in_fs);
        wavwrite(out,in_fs,outfile);
        fprintf('%s->%s\n',infile,outfile);
    end
end