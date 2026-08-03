function data = updateIsosurface(obj, isoIndex)
	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = obj.State.Plot(isoIndex).Handle;
	axisData = get(plotData, 'Parent');
	xSource = findSourceAxis(obj, axIndex);

	updateScene(obj, isoIndex, ...
		"normFacScale", 0.5, "setTitleFont", false, "handleDatetimeTicks", false)
tmpVertices = get(plotData, 'Vertices');
tmpFaces = get(plotData, 'Faces');

	data = struct( ...
		"type", "mesh3d", ...
		"name", get(plotData, 'DisplayName'), ...
		"showscale", false, ...
		"x", tmpVertices(:, 1), ...
		"y", tmpVertices(:, 2), ...
		"z", tmpVertices(:, 3), ...
		"i", tmpFaces(:, 1) - 1, ...
		"j", tmpFaces(:, 2) - 1, ...
		"k", tmpFaces(:, 3) - 1, ...
		"scene", sprintf("scene%d", xSource) ...
	);

	faceColor = getFaceColor(plotData, axisData);
	if iscell(faceColor)
		data.facecolor = faceColor;
	else
		data.color = faceColor;
	end

	if ~strcmp(get(plotData, 'FaceLighting'), "flat")
		data.lighting = struct( ...
			"diffuse", get(plotData, 'DiffuseStrength'), ...
			"ambient", get(plotData, 'AmbientStrength'), ...
			"specular", get(plotData, 'SpecularStrength'), ...
			"roughness", 0.2, ...
			"fresnel", 0.5, ...
			"vertexnormalsepsilon", 1e-12, ...
			"facenormalsepsilon", 1e-6 ...
		);
	end
end

function fillColor = getFaceColor(plotData, axisData)
	%-initializations-%
	faceColor = get(plotData, 'FaceColor');
	cData = get(plotData, 'CData');
	cLim = get(axisData, 'CLim');
	colorMap = get(axisData, 'Colormap');

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
