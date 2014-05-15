function [figure] = test_getplotlyfigure(requestor, api_key, file_owner, file_id, status_code)

    signin(requestor, api_key);
    try
        figure = getplotlyfig(file_owner, file_id);
    catch err
        fprintf([err.identifier, '\n', err.message,'\n']);
        assert(strcmp(err.identifier,...
                      ['BadResponse:StatusCode', num2str(status_code)]),...
               ['Expected status_code: ', num2str(status_code), ', recieved ', err.identifier]);
        figure = err;        
    end

end