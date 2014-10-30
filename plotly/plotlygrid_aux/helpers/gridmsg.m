function errormsg = gridmsg(key)
switch key 
    case 'gridAuthentication:credentialsNotFound'
        errormsg = ['\nOpps! It looks like you haven''t set up your plotly '...
            'account credentials\nyet. To get started, save your '...
            'plotly username and API key by calling:\n'...
            '>>> saveplotlycredentials(username, api_key). \n\n'...
            'For more help, see https://plot.ly/MATLAB or contact '...
            'chuck@plot.ly.\n\n'];
    case 'gridFilename:notValid'
        errormsg = ['Oops! Please specify a valid filename'];
    case 'gridFilename:alreadyExists'
        errormsg = ['\nOops! A file already exists with this filename.\n'];
    case 'gridInputs:notKeyValue'
        errormsg = ['\nOops! The variable argument inputs to plotlygrid.m ',...
            'must be key value. \n'];
    case 'gridCols:duplicateName'
        errormsg = ['Oops! Please specify unique name for each column.'];
    case 'gridDelete:tooInvalidInputs'
        errormsg = ['\nOops! you specified the wrong number of inputs!'];
    case 'gridGeneric:genericError'
        errormsg = [''];
end