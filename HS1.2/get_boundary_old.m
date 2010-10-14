function [idx,xi,idx2] = get_boundary(fn,bplot);

% idx = 500;
% xi = 6;
% return;

if nargin<2,
    bplot = 0;
end
load(fn);
%%
labelfiles = sess_info.stage(1).info.files;
N = numel(labelfiles);
fileidx = str2num(char(regexprep(labelfiles,'\D','')));
start_idx = fileidx(1);
end_idx = fileidx(end);
stim = sess_info.stage(1).info.order;
a = sess_info.stage(1).resp;
a = char(a);
nstim = numel(unique(stim));
res = NaN*ones(nstim,length(a));
idx = find((a(:,1) == '1'));
res((idx-1)*nstim+stim(idx)) = 1; %str2num(a(idx,2));
idx = find((a(:,1) == '2'));
res((idx-1)*nstim+stim(idx)) = -1; %str2num(a(idx,2));

%%
res1 = NaN*ones(size(res));
res2 = NaN*ones(size(res));
res1(res<0) = -res(res<0);
res2(res>0) = res(res>0);

%%%
of = inline('1./(1+exp(-beta(1)*(x-beta(2))))','beta','x')
beta1 = nlinfit([1:N]',0.1*nansum(res1,2),of,[1,N/2])
beta2 = nlinfit([1:N]',0.1*nansum(res2,2),of,[-1,N/2])
%%%

% [xi,yi] = polyxpoly(1:N,nansum(res1,2),1:N,nansum(res2,2),'unique');
[xi,yi] = polyxpoly(1:N,of(beta1,1:N),1:N,of(beta2,1:N),'unique');
idx = max(start_idx,min(end_idx,start_idx+round((xi-1)/(N-1)*(end_idx-start_idx))));
idx2 = fileidx(round(xi));
if bplot
    p(1) = plot(1:nstim,nansum(res1,2),'r');axis tight;
    hold on;
    p(2) = plot(1:nstim,nansum(res2,2));axis tight;
    hold off;
    set(p,'linewidth',2);
end

function num = sub_string2num(str)
num = str2num(fliplr(strtok(fliplr(strtok(str,'.')),'_')));