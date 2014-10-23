
# PROPOSAL

## plotlygrid.m

```MATLAB

% --- PUBLIC PROPERTIES--- %

UserData; % (struct)
GridOptions; % (struct)
url; % (string)
warnings; (string) 
column1 % (plotlycolumn object) [dynamic property]
column2 % (plotlycolumn object) [dynamic property]

.
.
.

columnN % (plotlycolumn obj) [dynamic property]

% --- HIDDEN PROPERTIES--- %

GridData; 
File; 

% --- PUBLIC METHODS--- %

plotlygrid (constructor)
upload
appendCols
appendRows

```

# Usage

## Creating a Plotly Grid in MATLAB 

Create data structure: 
```
data.current = [1,2,3]
data.voltage = [11,12,13]
data.mag_field = [110, 120, 130]
data.time = [500,600,700]
```

Construct `plotlygrid` object
```
grid = plotlygrid(data, 'filename', 'experimental data')
```

Example `plotlygrid` object properties once initialized:
```

% --UserData-- %

grid.UserData.UserName: 'localgrids'
grid.UserData.ApiKey: 'l0qljb42tc'
grid.UserData.Domain: 'http://api-local.plot.ly:3000'

% --GridOptions-- %

grid.GridOptions.FileName: 'experimental data' 
grid.GridOptions.WorldReadable: 1
grid.GridOptions.Parent: '0'
grid.GridOptions.ParentPath:'0'
grid.GridOptions.OpenUrl: 1
grid.GridOptions.ShowUrl: 1

% --Column Objects-- % (dynamic property)

grid.current = [1,2,3]
grid.voltage = [11, 12, 13]
grid.mag_field = [110, 120, 130]
grid.time = [500, 600, 700]

% --url-- %

grid.url: 'http://local.plot.ly/~localgrids/62/'

% --warnings-- % 

grid.warnings = {0x1 cell} 



% --File-- % (hidden)

grid.File.fid: 'localgrids:56'
grid.File.filename: 'experimental data'
grid.File.filetype: 'grid'
grid.File.owner: 'localgrids'
grid.File.world_readable: 1
grid.File.creation_time: '2014-10-22T15:30:17.247Z'
grid.File.parent: -1
grid.File.views: 0
grid.File.preview: [1x1 struct]
grid.File.title: [1x0 char]
grid.File.mg_url: [1x0 char]
grid.File.web_url: 'http://local.plot.ly/~localgrids/56/'
grid.File.embed_url: 'http://local.plot.ly/~localgrids/56.embed'
grid.File.cols: {[1x1 struct]  [1x1 struct]}

% --GridData-- % (hidden)

grid.GridData.current.data: [1 2 3] 
grid.GridData.current.order: 1
grid.GridData.voltage.data: [11 12 13] 
grid.GridData.voltage.order: 2
grid.GridData.mag_field.data: [110 120 130]
grid.GridData.mag_field.order: 3
grid.GridData.time.data: [500 6000 700]
grid.GridData.time.order: 4

```

## Updating Grids

Updating Plotly grids is currently handled by two methods of the `plotlygrid` class: `appendCols` and `appendRows` . 

`appendCols` takes a cell array as input, whose elements are structure arrays (similar to the data key of clientresp). The structure array elements of the cell array input contain both data and name fields. 

```
cols{1}.name = 'my_new_column1';
cols{1}.data = [1 2 3 4 5];
cols{2}.name = 'my_new_column2';
cols{2}.data = [10 20 30 40 50];

grids.appenCols(cols);
```

The `appendCols` method dynamically updates the properties of grid, adding new plotlycolumn objects under the name corresponding to the column. 
So grid.my_new_column1 and grid.my_new_column2 would now be properites of grid 
and would be initialized with new plotlycolumn objects. Should grid.File also be updated with the new column information? Pourquoi-pas. 


For now, `appendRows` takes row data as input in the form of an mxn matrix, where n is the number of columns in the grid and m is the number of rows to be appended. This might change to something a little more user friedly in the near future. The `plotlygrid` object properties containing the column data are updated to reflect the addition of these new rows. 

```
data.time = [0:100];
data.power = [1000:1100];

grid = plotlygrid(data);

row_data = [101 1102; 102 1102]
grid.appenRows(row_data);

grid.time = [0:100 101 102]
grid.power = [1000:1100 1101 1102]

```

Once the `../v2/grids/{id}` endpoint is up and running,  `appendCols` and `appendRows`can be wrapped in another, more user friendly, function like `extendplotlygrid`, which will take either/any of the filename of the grid, the url of the grid or the uid of the grid as input and simply create a plotlygrid object and invoke the `appendRows` or `appendCols` method of that object. 

## Plotting using Column References

Plotting will be handled by overloading MATLAB's core plotting functions within the ``plotlycolumn`` class (documented soon). A basic example is as follows: 

```
data.time = [0:100];
data.power = [1000:1100];

grid = plotlygrid(data);

plot(grid.time, grid.power, 'r');

```
Since `grid.time` is a plotlycolumn object, the plotlycoluumn function `plot` will be invoked. This will look something like:

```

function obj = plot(obj, varargin)
  
  handle = plot(obj, varargin)

  p = plotlyfig(gcf); 

  data_index = p.getDataIndex(handle);

  if isa(varargin{1},'plotlycolumn')
    obj2 = varargin{1}; 
    p.data{data_index}.x = [obj.username '/' obj.FID ':' obj.UID]; 
    p.data{data_index}.y = [obj2.username '/' obj2.FID ':' obj2.UID]; 
  else
    p.data{data_index}.y = [obj.username '/' obj.FID ':' obj.UID]; 
  end

  p.plotly; 
end

```

the else statment above could throw a msg like : Whoops! you are implicitly creating a new data column by only specifying one plotlycolumn as input... do you want us to create a new plotlycolumn object for you? ... and then do it. 


## Overwriting and Deleting Plotly Grids

Overwriting is not currently supported. For now, only a complete deletion of a grid is possible. This will be handled by the `deleteplotlygrid` function. 

```
deleteplotlygrid('grid_url' or 'uid' or 'plotlygridobj' or 'filename')

``` 
Will it ever be possible to give someone permission to delete a grid in your account? 

In the future, overwriting will look like: 

```
grid = plotlygrid(data,'mygrid') %overwrite my grid by default

% or

grid = plotlygrid(data, 'mygrid', 'overwrite', false)

```

## Error Handling 

```
data.time = [1:10];
data.time = [120:130];
grid = plotlygrid(data,'filename','my_grid');

'Whoops! Duplicate column names are not allowed!' 

```

```
data.time = [1:10];
data.power = [120:130];
grid = plotlygrid(data);

'Whoops! Must specify a filename!' 

```

```
data.time = [1:10];
data.power = [120:130];
grid = plotlygrid(data,'filename','my_grid');

row_data = [1 ; 2]; 
grid.appendRows(row_data);

'Whoops! Missing row data for the power column.' 

```

```
data.time = [1:10];
data.power = [120:130];
grid1 = plotlygrid(data,'filename','my_grid');

%try to create another plotlygrid object... 
grid2 = plotlygrid(data,'filename','my_grid','overwrite',false);

'Whoops! A grid with that filename already exists.' 

```

## Returning an Existing Plotly Grid

requires the `../v2/grids/{id}` endpoint. Eventually wrapped in a function called `getplotlygrid('username','fid')` in a similar fashion to getplotlyfig. 



