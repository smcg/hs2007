function idx = blockrandom(idx)
[Nx,Ny] = size(idx);
count = 0;
dv = abs(idx(end,1:Ny-1)-idx(1,2:Ny))==0;
while (count == 0) || ((count<1000) && any(dv))
    for i0=1:size(idx,2),
        idx(:,i0) = idx(randperm(Nx)',i0);
    end
    dv = abs(idx(end,1:Ny-1)-idx(1,2:Ny))==0;
    count = count + 1;
end
%count,dv