function run_test_subj_percep_final(subjid)

global sdir mon_left stimdate

subj_order = 1;

% subjid     = 'X00'; subj_order = 1;
% subjid     = 'T05'; subj_order = 2;
% day        = 2; %Which day

%%
if size(get(0,'MonitorPosition'),1) == 1,
    mon_left = 0;
elseif size(get(0,'MonitorPosition'),1) == 2,
    mon_left = -1;
end
figure('Menu','none','units','normalized','position',[mon_left+0 0 1 1],'color','k');
% basedir = pwd; %uigetdir(pwd,'Select a Directory to store the results');
% sdir = fullfile(pwd,'STIMULI'); %uigetdir(pwd,'Select the directory containing the stimuli [the STIMULI folder]');
basedir = pwd; %uigetdir(pwd,'Select a Directory to store the results');
[pn,fn] = fileparts(which(mfilename));
sdir = fullfile(pn,'STIMULI') %uigetdir(pwd,'Select the directory containing the stimuli [the STIMULI folder]');
%stimdate = '060717';
stimdate = '080830';

%basedir = uigetdir(pwd,'Select a Directory to store the results');
%sdir = uigetdir(pwd,'Select the directory containing the stimuli [the STIMULI folder]');

if ~exist(fullfile(basedir,'DATA'),'dir'),
    mkdir(fullfile(basedir,'DATA'));
end

%%
stage1 = repmat([4,5,6]',1,3);
stage2 = repmat([7,8,9]',1,3);
set    = repmat([2,3,4],3,1);
day1 = [set(:),stage1(:)];
day2 = [set(:),stage2(:)];

teststatfile = fullfile(basedir,'DATA',sprintf('%s_teststat.mat',subjid));
if ~exist(teststatfile),
    rand('state',sum(100*clock));
	order1 = [[2,3,4]',ones(3,1)];
	randorder = blockrandom([1,2,3;4,5,6;7,8,9]);
	order2 = day1(randorder(:),:);
	randorder = blockrandom([1,2,3;4,5,6;7,8,9]);
	order3 = day2(randorder(:),:);

    teststat.subjid = subjid;
    teststat.subj_order = subj_order;
    teststat.count = 1;
    teststat.day   = 1;
    teststat.order1=order1;
    teststat.order2=order2;
    teststat.order3=order3;
    teststat.SPLlevel = [];
    save(teststatfile);
else,
    load(teststatfile);
    order1 = teststat.order1;
    order2 = teststat.order2;
    order3 = teststat.order3;
end

% teststat.SPLlevel = pi_check_level();

msg_str = pi_messagestr;
msg = sprintf('%s\n\n%s\n\n%s',sprintf(msg_str.expt),sprintf(msg_str.testsession,teststat.day),msg_str.cont);
uiwait(mymsgbox(msg,'','modal'));

if teststat.day==1,
%%
    for i0=teststat.count:size(order1,1),
        figure('Menu','none','units','normalized','position',[mon_left+0 0 1 1],'color','k');
        switch(order1(i0,1)),
            case 1,
                run_exp_cont([subjid,'dt'],{'doe','toe'},1,basedir,order1(i0,2));
            case 2,
                run_exp_cont([subjid,'ea'],{'pap','pep'},2,basedir,order1(i0,2));
            case 3,
                run_exp_cont([subjid,'ie'],{'pep','pip'},3,basedir,order1(i0,2));
            case 4,
                run_exp_cont([subjid,'ssh'],{'said','shed'},4,basedir,order1(i0,2));
            case 5,
                run_exp_cont([subjid,'dur'],{'pup','pup'},5,basedir,order1(i0,2));
        end
        teststat.count =  teststat.count + 1;
        save(teststatfile,'teststat');
        uiwait(mymsgbox(sprintf(msg_str.finishedtest,teststat.count-1,size(order1,1)),'','modal'));
        if teststat.count-1 == size(order1,1),
            uiwait(mymsgbox('Thank you','','modal'));
        end
        closereq;close all;
    end
    teststat.day = 2;
    teststat.count = 1;
    save(teststatfile,'teststat');
elseif teststat.day==2,
%%
    for i0=teststat.count:size(order2,1),
        figure('Menu','none','units','normalized','position',[mon_left+0 0 1 1],'color','k');
        switch(order2(i0,1)),
            case 1,
                run_exp_cont([subjid,'dt'],{'doe','toe'},1,basedir,order2(i0,2));
            case 2,
                run_exp_cont([subjid,'ea'],{'pap','pep'},2,basedir,order2(i0,2));
            case 3,
                run_exp_cont([subjid,'ie'],{'pep','pip'},3,basedir,order2(i0,2));
            case 4,
                run_exp_cont([subjid,'ssh'],{'said','shed'},4,basedir,order2(i0,2));
            case 5,
                run_exp_cont([subjid,'dur'],{'pup','pup'},5,basedir,order2(i0,2));
        end
        teststat.count =  teststat.count + 1;
        save(teststatfile,'teststat');
        uiwait(mymsgbox(sprintf(msg_str.finishedtest,teststat.count-1,size(order2,1)),'','modal'));
        if teststat.count-1 == 5,
            uiwait(mymsgbox('Thank you','','modal'));
			closereq;close all;
			return;
        end
        if teststat.count-1 == size(order2,1),
            uiwait(mymsgbox('Thank you','','modal'));
        end
        closereq;close all;
    end
    teststat.day = 3;
    teststat.count = 1;
    save(teststatfile,'teststat');
elseif teststat.day==3,
%%
    for i0=teststat.count:size(order3,1),
        figure('Menu','none','units','normalized','position',[mon_left+0 0 1 1],'color','k');
        switch(order3(i0,1)),
            case 1,
                run_exp_cont([subjid,'dt'],{'doe','toe'},1,basedir,order3(i0,2));
            case 2,
                run_exp_cont([subjid,'ea'],{'pap','pep'},2,basedir,order3(i0,2));
            case 3,
                run_exp_cont([subjid,'ie'],{'pep','pip'},3,basedir,order3(i0,2));
            case 4,
                run_exp_cont([subjid,'ssh'],{'said','shed'},4,basedir,order3(i0,2));
            case 5,
                run_exp_cont([subjid,'dur'],{'pup','pup'},5,basedir,order3(i0,2));
        end
        teststat.count =  teststat.count + 1;
        save(teststatfile,'teststat');
        uiwait(mymsgbox(sprintf(msg_str.finishedtest,teststat.count-1,size(order3,1)),'','modal'));
        if teststat.count-1 == 5,
            uiwait(mymsgbox('Thank you','','modal'));
			closereq;close all;
			return;
        end
        if teststat.count-1 == size(order3,1),
            uiwait(mymsgbox('Thank you','','modal'));
        end
        closereq;close all;
    end
end

% pi_analyze_data(basedir,'M03',1);

%%
% pi_analyze_data('M04',1);
% pi_analyze_data('M05',2);
% pi_analyze_data('M06',3);
% pi_analyze_data('M07',4);