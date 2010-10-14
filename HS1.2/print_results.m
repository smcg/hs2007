function print_results(results,options)
% usage: print_results(results,options)
% parameters:
%   results: returned by pi_collate_data
%   options: two-element vector
%     [space bdist] 
%     space: 0 - Hz, 1 - mels
%     bdist: 0 - nodist, 1 -dist

switch options(1)
    case 0,
        fprintf('Results in Hz\n');
    case 1,
        fprintf('Results in mels\n');
    otherwise,
        error('unknown parameter for space');
end
switch options(2)
    case 0,
        fprintf('Results are in formant space\n');
    case 1,
        fprintf('Results are in euclidean distance\n');
    otherwise,
        error('unknown parameter for bdist');
end

%% read in the index to acoustic mapping tables
load('mapping_C23','data2','data3');
%data2 = xlsread(sprintf('mapping_C%d.csv',2));
%data3 = xlsread(sprintf('mapping_C%d.csv',3));

%%
title = {'Subject','Continuum','DiscriminationBoundary','Slope1','Slope2','JND1','JND2','JND3','JND4','JND5','JND6','MINJND'};
% frq2mel = inline('x;','x');
fn = fieldnames(results);
foo2 = [];
jndidx = 4:10;
for f0=1:numel(fn),
    if size(results.(fn{f0}),2) == jndidx(end),
        % vowel pap-pep
        foo = results.(fn{f0})(1,:);
        foo(jndidx) = 2*foo(jndidx);
        foo = [2,foo];
        acoust_vals = idx2acoust(data2,foo([2,1+jndidx]),options);
        if size(acoust_vals,1)> 1,
            N = size(acoust_vals,1);
            foo = repmat(foo,N,1);
        end
        foo(:,[2,1+jndidx]) = acoust_vals;
        if options(2) == 1,
            fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        else
            for j=1:size(foo,1)/2,            
                fmts = [foo(j,:),foo(size(foo,1)/2+j,(1+jndidx(1)):end)];
                fprintf('%s,F%d,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},mod(j-1,3)+1,fmts(:)');
            end
        end
        %foo2(end+1,:) = foo;
        
        % vowel pep-pip
        foo = results.(fn{f0})(2,:);
        foo(jndidx) = 2*foo(jndidx);
        foo = [3,foo];
        acoust_vals = idx2acoust(data3,foo([2,1+jndidx]),options);
        if size(acoust_vals,1)> 1,
            N = size(acoust_vals,1);
            foo = repmat(foo,N,1);
        end
        foo(:,[2,1+jndidx]) = acoust_vals;
        if options(2) == 1,
            fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        else
            for j=1:size(foo,1)/2,            
                fmts = [foo(j,:),foo(size(foo,1)/2+j,(1+jndidx(1)):end)];
                fprintf('%s,F%d,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},mod(j-1,3)+1,fmts(:)');
            end
        end
        %foo2(end+1,:) = foo;

        % sibilants
        foo = [];
%         foo(2:3) = results.(fn{f0})(4,2:3);
%         foo(4:7) = diff(frq2mel(fy(p,repmat(results.addp(fn{f0})(4,1),2,4)+[results.(fn{f0})(4,4:7);-results.(fn{f0})(4,4:7)])));
%         foo(1) = frq2mel(fy(p,results.(fn{f0})(4,1)));
        foo = results.(fn{f0})(3,:);
        foo(jndidx) = 2*foo(jndidx);
        foo = [4,foo];
        if options(2) == 1
            fprintf('%s,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        else
            fprintf('%s,XX,%d,%.2f,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f,%.2f\n',fn{f0},foo);
        end
            
        %        fprintf('%d,%.4f,%.4f,%.2f,%.2f,%.2f,%.2f\n',foo);
        %foo2(end+1,:) = foo;
    end
end   
