function datas = extractDataBox(d, xid, yid, CLim, colormap, strip_style)
% extractDataBox - create a data struct for box plots
%   data = extractDataHeatMap(d, xid, yid, CLim, colormap)
%       d - a data struct from matlab describing a scatter plot
%       xid,yid - reference axis indices
%       CLim - a 1x2 vector of extents of the color map
%       colormap - a kx3 matrix representing the colormap
% 
% For full documentation and examples, see https://plot.ly/api

datas = {};

%GENERAL IDEA: matlab box plot figures are a collection of traces
%representing the result of the box plot analysis. They describe the data
%in terms of percentiles and outliers, whithout keeping the underlying
%data. For each box, a total of 8 traces are generated. Each trace is a
%type of scatter plot. For styling purposes, each trace could be parsed
%using extractDataScatter. However, currently, plotly supports only a
%limited set of styling options, thus, for some traces, a simpler parse is
%used.

%TOIMPROVE: as plotly evolves, each trace could be fully parsed for
%styling.

%TOIMPORVE: for now, assume that the number of children is a multiple of 8
if mod(numel(d.Children),8)~=0
    return
end

num_boxes = numel(d.Children)/8;

%each box is it's own data struct

for b=1:num_boxes
       
    
    %COMMON PARAMETERS
    
    data = {};
    
    % copy in data type and values
    data.type = 'box';
    
    % set reference axis
    if xid==1
        xid=[];
    end
    if yid==1
        yid=[];
    end
    data.xaxis = ['x' num2str(xid)];
    data.yaxis = ['y' num2str(yid)];    
    
    %TOIMPORVE: for now assume that all boxes are visible (should generally
    %be the case)
    data.visible = true;
    
    id_basis = num_boxes-b+1;
    
    outliers = [];
    md=[];p25=[];p75=[];lev=[];uel=[];
    
    for c=1:8
        dc = get(d.Children(num_boxes*(c-1) + id_basis)); 
        
        %BOX NAME
        if strcmp('text',dc.Type)
            data.name = dc.String;
        end
        
        %RECORD OUTLIERS
        if strcmp('Outliers',dc.Tag)
            if ~isnan(dc.YData)
                outliers = dc.YData;
                %TODO: extract marker style
                marker_data = extractDataScatter(dc, xid, yid, CLim, colormap, strip_style);
            end
        end
        %RECORD MEDIAN
        if strcmp('Median',dc.Tag)
           md = dc.YData(1);
        end
        %RECORD 25 and 75 %
        if strcmp('Box',dc.Tag)
           p25 = min(dc.YData);
           p75 = max(dc.YData);
           line_data = extractDataScatter(dc, xid, yid, CLim, colormap, strip_style);
        end
        %RECORD EXTREME VALUES
        if strcmp('Upper Adjacent Value',dc.Tag)
           uev = dc.YData(1);
        end
        if strcmp('Lower Adjacent Value',dc.Tag)
           lev = dc.YData(1);
        end
        
    end
    
    %GENERATE DATA
    %TOIMPORVE: for now, given the statisitcal values, some dummy data is
    %generated as to replocate exactly these results

    data.y = generateBoxData(outliers, lev, p25, md, p75, uev);
    
    
    %styiling
    data.marker = marker_data.marker;
    data.line = line_data.line;
    %TOIMPORVE: fill color might be an option in matlab, have not seen it
    %yet, so default to transparent
    data.fillcolor = 'rgba(0, 0, 0, 0)';
    
    datas{b}=data;
    
    
    
end



end