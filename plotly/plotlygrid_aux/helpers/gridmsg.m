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
        errormsg = ['\nOops! Please specify a valid filename.\n\n'];
    case 'gridData:notFound'
        errormsg = ['\nOops! No grid data was found to upload to Plotly.\n\n'];
    case 'gridData:notValid'
        errormsg = ['\nOops! The grid data must be contained within a struct.\n\n'];
    case 'gridAppendRows:noGridId'
        errormsg = ['\nOops! Please specify a gridId!\n\n'];
    case 'gridAppendRows:invalidInput'
        errormsg = ['\nOops! Please data input must be a matrix!\n\n'];
    case 'gridAppendCols:noGridId'
        errormsg = ['\nOops! Please specify a gridId!\n\n'];
    case  'gridDelete:noGridId'
        errormsg = ['\nOops! Please specify a gridId!\n\n'];
    case 'gridAppendCols:invalidInput'
        errormsg = ['\nOops! Column input must be a struct!\n\n'];
    case 'gridFilename:alreadyExists'
        errormsg = ['\nOops! A file already exists with this filename.\n\n'];
    case 'gridInputs:notKeyValue'
        errormsg = ['\nOops! The variable argument inputs to plotlygrid.m ',...
            'must be key value. \n\n'];
    case 'gridCols:duplicateName'
        errormsg = ['\nOops! Please specify unique name for each column.\n\n'];
    case 'gridDelete:tooInvalidInputs'
        errormsg = ['\nOops! you specified the wrong number of inputs!\n\n'];
    case 'gridGet:invalidInputs'
        errormsg = ['\nOops! you specified the wrong number of inputs!\n\n'];
    case 'gridGeneric:genericError'
        errormsg = ['\n'];
end