function errormsg = plotlymsg(key)
    switch key
        %--plotlyfig constructor--%
        case 'plotlyfigConstructor:notSignedIn'
            errormsg = ['\nOops! You must be signed in to initialize ' ...
                    'a plotlyfig object.\n'];
        case 'plotlyfigConstructor:invalidInputs'
            errormsg = ['\nOops! It appears that you did not ' ...
                    'initialize the plotlyfig object using the\n', ...
                    'required: >>  plotlyfig(handle ', ...
                    '[optional],''property'',''value'',...) \ninput ' ...
                    'structure. Please try again or post a topic on ' ...
                    'https://community.plotly.com/c/api/matlab/ for ' ...
                    'any additional help!\n\n'];
            %--saveplotlyfig invocation--%;
        case 'plotlySaveImage:invalidInputs'
            errormsg = ['\nOops! It appears that you did not invoke ' ...
                    'the saveplotlyfig function using the\nrequired: ' ...
                    '>>  saveplotlyfig(plotly_figure, ...) input ' ...
                    'structure, where plotly_figure\nis of type cell ' ...
                    '(for data traces) or of type struct (with data ' ...
                    'and layout fields). \nPlease try again or post a ' ...
                    'topic on ' ...
                    'https://community.plotly.com/c/api/matlab/ for ' ...
                    'any additional help!\n\n'];
    end
end
