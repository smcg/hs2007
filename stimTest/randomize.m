function idx = randomize(idx)

idx = idx(:);
idx = idx(randperm(length(idx)));
didx = diff(idx);
push = 1;
%df = [];
count  = 0;
while (any(didx == 0) & (count<1000))
    idxold = idx;
    ix1 = find(didx == 0);
    ix1 = ix1(1);
%     if push
%         idx = idx([1:ix1,ix1+2:end,ix1+1],1);
%     else
%         idx = idx([ix1+1,1:ix1,ix1+2:end],1);
%     end
    randidx = randperm(length(idx));randidx = randidx(1);
    idx([randidx,ix1+1]) = idx([ix1+1,randidx]);
    didx = diff(idx);
    push = mod(push+1,2);
    %df(end+1) = sqrt(sum((idx-idxold).^2));
    count = count+1;
end
if count == 1000,
    warning('exceeded iterations');
end
