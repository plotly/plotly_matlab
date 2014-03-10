function [xid, yid, x_axis y_axis] = extractAxes(a, layout, x_axis, y_axis, strip_style)
% extractAxes - create an axes struct
%   [xid, yid, x_axis y_axis] = extractAxes(a, layout, x_axis, y_axis)
%       a - a data struct from matlab describing an axes
%       layout - a plotly layout strcut
%       x_axis, y_axis - current cells containing axis objects
%       xid,yid - reference axis indices
% 
% For full documentation and examples, see https://plot.ly/api


xaxes={};
yaxes={};

%copy over general properties

[xaxes, yaxes] = extractAxesGeneral(a, layout, xaxes, yaxes, strip_style);


%OVERLAY CHECK
x_bounds = xaxes.domain;
y_bounds = yaxes.domain;
x_check=0;x_duplicate=0;
y_check=0;y_duplicate=0;
for i=1:numel(x_axis)
    if x_bounds(1) == x_axis{i}.domain(1) && x_bounds(2) == x_axis{i}.domain(2)
        x_check = i;
        if strcmp(a.XAxisLocation, x_axis{i}.side)
            if sum(a.XLim == x_axis{i}.range)==2
                x_duplicate=1;
            end
        end
    end
end
for i=1:numel(y_axis)
    if y_bounds(1) == y_axis{i}.domain(1) && y_bounds(2) == y_axis{i}.domain(2)
        y_check = i;
        if strcmp(a.YAxisLocation, y_axis{i}.side)
            if sum(a.YLim == y_axis{i}.range)==2
                y_duplicate=1;
            end
        end
    end
end


if x_check>0 && y_check>0
       
    %anchors
    ax_num = x_check;
    if x_check==1
        ax_num = [];
    end
    ay_num = y_check;
    if y_check==1
        ay_num = [];
    end
    xaxes.overlaying = ['x' num2str(ax_num)];
    yaxes.overlaying = ['y' num2str(ay_num)]; 
    xaxes.anchor = ['y' num2str(ay_num)];
    yaxes.anchor = ['x' num2str(ax_num)];
    
    xaxes.mirror = false;
    yaxes.mirror = false;
    
    % some overlay happens
    if x_duplicate==1
        %xaxes will not be added
        xid = x_check;
    else
        x_axis{numel(x_axis)+1} = xaxes;
        xid = numel(x_axis);
    end
    if y_duplicate==1
        %yaxes will not be added
        yid = y_check;
    else
        y_axis{numel(y_axis)+1} = yaxes;
        yid = numel(y_axis);
    end

    
else

    ax_num = numel(x_axis)+1;
    if numel(x_axis)==0
        ax_num = [];
    end
    ay_num = numel(y_axis)+1;
    if numel(y_axis)==0
        ay_num = [];
    end
    xaxes.anchor = ['y' num2str(ay_num)];
    yaxes.anchor = ['x' num2str(ax_num)];
    % add both
    x_axis{numel(x_axis)+1} = xaxes;
    y_axis{numel(y_axis)+1} = yaxes;
    xid = numel(x_axis);
    yid = numel(y_axis);
end

end