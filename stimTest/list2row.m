% function list2row(fname)

fid = fopen(fname);

while 1,
    tline = fgetl(fid);
    if ~ischar(tline), break, end
    foo = tline;
    idx = find(foo==' ');
    if isempty(idx),
        fprintf('%s $1 %s\n',tline,tline);
    else
        foo(idx) = [];
        fprintf('%s "%s" $1 %s\n',foo,tline,tline);
    end
end
fclose(fid);