function [combos, argCount, argNames] = testParams(classFile, methodName)
%TESTPARAMS Read % @name = expr parameter annotations above a test method.
%   [combos, argCount, argNames] = testParams(classFile, methodName)
%
%   A test method declares its parameters in comment lines directly above
%   the function line:
%
%       % @quiverKind = {'vector', 'grid', 'nocoords'}
%       % @n = {1, 2, 3}
%       function testQuiver(tc, quiverKind, n)
%
%   Each annotation name must match the corresponding argument of the
%   method signature (the first argument is tc).  The RHS is evaluated
%   and must be a cell array of values (a non-cell value is treated as a
%   single-value list).  combos is the cartesian product of the annotated
%   value lists, each combo a cell of argument values in annotation
%   order; {} when the method has no annotations.  argCount is the number
%   of annotations, argNames their names.
%
%   Values are single-line expressions; the annotations must be
%   contiguous with the method line (blank lines allowed in between).

    combos = {};
    argCount = 0;
    argNames = {};

    if isempty(classFile) || ~exist(classFile, 'file')
        return;
    end
    fid = fopen(classFile, 'r');
    if fid < 0
        return;
    end
    text = fread(fid, Inf, '*char')';
    fclose(fid);
    lines = strsplit(text, sprintf('\n'));

    % find the method definition line
    namePat = ['^\s*function\s+' regexptranslate('escape', methodName) '\s*\('];
    methodLine = [];
    for i = 1:numel(lines)
        if ~isempty(regexp(lines{i}, namePat, 'once'))
            methodLine = i;
            break;
        end
    end
    if isempty(methodLine)
        return;
    end

    % collect contiguous % @name = expr lines above the method; blank
    % lines are allowed between the annotations and the method line
    annNames = {};
    annExprs = {};
    j = methodLine - 1;
    while j >= 1
        line = lines{j};
        if isempty(strtrim(line))
            j = j - 1;
            continue;
        end
        tok = regexp(line, '^\s*%\s*@([A-Za-z_]\w*)\s*=\s*(.*)$', ...
            'tokens', 'once');
        if isempty(tok)
            break;
        end
        annNames{end + 1} = tok{1}; %#ok<AGROW>
        annExprs{end + 1} = strtrim(tok{2}); %#ok<AGROW>
        j = j - 1;
    end
    annNames = fliplr(annNames);
    annExprs = fliplr(annExprs);
    if isempty(annNames)
        return;
    end

    % the method signature must declare the same arguments, in the same
    % order, after tc
    sigTok = regexp(lines{methodLine}, 'function\s+\w+\s*\((.*)\)', ...
        'tokens', 'once');
    sigNames = {};
    if ~isempty(sigTok)
        parts = strsplit(sigTok{1}, ',');
        for p = 1:numel(parts)
            part = strtrim(parts{p});
            eq = strfind(part, '=');
            if ~isempty(eq)
                part = strtrim(part(1:eq(1) - 1));
            end
            if ~isempty(part)
                sigNames{end + 1} = part; %#ok<AGROW>
            end
        end
    end
    if numel(sigNames) >= 2 && strcmp(sigNames{1}, 'tc')
        sigNames = sigNames(2:end);
    else
        sigNames = {};
    end
    if ~isempty(sigNames) && ~any(strcmp(sigNames, 'varargin'))
        if numel(sigNames) ~= numel(annNames)
            error('testParams:annotationCount', ...
                ['Method %s declares %d parameter annotation(s) but its ' ...
                 'signature takes %d argument(s) (after tc).'], ...
                methodName, numel(annNames), numel(sigNames));
        end
        for i = 1:numel(annNames)
            if ~strcmp(annNames{i}, sigNames{i})
                error('testParams:annotationName', ...
                    ['Annotation %d of %s is ''@%s'' but the signature ' ...
                     'argument %d is ''%s''.'], ...
                    i, methodName, annNames{i}, i, sigNames{i});
            end
        end
    end

    % evaluate each annotation to a list of values
    lists = cell(1, numel(annNames));
    for i = 1:numel(annNames)
        try
            v = eval(annExprs{i});
        catch e
            error('testParams:evalFailed', ...
                'Cannot evaluate annotation @%s = %s of %s: %s', ...
                annNames{i}, annExprs{i}, methodName, e.message);
        end
        if ~iscell(v)
            v = {v};
        end
        if isempty(v)
            error('testParams:noValues', ...
                'Annotation @%s of %s has no values.', annNames{i}, methodName);
        end
        lists{i} = v;
    end

    % cartesian product (the last argument varies fastest)
    total = prod(cellfun(@numel, lists));
    combos = cell(total, 1);
    for c = 1:total
        idx = zeros(1, numel(lists));
        rem = c - 1;
        for j = 1:numel(lists)
            nj = numel(lists{j});
            idx(j) = mod(rem, nj) + 1;
            rem = floor(rem / nj);
        end
        combo = cell(1, numel(lists));
        for j = 1:numel(lists)
            combo{j} = lists{j}{idx(j)};
        end
        combos{c} = combo;
    end
    argCount = numel(annNames);
    argNames = annNames;
end
