# Contributing

Thanks for helping out! This converter runs in both MATLAB and GNU Octave, so
changes should work in both. Below is how to run the tests and how to add
support for a new plot type or gallery example.

## Running the tests

The test runner is `plotly/testing/runplotlytests.m`; it discovers every
`Test_*.m` under `plotly/`.

```matlab
addpath(fullfile(pwd, 'plotly', 'testing'));
runplotlytests                                              % everything
runplotlytests('Test_m2json')                               % one suite
runplotlytests('Test_plotlyfig_lines/testLinePlotData')     % one test
```

In Octave, install the optional packages once if you haven't:
`pkg install -forge datatypes statistics`.

## Adding a plot handler

Every supported graphics type has an `updateX` function in
`plotly/plotlyfig_aux/handlegraphics/`. To add one:

1. Inspect the object first. Octave and MATLAB expose different graphics
   objects. Use `get`/`set` rather than dot indexing.
2. Add `plotly/plotlyfig_aux/handlegraphics/updateX.m`:

   ```matlab
   function obj = updateX(obj, dataIndex)
       h = obj.State.Plot(dataIndex).Handle;
       obj.data{dataIndex}.type = 'scatter';
       obj.data{dataIndex}.x = get(h, 'XData');
       obj.data{dataIndex}.y = get(h, 'YData');
   end
   ```
3. Register it in the switch in `plotly/plotlyfig_aux/core/updateData.m`.
4. Add a test to the matching suite (`Test_plotlyfig_lines`, `_bars`, `_3d`
   or `_special`).

Reusable code belongs in `plotly/plotlyfig_aux/helpers/`; local functions in
one file are not visible from another.

## Adding a gallery entry

The gallery compares native and converted figures for each entry in
`galleryEntries()` at the bottom of `plotly/makegallery.m`. Add a `{name, code}`
row:

```matlab
'myplot',    'myplot(1:10, [3 5 2 8 4 6 9 1 7 5]);'; ...
```

The gallery creates the figure for you, so the code just has to draw into it.
Use fixed data (or seed the RNG) so the picture is reproducible, and keep the
entry working in both engines when possible. Iterate on a single entry with:

```matlab
makegallery('Functions', {'myplot'}, 'Open', false)
```

Keep commits to one logical change with a short imperative message.
