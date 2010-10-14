function b = blockrandom(b)
% b is matrix of indices where each column is randomized separately
% and no two neighboring columns are allowed to have the same permutation.
% Also the last element of the one column and the first element of the
% following column are not allowed to be the same.

done = 0;
while ~done,
    for i0=1:size(b,2),
        b(:,i0) = b(randperm(size(b,1)),i0);
    end

    done = all((b(end,1:end-1)-b(1,2:end))~=0) & ~any(sum(abs(diff(b,1,2)))==0);
end