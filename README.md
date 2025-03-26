# Plotly Graphing Library for MATLAB®

> Plotly Graphing Library for MATLAB® - Create interactive charts in your web browser with MATLAB® and Plotly

<div align="center">
  <a href="https://dash.plotly.com/project-maintenance">
    <img src="https://dash.plotly.com/assets/images/maintained-by-community.png" width="400px" alt="Maintained by the Plotly Community">
  </a>
</div>

Version: 3.0.0

*MATLAB is a registered trademarks of The MathWorks, Inc.*

## Install

The latest version of the wrapper can be downloaded [here](https://github.com/plotly/MATLAB-Online/archive/master.zip).

Once downloaded, run `plotlysetup_offline()` to get started.
If you have a plotly bundle url of the form '<http://cdn.plot.ly/plotly-latest.min.js>', then run instead
`plotlysetup_offline('plotly_bundle_url')

For online use, run `plotlysetup_online('your_username', 'your_api_key')` to get started.

### Updates

**NOTE:** `plotlyupdate.m` is currently turned off.

Please manually download and setup the latest version
of the wrapper by following the installation instructions above.

## Usage

Convert your MATLAB® figures into online [Plotly](https://plot.ly) graphs with a single line of code:

```MATLAB
 % Create some data for the two curves to be plotted
 x  = 0:0.01:20;
 y1 = 200*exp(-0.05*x).*sin(x);
 y2 = 0.8*exp(-0.5*x).*sin(10*x);

 % Create a plot with 2 y axes using the plotyy function
 figure;
 [ax, h1, h2] = plotyy(x, y1, x, y2, 'plot');

 % Add title and x axis label
 xlabel('Time (s)');
 title('Frequency Response');

 % Use the axis handles to set the labels of the y axes
 ax(1).YLabel.String = "Low Frequency";
 ax(2).YLabel.String = "High Frequency";

 %--PLOTLY--%
 p = fig2plotly; % <-- converts the yy-plot to an interactive, online version.

 %--URL--%
 % p.url = 'https://plot.ly/~matlab_user_guide/1522'

```

[![MATLAB® Contour Plot](https://plot.ly/~matlab_user_guide/1522.png)](https://plot.ly/~matlab_user_guide/1522)

Also, access other Plotly services and graphs programmatically. Like, publication-quality image export:

```MATLAB
 saveplotlyfig(p, 'testimage.svg')
```

and Plotly figure retrieval:

```MATLAB
 p = getplotlyfig('chris', 1638) % downloads the graph data from https://plot.ly/~chris/1638
```

## Documentation

This lives here: [https://plot.ly/matlab](https://plot.ly/matlab)

## Questions & troubleshooting

Ask on the [Plotly Community Forum](https://community.plotly.com/c/plotly-r-matlab-julia-net)

## Contribute

Please do! This is an open source project. Check out [the issues](https://github.com/plotly/MATLAB-Online/issues) or open a PR!

We want to encourage a warm, welcoming, and safe environment for contributing to this project. See the [code of conduct](CODE_OF_CONDUCT.md) for more information.

## License

[MIT](LICENSE) © 2021 Plotly, Inc.
