function [x_axis, y_axis] = reevaluateDomains(x_axis, y_axis, empty_axis)

%find current domain range

x_min = 1;
x_max = 0;
y_min = 1;
y_max = 0;

x_min_r = 1;
x_max_r = 0;
y_min_r = 1;
y_max_r = 0;

for i = 1:numel(x_axis)
    if ~any(empty_axis(:,1)==i)
        if x_axis{i}.domain(1)<x_min_r
            x_min_r=x_axis{i}.domain(1);
        end
        if x_axis{i}.domain(2)>x_max_r
            x_max_r=x_axis{i}.domain(2);
        end
    end
    
    if x_axis{i}.domain(1)<x_min
        x_min=x_axis{i}.domain(1);
    end
    if x_axis{i}.domain(2)>x_max
        x_max=x_axis{i}.domain(2);
    end
end

for i = 1:numel(y_axis)
    if ~any(empty_axis(:,2)==i)
        if y_axis{i}.domain(1)<y_min_r
            y_min_r=y_axis{i}.domain(1);
        end
        if y_axis{i}.domain(2)>y_max_r
            y_max_r=y_axis{i}.domain(2);
        end
    end
    
    if y_axis{i}.domain(1)<y_min
        y_min=y_axis{i}.domain(1);
    end
    if y_axis{i}.domain(2)>y_max
        y_max=y_axis{i}.domain(2);
    end
end

%rescale domain after removing empty axis

x_scaling = (x_max_r-x_min_r)/(x_max-x_min);
y_scaling = (y_max_r-y_min_r)/(y_max-y_min);
a = x_max-x_max_r-x_min+x_min_r;
b = x_min_r-x_max_r;
x_center = (x_max-x_max_r) * b/a + x_max_r;
a = y_max-x_max_r-y_min+y_min_r;
b = y_min_r-y_max_r;
y_center = (y_max-y_max_r) * b/a + y_max_r;

for i = 1:numel(x_axis)   
    for k=1:2
        x_axis{i}.domain(k)=(x_axis{i}.domain(k)-x_center)/x_scaling + x_center;
    end  
end

for i = 1:numel(y_axis)   
    for k=1:2
        y_axis{i}.domain(k)=(y_axis{i}.domain(k)-y_center)/y_scaling + y_center;
    end  
end


end