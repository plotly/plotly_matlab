function formatStr = parseString(inputStr,interpreter)
    % parseLatex(inputStr,d) converts TeX, and LaTeX
    % strings into a format that preserves the text/math
    % formatting structure used by mathjax for Plotly plots.
    %
    % TeX: parses through inputStr for instances of
    % the specials characters: \, _, and ^. Uses whitespace
    % as a delimiter for the end of \reservedwords (enforced
    % if not already present), uses either the enclosing { }
    % brackets  as delimiters for _ and ^ or simply the
    % immediately proceeding character if no curly brackets
    % are present. If the immediately proceeding character
    % of ^ or _ is a \reservedword, the entire word up to the
    % next whitespace is taken. All other characters are
    % contained within \text{ } blocks. Resulting string is
    % placed within inline: formatStr = $ ...parsedStr... $ delimiters.
    %
    % LaTeX: parses through inputStr for instances of $
    % or $$. Assumes that $/$$ are only ever used as
    % delimiters. Anything chars that do not fall within the
    % $/$ or $$/$$ blocks are placed within a \text{ } block.
    % Finally, all instances of $/$$ are removed and the
    % resulting string is placed (if no $$ instance is present)
    % within inline: formatStr = $ ...parsedStr...$ delimiters
    % or (if an instance of $$ is present) within block:
    % formatStr $$... parsedStr ... $$ delimiters.

    %initialize output
    formatStr = inputStr;

    if isempty(inputStr)
        formatStr = 'untitled';
        return
    end

    try
        istex = false;
        islatex = false;

        %------- CONVERT CELL ARRAY TO STRING WITH LINE BREAKS -------%
        if (iscell(inputStr))
            if (size(inputStr,1)==1)
                inputStr = strjoin(inputStr, '<br>');
            else
                inputStr = strjoin(inputStr', '<br>');
            end
        end

        %------- PARSE TEX --------%

        if (strcmp(interpreter,'tex'))
            %add white space after reserved TeX words
            formatStr = formatRW(inputStr);
            %counter to iterate through formatStr
            scount = 1;
            %counter to iterate through formatStrCell
            ccount = 1;
            %iterate through formatStr
            while scount <= (length(formatStr))
                switch formatStr(scount)
                    case '\' %- \words - %
                        istex = true;
                        formatStrCell{ccount} = [];
                        while(scount <= length(formatStr))
                            formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                            %break \word structure at whitespace: ' '
                            if (strcmp(formatStr(scount),' '))
                                scount = scount + 1;
                                break
                            end
                            scount = scount + 1;
                        end
                        ccount = ccount + 1;
                    case '_' %- _ subscripts -%
                        istex = true;
                        formatStrCell{ccount} = [];
                        % look for enclosing { }
                        if (~strcmp(formatStr(scount+1),'{'))
                            % if no { } look for \ word
                            if (strcmp(formatStr(scount+1),'\'))
                                while (scount <= length(formatStr))
                                    formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                                    % break \word structure at whitespace: ' '
                                    if (strcmp(formatStr(scount), ' '))
                                        scount = scount + 1;
                                        break
                                    end
                                    scount = scount + 1;
                                end
                                ccount = ccount + 1;
                                % if no { } and no \word
                            else
                                % take immediately proceeding char (existence assumed)
                                formatStrCell{ccount} = [formatStr(scount) formatStr(scount+1)];
                                scount = scount + 2;
                                ccount = ccount + 1;
                            end
                        else
                            % if enclosing { } are present
                            while (scount <= length(formatStr))
                                formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                                % break _{ structure at '}'
                                if (strcmp(formatStr(scount), '}'))
                                    scount = scount + 1;
                                    break
                                end
                                scount = scount + 1;
                            end
                            ccount = ccount + 1;
                        end
                    case '^' %- ^ superscripts - %
                        istex = true;
                        formatStrCell{ccount} = [];
                        % look for enclosing { }
                        if (~strcmp(formatStr(scount+1),'{'))
                            % if no { } look for \ word
                            if (strcmp(formatStr(scount+1),'\'))
                                while ((scount <= length(formatStr)))
                                    formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                                    % break \word structure at whitespace: ' '
                                    if (strcmp(formatStr(scount), ' '))
                                        scount = scount + 1;
                                        break
                                    end
                                    scount = scount + 1;
                                end
                                ccount = ccount + 1;
                                % if no { } and no \word
                            else
                                % take immediately proceeding char (existence assumed)
                                formatStrCell{ccount} = [formatStr(scount) formatStr(scount+1)];
                                scount = scount + 2;
                                ccount = ccount + 1;
                            end
                        else
                            % if enclosing { } are present
                            while ((scount <= length(formatStr)))
                                formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                                % break ^{ structure at '}'
                                if (strcmp(formatStr(scount), '}'))
                                    scount = scount + 1;
                                    break
                                end
                                scount = scount + 1;
                            end
                            ccount = ccount + 1;
                        end
                    otherwise %- \text{ } - %
                        formatStrCell{ccount} = ['\text{'];
                        while (scount <= length(formatStr))
                            %break \text{ } structure at \word, _ or ^ chars
                            if (strcmp(formatStr(scount), '_') ...
                                    || strcmp(formatStr(scount), '^') ...
                                    || strcmp(formatStr(scount), '\') )
                                break
                            end
                            formatStrCell{ccount} = [formatStrCell{ccount}  formatStr(scount)];
                            scount = scount + 1;
                        end
                        formatStrCell{ccount} = [formatStrCell{ccount} '}'];
                        ccount = ccount + 1;
                end
            end
            %created parsedStr from formatStrCell
            parsedStr = [ formatStrCell{:} ];

            % place in inline: $...parsedStr...$ delimiters
            if (istex)
                formatStr = ['$' parsedStr '$'];
            else
                formatStr = inputStr;
            end
        elseif (strcmp(interpreter,'latex')) %------- PARSE LATEX --------%
            formatStr = inputStr;
            %counter to iterate through formatStr
            scount = 1;
            %counter to iterate through formatStrCell
            ccount = 1;
            %look for existence of $$
            dsPairs = regexp(formatStr,'\$\$');

            %iterate through formatStr
            while scount <= (length(formatStr))
                if (strcmp(formatStr(scount),'$'))
                    islatex = true;

                    %- $$... $$ -%
                    if any(dsPairs == scount)
                        nextS = regexp(formatStr(scount+1:end),'\$\$','once');
                        formatStrCell{ccount} = formatStr(scount:scount + nextS);
                        scount = scount + nextS + 2;
                        ccount = ccount + 1;

                        %- $ ... $ -%
                    else
                        nextS = regexp(formatStr(scount+1:end),'\$','once');
                        formatStrCell{ccount} = formatStr(scount:scount + nextS);
                        scount = scount + nextS + 1;
                        ccount = ccount + 1;
                    end
                else %- \text{ } -%
                    formatStrCell{ccount} = ['\text{'];
                    while(scount<= length(formatStr))
                        if (strcmp(formatStr(scount),'$'))
                            break
                        end
                        formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                        scount = scount + 1;
                    end
                    formatStrCell{ccount} = [formatStrCell{ccount} '}'];
                    ccount = ccount + 1;
                end
            end

            %remove all instances of $
            parsedStr = [formatStrCell{:}];
            parsedStr(regexp(parsedStr,'\$')) = '';

            % place in inline: $...parsedStr...$
            % or $$...parsedStr...$$ delimiters
            if (islatex)
                if (any(dsPairs))
                    formatStr = ['$$' parsedStr '$$'];
                else
                    formatStr = ['$' parsedStr '$'];
                end
            else
                formatStr = inputStr;
            end
        end
    end
end
