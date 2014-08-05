## Nutshell

Convert your MATLAB figures into online [plotly](https://plot.ly) graphs with a single line of code:

```MATLAB
[X, Y, Z] = peaks;
contour(X,Y,Z,20); % creates a MATLAB contour plot
fig2plotly(); % converts the contour plot to an interactive, online version: https://plot.ly/~demos/1574
```

[![MATLAB Contour Plot](https://i.imgur.com/E98mpNz.png)](https://plot.ly/~demos/1574)

Also, access other Plotly services and graphs programatically. Like, publication-quality image export:

```MATLAB
saveplotlyfig(figure.data, figure.layout, filename)
```

and Plotly figure retrieval:

```MATLAB
figure = getplotlyfig('chris', 1638) % downloads the graph data from https://plot.ly/~chris/1638
```

## Docs
Live here: [https://plot.ly/MATLAB](https://plot.ly/MATLAB)

## Get in touch
- <chris@plot.ly>
- [@plotlygraphs](https://twitter.com/plotlygraphs)
