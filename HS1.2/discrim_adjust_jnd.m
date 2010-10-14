function info = discrim_adjust_jnd(info,resp)

correct = resp(:,1)==resp(:,2);

method = 2;
switch(method)
    case '1'
        % 2up 1down
        if correct(end)==0,
            info.jnd(end+1) = info.jnd(end)+info.stepsize;
        end
        if numel(correct)>1 & sum(correct(end-1:end))==2,
            info.jnd(end+1) = info.jnd(end)-info.stepsize;
        end
        info.jnd(end) = max(info.jnd(end),info.stepsize);
    case 2,
        % weighted up-dwon (Kaernbach 1991)
        % for 75% correct
        info.stepsize = ceil(info.jnd(end)/10);
        if correct(end)==0,
            info.jnd(end+1) = info.jnd(end)+3*info.stepsize;
        else
            info.jnd(end+1) = info.jnd(end)-info.stepsize;
        end
    case 3,
        % quicksort for jnd
        if correct(end)==0,
            info.jnd(end+1) = min(9*info.jnd(end),size(info.files,1));
        else
            info.jnd(end+1) = max(info.jnd(end)/2,1);
        end
    case 4,
        
    otherwise,
end
info.jnd = max(1,round(info.jnd));

% determine number of reversals
a = sign(diff(info.jnd));
a(a==0)=[];
if ~isempty(a),
    info.numreversals = sum(diff(a)~=0);
else,
    info.numreversals = 0;
end
