function formatStr = parseLatex(inputText,d)
% IF $$ signs - if on outside just keep their style
% IF $$ signs - if on inside move everything on outside of $$ to \text{} and place $$ on outside
% IF NO $$ but \greek put $$ around string and .. look for \greek and isolate the rest with \text { }
% IF NO $$ and no greek, keep as is.
% CHECK THE INTERPRETER IF LATEX

try
    if(strcmp(d.Interpreter,'tex'));
        formatStr = inputText;
        
        % look for \ ^ and _
        % text needs to be put in \text{} blocks and everything else needs to be untouched
        % the issue - plotly format should have \text{} blocks around text for nicer formatting
        % look for \, ^ and _ . Place everything else in \text{}
        
        scount = 1; %iterates through formatStr
        ccount = 1; %iterates through formatStrCell
        
        while scount <= (length(formatStr))
            switch formatStr(scount)
                case '\'
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
                        formatStrCell{ccount} = [];
                    end
                case '^'
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
        
        formatStr = ['$' formatStrCell{:} '$'];
        
    elseif(strcmp(d.Interpreter,'Latex'));
        formatStr = inputText;
    else
        formatStr = inputText; %do nothing
    end
    
catch
    formatStr = inputText;
    display(['Sorry - we could not successfully parse the latex within your title.', ...
        'Please consult www.plot.ly/matlab for more information']);
end




