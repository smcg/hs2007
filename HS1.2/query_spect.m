sdir = uigetdir;
fl = strcat(sdir,filesep,labelfiles);


idx = repmat(round(linspace(1,1000,11)),11,1)+repmat([-5:5]',1,11);
idx = idx(:);
idx(idx<1 | idx>1000) = [];

%%
N = 512;
for i0=idx(:)',
[y,fs] = wavread(fl{i0});
fsig = sat_window(sat_frame4(y(:),10,15,fs),'hamming');
spc = sat_spectra(fsig,N);
spch(:,find(i0==idx)) = 20*log10(mean(abs(spc(:,5:15)),2)+eps);
end
data = NaN+zeros(N,idx(end));
data(:,idx) = spch;
figure;imagesc(data);axis xy;
figure;imagesc(spch);axis xy;

%%
% for i0 = 1:4, 
%     F = linspace(0,fs/2,size(spch,1));	% frequency bins
% p = p(1:upb);								% power (1-based)
% np = p ./ sum(p);							% normalized power
% np = np(2:end);								% drop DC
% L1 = sum(F .* np);							% moments
% FL = F - L1;
% L2 = sum(FL.^2 .* np);
% L3 = sum(FL.^3 .* np);
% L4 = sum(FL.^4 .* np);
% skew = L3/L2^1.5;
% kurt = L4/L2^2 - 3;
% 
%     if i0==1,
%         mm(i0) = nanmean(spch);
%     else
%         mm(i0) = mean((a-mean(a)).^i0); 
%     end
% end


%%
% figure;
for gp=1:11,
    idxgp = find(idx<100*(gp-1)+50 & idx>100*(gp-1)-50);
    idx2 = idxgp(1:5:end);
    %subplot(3,4,gp);
    figure;
    p = plot(linspace(0,8000,N),spch(:,idx2));axis tight;
    set(p,'linewidth',2);
    legend(p,num2str(idx(idx2)));
end