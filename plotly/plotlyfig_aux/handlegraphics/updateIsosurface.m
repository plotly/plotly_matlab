function data = updateIsosurface(obj, isoIndex)
	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = obj.State.Plot(isoIndex).Handle;
	axisData = plotData.Parent;
	xSource = findSourceAxis(obj, axIndex);

	updateScene(obj, isoIndex, ...
		"normFacScale", 0.5, "setTitleFont", false, "handleDatetimeTicks", false)

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
