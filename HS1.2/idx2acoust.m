function out = idx2acoust(data,val,options)
% options: [space bdist] 
% space: 0 - Hz, 1 - mels
% bdist: 0 - nodist, 1 -dist

if nargin<3,
    options = [0 0];
end

idx = data(:,1);
acoustdata = data(:,5:7);
if options(1) == 1,
    acoustdata = frq2mel(data(:,5:7));
end

% F0 = 165;
% if bmiller,
%     acoustdata = frq2miller(data(:,5:7),F0);
% end

fmtidx = 1:3;
acoustdata(idx,1:numel(fmtidx)) = acoustdata(:,fmtidx);
acoustdata = acoustdata(:,1:numel(fmtidx));

index = 2:8;

upbound = round(val(1)+val(index)/2);
lowbound = round(val(1)-val(index)/2);
if any(lowbound<0)
    warning('NOTE: subject hit lower bound');
    lowbound = max(1,lowbound);
end
if any(upbound>length(acoustdata))
    warning('NOTE: subject hit upper bound');
    upbound = min(length(acoustdata),upbound);
end

if options(2) == 1,
    out(1) = sqrt(sum(acoustdata(round(val(1)),:).^2));
    out(index) = sqrt(sum((acoustdata(upbound,:)'-acoustdata(lowbound,:)').^2));
else
    out(:,1) = repmat(acoustdata(round(val(1)),:),1,2)';
    out(:,index) = [acoustdata(upbound,:),acoustdata(lowbound,:)]';
    %[acoustdata(upbound,:),acoustdata(lowbound,:)]
end

% if bmiller
%     out = 1000*out;
% end

