function data = updateIsosurface(obj, isoIndex)
	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = obj.State.Plot(isoIndex).Handle;
	axisData = plotData.Parent;
	xSource = findSourceAxis(obj, axIndex);

	updateScene(obj, isoIndex)

	data = struct( ...
		"type", "mesh3d", ...
		"name", plotData.DisplayName, ...
		"showscale", false, ...
		"x", plotData.Vertices(:, 1), ...
		"y", plotData.Vertices(:, 2), ...
		"z", plotData.Vertices(:, 3), ...
		"i", plotData.Faces(:, 1) - 1, ...
		"j", plotData.Faces(:, 2) - 1, ...
		"k", plotData.Faces(:, 3) - 1, ...
		"scene", "scene" + xSource ...
	);

	faceColor = getFaceColor(plotData, axisData);
	if iscell(faceColor)
		data.facecolor = faceColor;
	else
		data.color = faceColor;
	end

	if plotData.FaceLighting ~= "flat"
		data.lighting = struct( ...
			"diffuse", plotData.DiffuseStrength, ...
			"ambient", plotData.AmbientStrength, ...
			"specular", plotData.SpecularStrength, ...
			"roughness", 0.2, ...
			"fresnel", 0.5, ...
			"vertexnormalsepsilon", 1e-12, ...
			"facenormalsepsilon", 1e-6 ...
		);
	end
end

function updateScene(obj, isoIndex)
	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = obj.State.Plot(isoIndex).Handle;
	axisData = plotData.Parent;
	xSource = findSourceAxis(obj, axIndex);
	scene = obj.layout.("scene" + xSource);

	aspectRatio = axisData.PlotBoxAspectRatio;
	cameraPosition = axisData.CameraPosition;
	dataAspectRatio = axisData.DataAspectRatio;
	cameraUpVector = axisData.CameraUpVector;
	cameraEye = cameraPosition./dataAspectRatio;
	normFac = 0.5*abs(min(cameraEye));

	scene.aspectratio.x = aspectRatio(1);
	scene.aspectratio.y = aspectRatio(2);
	scene.aspectratio.z = aspectRatio(3);

	scene.camera.eye.x = cameraEye(1) / normFac;
    scene.camera.eye.y = cameraEye(2) / normFac;
    scene.camera.eye.z = cameraEye(3) / normFac;

    scene.camera.up.x = cameraUpVector(1);
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

	scene.xaxis.range = axisData.XLim;
	scene.xaxis.zeroline = false;
	scene.xaxis.showline = true;
	scene.xaxis.ticklabelposition = "outside";
	scene.xaxis.title = axisData.XLabel.String;
	scene.xaxis.tickvals = axisData.XTick;
	scene.xaxis.ticktext = axisData.XTickLabel;
	scene.xaxis.tickcolor = "rgba(0,0,0,1)";
	scene.xaxis.tickfont.size = axisData.FontSize;
	scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

	scene.yaxis.range = axisData.YLim;
	scene.yaxis.zeroline = false;
	scene.yaxis.showline = true;
	scene.yaxis.ticklabelposition = "outside";
	scene.yaxis.title = axisData.YLabel.String;
	scene.yaxis.tickvals = axisData.YTick;
	scene.yaxis.ticktext = axisData.YTickLabel;
	scene.yaxis.tickcolor = "rgba(0,0,0,1)";
	scene.yaxis.tickfont.size = axisData.FontSize;
	scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

	scene.zaxis.range = axisData.ZLim;
	scene.zaxis.zeroline = false;
	scene.zaxis.showline = true;
	scene.zaxis.ticklabelposition = "outside";
	scene.zaxis.title = axisData.ZLabel.String;
	scene.zaxis.tickvals = axisData.ZTick;
	scene.zaxis.ticktext = axisData.ZTickLabel;
	scene.zaxis.tickcolor = "rgba(0,0,0,1)";
	scene.zaxis.tickfont.size = axisData.FontSize;
	scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

	if axisData.XGrid == "off"
	    scene.xaxis.showgrid = false;
	end
	if axisData.YGrid == "off"
	    scene.yaxis.showgrid = false;
	end
	if axisData.ZGrid == "off"
	    scene.zaxis.showgrid = false;
	end

	obj.layout.("scene" + xSource) = scene;
end

function fillColor = getFaceColor(plotData, axisData)
	%-initializations-%
	faceColor = plotData.FaceColor;
	cData = plotData.CData;
	cLim = axisData.CLim;
	colorMap = axisData.Colormap;

	%-get face color depending of faceColor attribute
	if isnumeric(faceColor)
		fillColor = getStringColor(round(255*faceColor));
	elseif strcmpi(faceColor, "flat")
		fillColor = getColor(cData, colorMap, cLim);
    elseif strcmpi(faceColor, "interp")
    	if size(cData, 1) ~= 1
    		for n = 1:size(cData, 2)
				fillColor{n} = getColor(mean(cData(:, n)), colorMap, cLim);
    		end
    	else
    		% TODO
    	end
	end
end

function color = getColor(cData, colorMap, cLim)
	nColors = size(colorMap, 1);
	cIndex = max(min(cData, cLim(2)), cLim(1));
    scaleColor = (cIndex - cLim(1)) / diff(cLim);
    cIndex = 1 + floor(scaleColor*(nColors-1));
    color = getStringColor(round(255 * colorMap(cIndex, :)));
end
