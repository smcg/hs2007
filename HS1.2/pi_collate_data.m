function results = pi_collate_data(basedatadir,subjects)
% function pi_collate_data(basedatadir,subjects)
%  basedatadir = directory containing the data. This will typically be the
%           location of the DATA folder. e.g.,
%           \\killick1\NT_Data\PH_DATA\PerceptualTesting\DATA
%  subjects    = list of subjects in the above mentioned data directory
%            e.g., {'PIUF03','PIUM01'}
%  e.g., 
%  pi_collate_data('\\killick1\NT_Data\PH_DATA\PerceptualTesting\DATA', {'PIUF03','PIUM01'}); 
%

% basedir = '\\killick1\NT_Data\PH_DATA\PerceptualTesting';
% basedir = 'C:\RESEARCH\EXPERIMENTS\HS07\ACUITY\DATA';
% basedir = fullfile(pwd,'DATA');
% subjects = {'PIUF03'};
basedir = basedatadir;
for s0=subjects,
    close all;
    if 1,
        [results.(s0{:}),jnddata.(s0{:})] = pi_analyze_data02(basedir,s0{:},1);
    else
        close all
        subj = s0{:};
        open(sprintf('%s_1.fig',s0{:}));
        %     subplot(4,1,1);title(s0{:});
        %set(gcf,'Position',[1,40,800,1100]);
        open(sprintf('%s_3.fig',s0{:}));
        %     subplot(5,1,1);title(s0{:});
        %set(gcf,'Position',[801,40,800,1100]);
        embed
%         hgsave(1,[subj,'_1']);
%         hgsave(2,[subj,'_3']);
%         print(1,'-dpsc','results.ps','-append');
%         print(2,'-dpsc','results.ps','-append');
        set(gcf,'units','normalized','Position',[0 0 1 1],'PaperOrientation','landscape','PaperUnits','normalized','PaperPosition',[0.1 0.1 0.9 0.9]);
        print(3,'-dpsc','results2.ps','-append');
    end
end

return;

%%
title = {'Subject','Continuum','DiscriminationBoundary','Slope1','Slope2','JND1','JND2','JND3','JND4'};
% frq2mel = inline('x;','x');
fn = fieldnames(results);
foo2 = [];
for f0=1:numel(fn),
    if size(results.(fn{f0}),2) == 7,
        % vowel pap-pep
        foo = results.(fn{f0})(1,:);
        foo(4:7) = 2*foo(4:7);
        foo = [2,foo];
        foo([2,5:8]) = idx2acoust(2,foo([2,5:8]));
        fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        foo2(end+1,:) = foo;
        
        % vowel pep-pip
        foo = results.(fn{f0})(2,:);
        foo(4:7) = 2*foo(4:7);
        foo = [3,foo];
        foo([2,5:8]) = idx2acoust(3,foo([2,5:8]));
        fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        foo2(end+1,:) = foo;

        % sibilants
        foo = [];
%         foo(2:3) = results.(fn{f0})(4,2:3);
%         foo(4:7) = diff(frq2mel(fy(p,repmat(results.(fn{f0})(4,1),2,4)+[results.(fn{f0})(4,4:7);-results.(fn{f0})(4,4:7)])));
%         foo(1) = frq2mel(fy(p,results.(fn{f0})(4,1)));
        foo = results.(fn{f0})(3,:);
        foo(4:7) = 2*foo(4:7);
        foo = [4,foo];
        fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        %        fprintf('%d,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f\n',foo);
        foo2(end+1,:) = foo;

    end
end   


%% old sibilant map

p(1) = -3.0735e-014
p(2) = 9.3006e-011
p(3) = -7.4175e-008
p(4) = -2.4239e-005
p(5) = 0.055415
p(6) = -25.457
p(7) = 9679.1

fy = inline('p(1)*x.^6 + p(2)*x.^5 + p(3)*x.^4 + p(4)*x.^3 + p(5)*x.^2 + p(6)*x + p(7)','p','x'); 
