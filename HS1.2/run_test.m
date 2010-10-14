function run_test

global sdir

subjid = 'M03';
uiwait(msgbox('Start Perceptual test','Experiment Setup','modal'));
basedir = uigetdir(pwd,'Select a Directory to store the results');
sdir = uigetdir(pwd,'Select the directory containing the stimuli [the STIMULI folder]');

rand('state',25);
for i0=randperm(4),
    switch(i0),
        case 1,
            uiwait(msgbox('Starting continuum: doe-toe ','Experiment Setup','modal'));
            run_exp_cont([subjid,'dt'],{'doe','toe'},1,basedir);
            closereq;
        case 2,
            uiwait(msgbox('Starting continuum: pap-pep ','Experiment Setup','modal'));
            run_exp_cont([subjid,'ea'],{'pap','pep'},2,basedir);
            closereq;
        case 3,
            uiwait(msgbox('Starting continuum: pep-pip ','Experiment Setup','modal'));
            run_exp_cont([subjid,'ie'],{'pep','pip'},3,basedir);
            closereq;
        case 4,
            uiwait(msgbox('Starting continuum: said-shed ','Experiment Setup','modal'));
            run_exp_cont([subjid,'ssh'],{'said','shed'},4,basedir);
            uiwait(msgbox('Thank you','Experiment Setup','modal'));
    end
    closereq;close all;
end

% pi_analyze_data(basedir,'M03',1);

%%
% pi_analyze_data('M04',1);
% pi_analyze_data('M05',2);
% pi_analyze_data('M06',3);
% pi_analyze_data('M07',4);