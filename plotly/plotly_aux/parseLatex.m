function formatStr = parseLatex(inputText,d)
% IF $$ signs - if on outside just keep their style
% IF $$ signs - if on inside move everything on outside of $$ to \text{} and place $$ on outside
% IF NO $$ but \greek put $$ around string and .. look for \greek and isolate the rest with \text { }
% IF NO $$ and no greek, keep as is.
% CHECK THE INTERPRETER IF LATEX

try
    if(strcmp(d.Interpreter,'tex'));
        istex = false; %check to see if there is tex present
        formatStr = inputText;
        scount = 1; %iterates through formatStr
        ccount = 1; %iterates through formatStrCell
        
        % look for \ ^ and _
        % text needs to be put in \text{} blocks and everything else needs to be untouched
        % the issue - plotly format should have \text{} blocks around text for nicer formatting
        % look for \, ^ and _ . Place everything else in \text{}
        
        while scount <= (length(formatStr))
            switch formatStr(scount)
                case '\'
                    istex = true;
                    formatStrCell{ccount} = [];
                    while((scount <= length(formatStr)))
                        %break \ statements at whitespace: ' '
                        formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                        if(strcmp(formatStr(scount),' '))
                            scount = scount + 1;
                            break
                        end
                        scount = scount + 1;
                    end
                    ccount = ccount + 1;
                case '_'
                    istex = true;
                    formatStrCell{ccount} = [];
                    if(~strcmp(formatStr(scount+1),'{')) %assumes formatStr(scount+1) exists
                        formatStrCell{ccount} = [formatStr(scount) formatStr(scount+1)];
                        scount = scount + 2;
                        ccount = ccount + 1;
                    else
                        while ((scount <= length(formatStr)))
                            formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                            if(strcmp(formatStr(scount), '}'))
                                scount = scount + 1;
                                break
                            end
                            scount = scount + 1;
                        end
                        ccount = ccount + 1;
                    end
                case '^'
                    istex = true;
                    formatStrCell{ccount} = [];
                    if(~strcmp(formatStr(scount+1),'{')) %assumes formatStr(scount+1) exists
                        formatStrCell{ccount} = [formatStr(scount) formatStr(scount+1)];
                        scount = scount + 2;
                        ccount = ccount + 1;
                    else
                        while ((scount <= length(formatStr)))
                            formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                            if(strcmp(formatStr(scount), '}'))
                                scount = scount + 1;
                                break
                            end
                            scount = scount + 1;
                        end
                        ccount = ccount + 1;
                    end
                otherwise
                    formatStrCell{ccount} = ['\text{'];
                    while ((scount <= length(formatStr)))
                        if(strcmp(formatStr(scount), '_') || strcmp(formatStr(scount), '^') || strcmp(formatStr(scount), '\') )
                            break
                        end
                        formatStrCell{ccount} = [formatStrCell{ccount}  formatStr(scount)];
                        scount = scount + 1;
                    end
                    formatStrCell{ccount} = [formatStrCell{ccount} '}'];
                    ccount = ccount + 1;
            end
        end
        
        if(istex)
            formatStr = ['$' formatStrCell{:} '$'];
        else
            formatStr = inputText;
        end
        
    elseif(strcmp(d.Interpreter,'latex'));
        islatex = false; %check to see if there is latex present
        %assume that $ are only used in title as delimiters
        formatStr = inputText;
        scount = 1; %iterates through formatStr
        ccount = 1; %iterates through formatStrCell
        dsPairs = regexp(formatStr,'\$\$');
        %from $$ $$ or $ $
        while scount <= (length(formatStr))
            if(strcmp(formatStr(scount),'$'))
                islatex = true;
                if any(dsPairs == scount)
                    %double $$ situation
                    nextS = regexp(formatStr(scount+1:end),'\$\$','once');
                    formatStrCell{ccount} = formatStr(scount:scount + nextS);
                    scount = scount + nextS + 2;
                    ccount = ccount + 1;
                else
                    %single $ situation
                    nextS = regexp(formatStr(scount+1:end),'\$','once');
                    formatStrCell{ccount} = formatStr(scount:scount + nextS);
                    scount = scount + nextS + 1;
                    ccount = ccount + 1;
                end
            else
                formatStrCell{ccount} = ['\text{'];
                while(scount<= length(formatStr)) %always going to be outside a $ pair
                    if(strcmp(formatStr(scount),'$'))
                        break
                    end
                    formatStrCell{ccount} = [formatStrCell{ccount} formatStr(scount)];
                    scount = scount + 1;
                end
                formatStrCell{ccount} = [formatStrCell{ccount} '}'];
                ccount = ccount + 1;
            end
        end
        
        %remove all $
        formatStr = [formatStrCell{:}];
        dsloc = regexp(formatStr,'\$');
        formatStr(dsloc) = '';
        
        if(islatex)
            if(any(dsPairs))
                formatStr = ['$$' formatStr '$$'];
            else
                formatStr = ['$' formatStr '$'];
            end
        else
            formatStr = inputText;
        end
        
        %same approach as tex but need to handle $$/$
        %don't touch anything within $$ signs - can't be nested
        %everything else is in \text{}
        %find pairs of $ or $$
        %1 - create cell array of string
        %2 - check string cell array and see if $
        %3 - if $ check for next $
        %4 - if next $ is immediately after then take the next next $$ if
        %5 - none then just take one $
        %6 - from that dollar sign to next dollar sign do nothing
        %7 - between dollar signs add \text{};
        %ex: $\sqrt{5}$ + $$\int123$$ + $$hello$;
        
    else
        formatStr = inputText; %do nothing (allow user to specify mathjax format)
    end
    
catch
    formatStr = inputText;
    display(['Sorry - we could not successfully parse the latex within your title.', ...
        'Please consult www.plot.ly/matlab for more information']);
end




