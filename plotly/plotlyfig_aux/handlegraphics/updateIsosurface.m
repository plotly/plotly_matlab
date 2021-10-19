function obj = updateIsosurface(obj, isoIndex)

    %-------------------------------------------------------------------------%

	%-INITIALIZATIONS-%

	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = get(obj.State.Plot(isoIndex).Handle);
	axisData = get(plotData.Parent);
	[xSource, ySource] = findSourceAxis(obj, axIndex);

	%-update scene-%
	updateScene(obj, isoIndex)

	%-get mesh data-%
	xData = plotData.Vertices(:, 1);
	yData = plotData.Vertices(:, 2);
	zData = plotData.Vertices(:, 3);

	iData = plotData.Faces(:, 1) - 1;
	jData = plotData.Faces(:, 2) - 1;
	kData = plotData.Faces(:, 3) - 1;

	%-------------------------------------------------------------------------%

	%-get trace-%
	obj.data{isoIndex}.type = 'mesh3d';
	obj.data{isoIndex}.name = plotData.DisplayName;
	obj.data{isoIndex}.showscale = false;

	%-------------------------------------------------------------------------%	

	%-set mesh data-%
	obj.data{isoIndex}.x = xData;
	obj.data{isoIndex}.y = yData;
	obj.data{isoIndex}.z = zData;

	obj.data{isoIndex}.i = iData;
	obj.data{isoIndex}.j = jData;
	obj.data{isoIndex}.k = kData;

	%-------------------------------------------------------------------------%

	%-mesh coloring-%
	faceColor = getFaceColor(plotData, axisData);

	if iscell(faceColor)
		obj.data{isoIndex}.facecolor = faceColor;
	else
		obj.data{isoIndex}.color = faceColor;
	end

	%-------------------------------------------------------------------------%

	%-lighting settings-%
	if ~strcmp(plotData.FaceLighting, 'flat')
		obj.data{isoIndex}.lighting.diffuse = plotData.DiffuseStrength;
		obj.data{isoIndex}.lighting.ambient = plotData.AmbientStrength;
		obj.data{isoIndex}.lighting.specular = plotData.SpecularStrength;
		obj.data{isoIndex}.lighting.roughness = 0.2;
		obj.data{isoIndex}.lighting.fresnel = 0.5;
		obj.data{isoIndex}.lighting.vertexnormalsepsilon = 1e-12;
		obj.data{isoIndex}.lighting.facenormalsepsilon = 1e-6;
	end

	%-------------------------------------------------------------------------%

	%-associate scene to trace-%
	obj.data{isoIndex}.scene = sprintf('scene%d', xSource);

	%-------------------------------------------------------------------------%
end

function updateScene(obj, isoIndex)

	%-INITIALIZATIONS-%
	axIndex = obj.getAxisIndex(obj.State.Plot(isoIndex).AssociatedAxis);
	plotData = get(obj.State.Plot(isoIndex).Handle);
	axisData = get(plotData.Parent);
	[xSource, ySource] = findSourceAxis(obj, axIndex);
	scene = eval( sprintf('obj.layout.scene%d', xSource) );

	aspectRatio = axisData.PlotBoxAspectRatio;
	cameraPosition = axisData.CameraPosition;
	dataAspectRatio = axisData.DataAspectRatio;
	cameraUpVector = axisData.CameraUpVector;
	cameraEye = cameraPosition./dataAspectRatio;
	normFac = 0.5*abs(min(cameraEye));

	%-aspect ratio-%
	scene.aspectratio.x = aspectRatio(1);
	scene.aspectratio.y = aspectRatio(2);
	scene.aspectratio.z = aspectRatio(3);

	%-camera eye-%
	scene.camera.eye.x = cameraEye(1) / normFac;
    scene.camera.eye.y = cameraEye(2) / normFac;
    scene.camera.eye.z = cameraEye(3) / normFac;

    %-camera up-%
    scene.camera.up.x = cameraUpVector(1); 
    scene.camera.up.y = cameraUpVector(2);
    scene.camera.up.z = cameraUpVector(3);

    %-camera projection-%
    % scene.camera.projection.type = axisData.Projection;

	%-scene axis configuration-%
	scene.xaxis.range = axisData.XLim;
	scene.yaxis.range = axisData.YLim;
	scene.zaxis.range = axisData.ZLim;

	scene.xaxis.zeroline = false;
	scene.yaxis.zeroline = false;
	scene.zaxis.zeroline = false;

	scene.xaxis.showline = true;
	scene.yaxis.showline = true;
	scene.zaxis.showline = true;

	scene.xaxis.ticklabelposition = 'outside';
	scene.yaxis.ticklabelposition = 'outside';
	scene.zaxis.ticklabelposition = 'outside';

	scene.xaxis.title = axisData.XLabel.String;
	scene.yaxis.title = axisData.YLabel.String;
	scene.zaxis.title = axisData.ZLabel.String;

	%-tick labels-%
	scene.xaxis.tickvals = axisData.XTick;
	scene.xaxis.ticktext = axisData.XTickLabel;
	scene.yaxis.tickvals = axisData.YTick;
	scene.yaxis.ticktext = axisData.YTickLabel;
	scene.zaxis.tickvals = axisData.ZTick;
	scene.zaxis.ticktext = axisData.ZTickLabel;

	scene.xaxis.tickcolor = 'rgba(0,0,0,1)';
	scene.yaxis.tickcolor = 'rgba(0,0,0,1)';
	scene.zaxis.tickcolor = 'rgba(0,0,0,1)';
	scene.xaxis.tickfont.size = axisData.FontSize;
	scene.yaxis.tickfont.size = axisData.FontSize;
	scene.zaxis.tickfont.size = axisData.FontSize;
	scene.xaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
	scene.yaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);
	scene.zaxis.tickfont.family = matlab2plotlyfont(axisData.FontName);

	%-grid-%
	if strcmp(axisData.XGrid, 'off'), scene.xaxis.showgrid = false; end
	if strcmp(axisData.YGrid, 'off'), scene.yaxis.showgrid = false; end
	if strcmp(axisData.ZGrid, 'off'), scene.zaxis.showgrid = false; end

	%-SET SCENE TO LAYOUT-%
	obj.layout = setfield(obj.layout, sprintf('scene%d', xSource), scene);
end

function fillColor = getFaceColor(plotData, axisData)

	%-initializations-%
	faceColor = plotData.FaceColor;
	cData = plotData.CData;
	cLim = axisData.CLim;
	colorMap = axisData.Colormap;
	
	%-get face color depending of faceColor attribute
	if isnumeric(faceColor)
		numColor = 255 * faceColor;
		fillColor = sprintf('rgb(%f,%f,%f)', numColor);

	elseif strcmpi(faceColor, 'flat')
		fillColor = getStringColor(cData, colorMap, cLim);

    elseif strcmpi(faceColor, 'interp')
    	if size(cData, 1) ~= 1
    		for n = 1:size(cData, 2)
				fillColor{n} = getStringColor(mean(cData(:, n)), colorMap, cLim);
    		end
    	else
    		% TODO
    	end
	end
end

function stringColor = getStringColor(cData, colorMap, cLim)
	nColors = size(colorMap, 1);
	cIndex = max( min( cData, cLim(2) ), cLim(1) );
    scaleColor = (cIndex - cLim(1)) / diff(cLim);
    cIndex = 1 + floor(scaleColor*(nColors-1));
    numColor =  255 * colorMap(cIndex, :);
    stringColor = sprintf('rgb(%f,%f,%f)', numColor);
end