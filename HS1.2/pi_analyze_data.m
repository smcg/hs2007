function pi_analyze_data(basedir,subj,cl_idx)

ext = {'dt','ea','ie','ssh'};
ep = {'doe-toe','pap-pep','pep-pip','said-shed'};
colors = {'r:','g.-','b-.','k--','m'};
%subj = 'M05';
cl = [colors{cl_idx}];%,'.-'];

for i0=1:numel(ext),
    figure(1);
    subplot(4,1,i0);hold on;
    plot_label_data(fullfile(basedir,'DATA',[subj,ext{i0}]),subj,cl);
    ylabel(ep{i0});grid on;
    figure(2);
    subplot(4,1,i0);hold on;
    plot_rate_data(fullfile(basedir,'DATA',[subj,ext{i0}]),subj,cl);
    ylabel(ep{i0});grid on;
    figure(3);
    subplot(4,1,i0);hold on;
    plot_jnd_data(fullfile(basedir,'DATA',[subj,ext{i0}]),subj,cl);
    ylabel(ep{i0});axis tight;
    set(gca,'ylim',[0,250]);
end

%%
function plot_label_data(bd,subj,cl)
fn = dir([bd,filesep,'*',subj,'*.mat']);
fn = fullfile(bd,fn(1).name);
load(fn);
%%
stim = sess_info.stage(1).info.order;
a = sess_info.stage(1).resp;
a = char(a);
nstim = numel(unique(stim));
res = NaN*ones(nstim,length(a));
idx = find((a(:,1) == 'a'));
res((idx-1)*nstim+stim(idx)) = 1; %str2num(a(idx,2));
idx = find((a(:,1) == 's'));
res((idx-1)*nstim+stim(idx)) = -1; %str2num(a(idx,2));

%%
res1 = NaN*ones(size(res));
res2 = NaN*ones(size(res));
res1(res<0) = -res(res<0);
res2(res>0) = res(res>0);
p(1) = plot(1:nstim,nansum(res1,2),cl);axis tight;
hold on;
p(2) = plot(1:nstim,nansum(res2,2),cl);axis tight;
hold off;
set(p,'linewidth',2);

%%
function plot_jnd_data(bd,subj,cl)
fn = dir([bd,filesep,'*',subj,'*.mat']);
fn = fullfile(bd,fn(1).name);
load(fn);
%%
jnd = NaN+zeros(100,4);
for s0=4:7,
    try
    foo = sess_info.stage(s0).info.jnd;
    foo(foo==0) = []
    jnd(1:numel(foo),s0-3)  = foo;
    catch
    end
end
idx = find(any(~isnan(jnd),2));
jnd = jnd(1:idx(end),:);
ph = plot(jnd,'.-');
legend(ph,{'EP1','MID','EP2','BDRY'});
set(ph,'linewidth',2);

%%
function plot_rate_data(bd,subj,cl)
fn = dir([bd,filesep,'*',subj,'*.mat']);
fn = fullfile(bd,fn(1).name);
load(fn);
%%
stim1 = sess_info.stage(2).info.order;
a = sess_info.stage(2).resp;
a = char(a);
a = str2num(a(:,1));

stim2 = sess_info.stage(3).info.order;
b = sess_info.stage(3).resp;
b = char(b);
b = str2num(b(:,1));

nstim = 11; %numel(unique(stim1));

res1 = NaN*ones(nstim,length(a));
res1(nstim*([1:numel(a)]'-1) + stim1) = a;
res2 = NaN*ones(nstim,length(b));
res2(nstim*([1:numel(b)]'-1) + stim2) = b;

p(1) = plot(1:nstim,nanmean(res1,2),cl);axis tight;
plot(res1,'x-');
hold on;
p(2) = plot(1:nstim,nanmean(res2,2),cl);axis tight;
plot(res2,'o-');
hold off;
set(p,'linewidth',2);
