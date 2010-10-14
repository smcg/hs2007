function [results,subjnd] = pi_analyze_data02(basedir,subj,cl_idx)

datadir = '';

ext = {'ea','ie','ssh'};
ep = {'pap-pep','pep-pip','said-shed'};
colors = {'r.-','g.-','b-.','k--','m'};
cl = [colors{cl_idx}];
maxy = 600;
results = [];

for i0=1:numel(ext),
    figure(1);
    subplot(3,1,i0);hold on; if i0==1,title(subj);end
    results(i0,1:3) = plot_label_data(fullfile(basedir,datadir,[subj,ext{i0}]),subj,cl);hold on;
    set(gca,'ylim',[0.75,10.25],'xtick',results(i0,1));
    ylabel(ep{i0});grid on;
    figure(3);
    subplot(3,1,i0);hold on;if i0==1,title(subj);end
    [foo,jnd] = plot_jnd_data(fullfile(basedir,datadir,[subj,ext{i0}]),subj,cl,i0);
    subjnd{i0} = jnd;
    results(i0,3+[1:size(foo,2)]) = foo;
    ylabel(ep{i0});axis tight;
end
hgsave(1,[subj,'_1']);
hgsave(3,[subj,'_3']);

%%
function out = plot_label_data(bd,subj,cl)
fn = dir([bd,filesep,'*',subj,'*.mat']);
fn = fullfile(bd,fn(1).name);
load(fn);
labelfiles = sess_info.stage(1).info.files;
N = numel(labelfiles);
stimidx = str2num(char(regexprep(labelfiles,'\D','')));
[idx,xi,idx2,slope] = get_boundary(fn);
if isempty(idx),
    idx = stimidx(round(end/2));
    uiwait(msgbox(sprintf('Boundary could not be found: %s\nSetting it to: %d',subj,idx),'Warning','modal'))    
end
out = [idx,slope(:)'];

%%
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

of = inline('10./(1+exp(-beta(1)*(x-beta(2))))','beta','x');
beta1 = nlinfit([1:N]',nansum(res1,2),of,[1,N/2]);
beta2 = nlinfit([1:N]',nansum(res2,2),of,[-1,N/2]);

fac = 9/10;
p(1) = plot(stimidx,1+fac*nansum(res1,2),['r','s-']);axis tight;
hold on;
p(2) = plot(stimidx,1+fac*nansum(res2,2),['g','s-']);axis tight;
p(3) = plot(stimidx,1+fac*of(beta1,1:N),'k');axis tight;
p(4) = plot(stimidx,1+fac*of(beta2,1:N),'k');axis tight;
hold off;
set(p,'linewidth',2);

%%
function [out,jnd] = plot_jnd_data(bd,subj,cl,cidx)
fn = dir([bd,filesep,'*',subj,'*.mat']);
fn = fullfile(bd,fn(1).name);
load(fn);
try
    [idx,xi,idx2,slope] = get_boundary(fn);
catch
    idx = [];
end

labelfiles = sess_info.stage(4).info.files;
N = numel(labelfiles);
stimidx = str2num(char(regexprep(labelfiles,'\D','')));
if isempty(idx),
    idx = stimidx(round(end/2));
    uiwait(msgbox(sprintf('Boundary could not be found: %s\nSetting it to: %d',subj,idx),'Warning','modal'))    
end
standard = find(stimidx==idx);

%%
jnd = NaN+zeros(100,6);
out = [];
minerr = inf;
minjnd = inf;
for s0=4:9,
    try
    foo = sess_info.stage(s0).info.jnd;
    foo(foo==0) = [];
    jnd(1:numel(foo),s0-3)  = foo;
    out(1,s0-3) = calc_jnd03(min(sess_info.stage(s0).info.jnd,N-standard));
    [error,jndout] = calc_jnd_jana4(min(sess_info.stage(s0).info.jnd,N-standard));
    if error<minerr,
        minerr = error;
        minjnd = jndout;
    end
    catch
        fprintf('Cannot load session %d\n',s0);
    end
end
out(end+1) = minjnd;
idx = find(any(~isnan(jnd),2));
jnd = jnd(1:idx(end),:);

data = load([bd,filesep,'..',filesep,subj,'_teststat.mat']);
order = [data.teststat.order1;data.teststat.order2;data.teststat.order3];
order = order(4:end,:);
order = [order(find(order(:,1) == cidx+1),2)-3];
ph = plot(jnd(:,order),'.-');
%legend(ph,{'EP1','MID','EP2','BDRY'});
set(ph,'linewidth',2);
legend({'1','2','3','4','5','6'});


%% 
function jnd = calc_jnd(data)
val = 5;
ub = 1+find(diff(sign(diff(data)))==-2);
lb = 1+find(diff(sign(diff(data)))==2);
numrev = min(val,min(numel(ub),numel(lb))-1);
jnd = median(data([ub(max(1,end-numrev):end),lb(max(1,end-numrev):end)]));

%%
function jnd = calc_jnd02(data)
df = diff(data);
[h1,x1] = hist(data(sign(df)<0),logspace(log10(min(data)),log10(max(data)),10));
[h2,x2] = hist(data(sign(df)>0),logspace(log10(min(data)),log10(max(data)),10));
idx = find(h1./[h1+h2]>0.5);
jnd = x1(idx(1));

%%
function jnd = calc_jnd03(data)
ub = 1+find(diff(sign(diff(data)))==-2);
lb = 1+find(diff(sign(diff(data)))==2);
val = 5;
numrev = min(val,min(numel(ub),numel(lb))-1);
jnd = mean(mean(data([lb(max(1,end-numrev):end);ub(max(1,end-numrev):end)])));

%%
function [mini, jnd]=calc_jnd_jana4(data) %least error 

for i=1:length(data)-15 %vary beginning of segment
    candidates=data(i:(i+14)); %take 15 trials
    mean_cand=mean(candidates); %calculate mean over those trials
    for j=1:length(candidates) 
        error_cand(j)=(mean_cand-candidates(j))^2; %squared distance between each of the 15 points and the mean
    end
    error(i)=mean(error_cand); %mean over those distances
    clear error_cand
end
[mini, ind]=min(error); %take 15-trial sequence with smallest squared distance
jnd=mean(data(ind:ind+14));
