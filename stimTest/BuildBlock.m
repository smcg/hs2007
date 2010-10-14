function [newoffset,strout] = BuildBlock2(tokenfile,lstfile,block,repOffset,repCount,permfcn)
%BUILDBLOCK  - expands tokens into templates for use in Maggie stimulus lists
%
%	usage:  BuildBlock(TOKENFILE,LSTFILE,BLOCK,REPCOUNT,PERMFCN)
%
% TOKENFILE - input token file or cellstr array (default ''; prompts if empty)
% LSTFILE   - expanded output LST file (default ''; echoed to command window if empty)
% BLOCK     - string appended to the token name for each acquisition trial (default '')
% REPOFFSET - determines the starting offset for incrementing the repetition number (default 0)  
% REPCOUNT  - number of times each stimulus is to be repeated (default 1)
% PERMFCN:  - function that accepts a vector of indices and returns its permutation (default '')
% 
% Optionally returns
% NEWOFFSET - the value of REPOFFSET if this block is called again
% STROUT    - expanded output as a cellstr array (overrides LSTFILE)
%
% TOKENFILE format:
%
% ! Comment (blank lines and text following "!")
% #<TCODE<IDX>> <TEMPLATE>                                              ! TEMPLATE line
% <TOKEN> <PROMPT> (TREP) (#<TCODE<IDX>> (ARG1 ... ARGn)) (#<TCODE<IDX>> (ARG1 ... ARGn))  ! TOKEN line 
%
% TEMPLATES are used to define carrier contexts, display formatting, and
% allow bundling of multiple screen displays/token (e.g., an instructional
% DUMMY trial preceding data acq.) The "#T" TCODE sequence defines a data
% acquisition template that generates a token name, while "#D" and "#P"
% generate DUMMY and PAUSE tokens respectively.  Each of these may be
% followed by an indexation integer IDX for subsequent reference in the
% TOKEN lines (i.e., #T2 maps to template 2).  Within each template the
% "@<N>" sequence is an argument place-holder that during expansion is
% replaced by the Nth argument specified with each token. "@0" is  replaced
% by the PROMPT, and "@@" with the "@" character. If PROMPT is empty,
% PROMPT is set to TOKEN. TOKEN is used to create the filename. 
%
% All TOKENS are expanded REPCOUNT times.  Tokens that do not refer to any
% template are passed through as is.  Tokens may reference an arbitrary
% number of templates, with the specification order defining the ultimate
% bundled presentation order.  Each template reference must be followed by
% the appropriate number of arguments for instantiation: e.g., if
% referenced template #T1 includes "@1" and "@2" then each token must
% specify two arguments ("@0" is always the token name itself).  The
% optional TREP parameter is an optional token-specific multiplier, such
% that the resulting output count for that token is TREP*REPCOUNT.
%
% Adds a $$$ placeholder for a trial count that is replaced by
% BuildStimList to reflect the actual number.
%
% SAMPLE TOKENFILE input
% 
%! repeat "heed" 3x for each repetition of the others; its color & duration by argument
%#T1 \d@2 @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
%heed 3 #T1 heed AF0000 1.5
%! template for remaining tokens:  set color by argument
%#T2 @0 \e<ROW=-2><COL=4>Say <TXTCOLOR=@2>@1<TXTCOLOR=000000> for me
%hid  #T2 hid 0000AF
%head #T2 head 0000AF
%
%! bundle preceding instructional DUMMY token
%#D @0 \e<ROW=2><HCEN>Speak when color changes</HCEN><ROW=-2><TXTCOLOR=@2><HCEN>@1</HCEN><TXTCOLOR=000000>
%#T @0 acquisition \e<ROW=-2><TXTCOLOR=@2><HCEN>@1</HCEN><TXTCOLOR=000000>
%atu #D atu 0000AF #T atu 00AF00
%
% see also BUILDSTIMLIST

% [3DEC05-SG] Updated help file to reflect the changes
% [2DEC05-SG] Updated file, to differentiate between filename and prompt.
% Also adds a $$$ placeholder for item-count.
% mkt 12/04 minor tweaks

if nargin<1,
    tokenfile = '';
end
if nargin<2,
    lstfile = '';
end
if nargin<3
    block = '';
end
if nargin<4 | isempty(repOffset),
    repOffset = 1;
end
if nargin<5 | isempty(repCount),
    repCount = 1;
end
if nargin<6,
    permfcn = '';
end

% Get tokenfile if not provided.
if isempty(tokenfile),
    [fn, pn] = uigetfile('*.*', 'Select token sequence list');
    if fn == 0, return; end;
    fileName = fullfile(pn,fn);
end

% Read file
if iscell(tokenfile),
	token_data = tokenfile;
else,
    token_data = textread(tokenfile,'%s','delimiter','\n');
end

% Remove empty lines
token_data = token_data(~strcmp('',token_data));
% Remove comments
token_data = token_data(~strncmp('!',token_data,1));

% Get pass through items and remove from main list
passthrough = token_data(strncmp('%',token_data,1));
token_data = token_data(~strncmp('%',token_data,1));
if ~isempty(passthrough),
    passthrough = strtok(passthrough,'%');
end

% Parse token
% Step 1.
% Read #-ed lines
hash_idx = find(strncmp('#',token_data,1));
hash_list = [];
for h0=1:length(hash_idx),
    hash_str = token_data{hash_idx(h0)};

    switch hash_str(1:2),
        case {'#T','#P','#D'}
            [hashkey,hashval]  = strtok(hash_str,' ');
            hash_list(h0).key  = strtok(hashkey);
            hash_list(h0).val  = hashval;
            hash_list(h0).data = sub_parse_hashval(hashval);
        otherwise,
            error(['Unknown hash sequence: ',hash_str]);
    end
end

% Step 2.
% Read token lines
token_idx = setdiff([1:size(token_data,1)],hash_idx);
for t0=1:length(token_idx),
    stim_str = token_data{token_idx(t0)};
     [idx1,idx2] = regexp(stim_str,'#[-.</>\w\s"\?,''!=]*');
%    stim(t0).token = deblank(strtok(stim_str));
%    prompt = regexp(strtok(stim_str,'#'),'(".*")','match');
    promptargs = regexp(strtok(stim_str,'#'),'[\w#.]*|("((?:[^"\\]|\\.)*)")','match');
    if numel(promptargs)==1,
        prompt = '';
    else
        prompt = promptargs(2);
    end
    stim(t0).token = promptargs{1};
    if isempty(prompt)
        %stim(t0).prompt = sprintf('%s %s','$$$',stim(t0).token);
        stim(t0).prompt = sprintf('%s',stim(t0).token);
    else
        prompt = regexp(prompt{1},'[#\w\s<>=@''/]*','match');
        %stim(t0).prompt = sprintf('%s %s','$$$',prompt{1});
        stim(t0).prompt = sprintf('%s',prompt{1});
    end
    
    stim(t0).nrows = length(idx1);
    tokenrep = regexp(strtok(stim_str,'#'),'\s\d+','match');
    if isempty(tokenrep),
        tokenrep = {'1'};
    end
    stim(t0).tokenrep = str2num(char(tokenrep));
    
    arg{1} = stim(t0).prompt;

    for r0=1:stim(t0).nrows,
        if stim(t0).nrows==1
            row_str  = stim_str(idx1(r0):end);
        else
            row_str  = stim_str(idx1(r0):idx2(r0));
        end
        [row_type,row_args] = strtok(row_str);
        row_type = deblank(row_type);
%        args = regexp(row_str,'(?<!#\w*)[-.</>\w]*','match');
        args = regexp(row_args,'[\w#.]*|("((?:[^"\\]|\\.)*)")','match');
        for a0=1:numel(args),
            tmp = args{a0};
            if tmp(1) == '"',
                args{a0} = tmp(2:end-1);
            end
        end
        args = {arg{:},args{:}}';
        key  = find(strcmp(row_type,{hash_list(:).key}));
        
        if ~isempty(key),
            try
                fullstr = sub_replace_keys(hash_list(key).val,hash_list(key).data.keys,args);
            catch
               error(['Replace keys: [',lasterr,'] ',row_str]);
            end
            switch row_type(1:2),
                case '#D',
                    row_str = cat(2,'DUMMY ',fullstr);
                case '#T',
                     fullstr = cat(2,'$$$',fullstr);
                    if isempty(block),
                        row_str = cat(2,stim(t0).token,'@@@ ',fullstr);
                    else
                        row_str = cat(2,stim(t0).token,'_',block,'@@@ ',fullstr);
                    end
                case '#P',
                    row_str = cat(2,'PAUSE ',fullstr);
                otherwise,
                    error(['Unknown hash sequence in token: ',stim_str]);
            end
        else,
            error(['Unknown hash key: ',row_type]);
        end
        stim(t0).row{r0} = row_str;
    end
    if isempty(stim(t0).row), 			% stimulus that does not reference template case
    	stim(t0).row = {stim_str}; 
    	stim(t0).nrows = 1;
    end;
end

% Create repetitions
stimlist = [];
for t0=1:length(stim),
    stimlist = [stimlist,repmat(t0,1,stim(t0).tokenrep)];
end
stimlist = repmat(stimlist,repCount,1);
stimlist = stimlist';

% Randomize if necessary
if ~isempty(permfcn),
    stimlist = feval(permfcn,stimlist);
end
stimlist = stimlist(:);

% generate repetition numbers
repnostart = repOffset*[stim(:).tokenrep];
newoffset = repOffset+repCount;
repnostart = repnostart(:);
replist = 0;
for t0=1:length(stim),
    replist = replist + (repnostart(stimlist)+cumsum(stimlist==t0)).*(stimlist==t0);
end

% Echo token array to command window or file
if isempty(lstfile),
    fid = 1;
elseif ischar(lstfile),
    fid = fopen(lstfile,'wt');
    if fid == -1,
        error(['Could not open output file']);
    end
else,
    fid = lstfile;
    lstfile = '';
end
if nargout == 2,
    strout = {};
    fid = -1;
    lstfile = '';
end

if ~isempty(passthrough),
    for s0=1:length(passthrough),
        if fid ~= -1,
            fprintf(fid,'%s\n',passthrough{s0});
        else
            strout{end+1,1} = passthrough{s0};
        end
    end
end
if fid ~= -1,
    fprintf(fid,'\n');
else
    strout{end+1,1} = sprintf('\n');
end

for s0=1:length(stimlist),
    for r0=1:stim(stimlist(s0)).nrows,
        str = stim(stimlist(s0)).row{r0};
        %str = regexprep(str,'@@@',sprintf('_R%02d',replist(s0)));
        str = regexprep(str,'@@@',sprintf('_%02d',replist(s0)));
        if isempty(str), str = stim(stimlist(s0)).row{r0}; end;
        if fid ~= -1,
            fprintf(fid,'%s\n',str);
        else
            strout{end+1,1} = str;
        end
    end
end
if ~isempty(lstfile),
    fclose(fid);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                          SUBFUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function data = sub_parse_hashval(str)
% Parses the carrier phrase to determine the number of input arguments
mat = regexp(str,'@\d','match');
data.keys    = unique(mat);

if isempty(mat)
    data.numargs = 0;
else,
    argnum = char(mat');
    argnum = str2num(argnum(:,2:end));
    argnum = unique(argnum);
    data.numargs = length(argnum);
    if (max(argnum)-min(argnum))>(length(argnum)-1),
        error(['Incorrect argument numbering: ',str]);
    end
end

function str = sub_replace_keys(str,keys,keyvalues)
% Substitutes arguments with appropriate string values
if length(keys) ~= length(keyvalues),
    error('Argument number mismatch');
end
for key0=1:length(keyvalues),
    str = regexprep(str,keys{key0},keyvalues{key0});
end
