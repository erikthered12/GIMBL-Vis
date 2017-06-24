function plot(pluginObj)

hFig = pluginObj.handles.fig;
hAx = pluginObj.handles.ax;
figure(hFig); % make hFig gcf

nViewDims = pluginObj.view.dynamic.nViewDims;
viewDims = pluginObj.view.dynamic.viewDims;

fontSize = pluginObj.view.fontSize;

hypercubeData = pluginObj.controller.activeHypercube;
plotLabels = hypercubeData.data; % TODO generalize
dimNames = hypercubeData.axisNames;
dimNames = strrep(dimNames, '_', ' '); % replace '_' with ' ' to avoid subscript
sliderVals = pluginObj.view.dynamic.sliderVals;
nAxDims = length(sliderVals);

dataAxesType = gvGetAxisType(hypercubeData);

dataTypeAxInd = find(strcmp(dataAxesType, 'dataType'));

% check if axes dataType specified
if ~isempty(dataTypeAxInd)
  dataAxisInd = sliderVals(dataTypeAxInd);
  thisSliceDataType = hypercubeData.axis(dataTypeAxInd).axismeta.dataType{dataAxisInd};
  
  if strcmp(thisSliceDataType, 'categorical')
    
    if isfield(hypercubeData.axis(dataTypeAxInd).axismeta, 'plotInfo')
      
      plotInfoBool = length(hypercubeData.axis(dataTypeAxInd).axismeta.plotInfo) >= dataAxisInd;
      
      if plotInfoBool
        thisSlicePlotInfo = hypercubeData.axis(dataTypeAxInd).axismeta.plotInfo{dataAxisInd};
      end
      
      if plotInfoBool && isfield(thisSlicePlotInfo,'labels')
        groups = thisSlicePlotInfo.labels;
      else
        thisDataTypeSliceInds = sliderVals;
        thisDataTypeSliceInds = num2cell(thisDataTypeSliceInds);
        [thisDataTypeSliceInds{setxor(dataAxisInd, 1:nAxDims)}] = deal(':');
    
        thisDataTypeSlice = plotLabels(thisDataTypeSliceInds{:});
        clear thisDataTypeSliceInds
        
        thisDataTypeSlice(cellfun(@isempty, thisDataTypeSlice)) = {''};
        groups = unique(thisDataTypeSlice);
        groups(cellfun(@isempty,groups)) = [];
        clear thisDataTypeSlice
        
        % store for future plots
        hypercubeData.axis(dataTypeAxInd).axismeta.plotInfo{dataAxisInd}.groups = groups;
      end
      nGroups = length(groups);
      
      if plotInfoBool && isfield(thisSlicePlotInfo,'colors')
        colors = thisSlicePlotInfo.colors;
      else
        colors = distinguishable_colors(nGroups);
        
        % store for future plots
        hypercubeData.axis(dataTypeAxInd).axismeta.plotInfo{dataAxisInd}.colors = colors;
      end
      
      if plotInfoBool && isfield(thisSlicePlotInfo,'markers')
        markers = thisSlicePlotInfo.markers;
      else
        markers = cell(nGroups,1);
        [markers{:}] = deal('.');
        
        % store for future plots
        hypercubeData.axis(dataTypeAxInd).axismeta.plotInfo{dataAxisInd}.markers = markers;
      end
      
      % Store legend data
      hypercubeData.meta.legend.groups = groups;
      hypercubeData.meta.legend.colors = colors;
      hypercubeData.meta.legend.markers = markers;
    end
    
  end
end

%% TODO: check axis order correct **********************************************
switch nViewDims
  case 1
    % 1 1d pane
    make1dPlot(hAx)
    
  case 2
    % 1 2d pane
    plotDims = find(viewDims);
%     if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        make2dPlot(hAx, plotDims);
%     elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
%       make2dPcolorPlot(hAx, plotDims);

      % FIXME to use pcolor, need to add extra row,col that arent used for
      % color. the x,y,z are the edge points.  uses the first point in C for the
      % interval from 1st point to second point in x,y,z. need to change axis to
      % shift by 50%, then move ticks and tick lables to center of dots, instead
      % of edges of dots
%     end
    
  case {3,4,5}
    % 3D: 3 2d panes + 1 3d pane = 4 subplots
    % 4D: 6 2d panes + 4 3d pane = 10 subplots
    % 5D: 10 2d panes + 10 3d pane = 20 subplots
    
    plotDims = find(viewDims);
    
    % 2d plots
    plotDims2d = sort(combnk(plotDims,2));
    for iAx2d = 1:size(plotDims2d, 1)
      ax2d = hAx(iAx2d);
%       if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        make2dPlot(ax2d, plotDims2d(iAx2d,:));
%       elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
%         make2dPcolorPlot(ax2d, plotDims2d(iAx,:));
%       end
    end
    
    % 3d plot
    plotDims3d = sort(combnk(plotDims,3));
    
    for iAx3d = iAx2d:iAx2d+size(plotDims3d, 1)
      ax3d = hAx(iAx3d);
      if isgraphics(ax3d) && isempty(get(ax3d,'Children'))
        make3dPlot(ax3d, plotDims3d(iAx3d-iAx2d,:))
      end
    end

  case {6, 7, 8}
    % 6D: 15 2d panes = 15 subplots
    % 7D: 21 2d panes = 21 subplots
    % 8D: 28 2d panes = 28 subplots
    
    plotDims = find(viewDims);
    
    % 2d plots
    plotDims2d = sort(combnk(plotDims,2));
    for iAx2d = 1:size(plotDims2d, 1)
      ax2d = hAx(iAx2d);
%       if strcmp(pluginObj.plotWindow.markerType, 'scatter')
        make2dPlot(ax2d, plotDims2d(iAx2d,:));
%       elseif strcmp(pluginObj.plotWindow.markerType, 'pcolor')
%         make2dPcolorPlot(ax2d, plotDims2d(iAx,:));
%       end
    end
end

hideEmptyAxes(hFig);

if nargout > 0
  varargout{1} = handles;
end

%% Sub functions
  function make3dPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    % z dim is plotDims(2)
    
    set(hFig,'CurrentAxes', hAx);

    sliceInds = sliderVals;
    sliceInds = num2cell(sliceInds);
    [sliceInds{plotDims}] = deal(':');
    
    % ax vals
    xVals = hypercubeData.axisValues{plotDims(1)};
    yVals = hypercubeData.axisValues{plotDims(2)};
    zVals = hypercubeData.axisValues{plotDims(3)};
    
    % Get grid
    [y,x,z] = meshgrid(yVals, xVals, zVals);
      %  meshgrid works differently than the linearization
    g = plotLabels(sliceInds{:});
    
    % Linearize grid
    x = x(:)';
    y = y(:)';
    z = z(:)';
    g = g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,g);
    x(emptyCells) = [];
    y(emptyCells) = [];
    z(emptyCells) = [];
    g(emptyCells) = [];
    
    plotData.x = x;
    plotData.xlabel = dimNames{plotDims(1)};
    
    plotData.y = y;
    plotData.ylabel = dimNames{plotDims(2)};
    
    plotData.z = z;
    plotData.zlabel = dimNames{plotDims(3)};
    
    plotData.g = g;
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end

    % Marker Size
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max([length(xVals), length(yVals), length(zVals)]);
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
%     if isfield(pluginObj.plotWindow, 'sliderH')
%       pluginObj.plotWindow.sliderH.Value = markerSize;
%       gvMarkerSizeSliderCallback(pluginObj.plotWindow.sliderH,[])
%     end

  % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max([length(xVals), length(yVals), length(zVals)]);
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    scatter3dPlot(plotData);
    
    % lims
    xlim([min(xVals), max(xVals)]);
    ylim([min(yVals), max(yVals)]);
    zlim([min(zVals), max(zVals)]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end
    
    % Rescale ylim
    try
      ylims = get(hAx,'ylim');
      set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
    end
    
    % Rescale zlim
    try
      zlims = get(hAx,'zlim');
      set(hAx, 'zlim', [zlims(1)- 0.05*range(zlims) zlims(2)+0.05*range(zlims)]);
    end
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end
  
  function make2dPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    
    set(hFig,'CurrentAxes', hAx);
    
    sliceInds = sliderVals;
    sliceInds = num2cell(sliceInds);
    [sliceInds{plotDims}] = deal(':');
    
    % ax vals
    xVals = hypercubeData.axisValues{plotDims(1)};
    yVals = hypercubeData.axisValues{plotDims(2)};
    
    % Get grid
    [y,x] = meshgrid(yVals, xVals);
      %  meshgrid works opposite the linearization
    g = plotLabels(sliceInds{:});
    
    % Linearize grid
    x = x(:)';
    y = y(:)';
    g = g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,g);
    x(emptyCells) = [];
    y(emptyCells) = [];
    g(emptyCells) = [];
    
    plotData.x = x;
    plotData.xlabel = dimNames{plotDims(1)};
    
    plotData.y = y;
    plotData.ylabel = dimNames{plotDims(2)};
    
    plotData.g = g;
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end
    
    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / max(length(xVals), length(yVals));
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    markerSizeSlider.Value = markerSize;
    
    scatter2dPlot(plotData);
    
    % lims
    xlim([min(xVals), max(xVals)]);
    ylim([min(yVals), max(yVals)]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end
    
    % Rescale ylim
    try
      ylims = get(hAx,'ylim');
      set(hAx, 'ylim', [ylims(1)- 0.05*range(ylims) ylims(2)+0.05*range(ylims)]);
    end
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end

  function make2dPcolorPlot(hAx, plotDims)
    % x dim is plotDims(1)
    % y dim is plotDims(2)
    
    set(hFig,'CurrentAxes', hAx);
    
    sliceInd = pluginObj.plotWindow.axInd;
    sliceInd = num2cell(sliceInd);
    [sliceInd{plotDims}] = deal(':');
    
    % Get grid
    [y,x] = meshgrid(hypercubeData.dimVals{plotDims(2)}, hypercubeData.dimVals{plotDims(1)});
      %  meshgrid works opposite the linearization
    g = plotLabels(sliceInd{:});
    
%     % Linearize grid
%     x = x(:)';
%     y = y(:)';
%     g = g(:)';
    
    % Remove empty points
%     emptyCells = cellfun(@isempty,g);
%     x(emptyCells) = [];
%     y(emptyCells) = [];
%     g(emptyCells) = [];
    
%     plotData.x = x;
%     plotData.xlabel = dimNames{plotDims(1)};
    
%     plotData.y = y;
%     plotData.ylabel = dimNames{plotDims(2)};
    
%     plotData.g = g;
    
    grpNumeric = nan(size(g));
    for iG = 1:length(groups)
      gInd = strcmp(groups, groups{iG});
      grpNumeric(gInd) = iG;
    end
    
    % add extra row and col to x,y,g
    x(end+1,:) = x(end,:);
    x(:,end+1) = x(:,end);
    y(end+1,:) = y(end,:);
    y(:,end+1) = y(:,end);
    grpNumeric(end+1,:) = grpNumeric(end,:);
    grpNumeric(:,end+1) = grpNumeric(:,end);
    
    %add min and max values for colormap to work
    grpNumeric(end,1:2) = [1, length(groups)];

    % Plot
    colormap(colors)
    pcolor(hAx, x,y,grpNumeric)
    xlabel(dimNames{plotDims(1)})
    ylabel(dimNames{plotDims(2)})
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDims;
    axObj.UserData.axLabels = dimNames(plotDims);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end

  function make1dPlot(hAx)
    set(hFig,'CurrentAxes', hAx);
    plotDim = find(viewDims);
    
    % make cell array of slice indicies
    sliceInds = sliderVals;
    sliceInds = num2cell(sliceInds);
    sliceInds{plotDim} = ':';
    
    % ax vals
    xVals = hypercubeData.axisValues{plotDim};
    
    plotData.xlabel = dimNames{plotDim};
    plotData.x = hypercubeData.axisValues{plotDim};
    plotData.y = zeros(length(plotData.x),1);
    plotData.ylabel = '';
    plotData.g = plotLabels(sliceInds{:});
    plotData.g = plotData.g(:)';
    
    % Remove empty points
    emptyCells = cellfun(@isempty,plotData.g);
    plotData.x(emptyCells) = [];
    plotData.y(emptyCells) = [];
    plotData.g(emptyCells) = [];
    
    plotData.clr = [];
    plotData.sym = '';
    for grp = unique(plotData.g)
      gInd = strcmp(groups, grp);
      thisClr = colors(gInd,:);
      thisSym = markers{gInd};
      plotData.clr(end+1,:) = thisClr;
      plotData.sym = [plotData.sym thisSym];
    end
    
    % Marker Size
    markerSizeSlider = findobjReTag('plot_panel_markerSizeSlider');
    autoSizeMarkerCheckboxHandle = findobjReTag('plot_panel_autoSizeToggle');
    if autoSizeMarkerCheckboxHandle.Value %auto size marker
      axUnit = get(hAx,'unit');
      set(hAx,'unit', 'pixels');
      pos = get(hAx,'position');
      axSize = pos(3:4);
      markerSize = min(axSize) / length(xVals);
      plotData.siz = markerSize;
      set(hAx,'unit', axUnit);
    else %manual size marker
      markerSize = markerSizeSlider.Value;
      plotData.siz = markerSize;
    end
    
    % Set MarkerSize Slider Val
    markerSizeSlider.Value = markerSize;
    
    scatter2dPlot(plotData);
    
    % lims
    xlim([min(hypercubeData.axisValues{plotDim}), max(hypercubeData.axisValues{plotDim})]);
    
    % Rescale xlim
    try
      xlims = get(hAx,'xlim');
      set(hAx, 'xlim', [xlims(1)- 0.05*range(xlims) xlims(2)+0.05*range(xlims)]);
    end

    set(hAx,'YTick', []);
    
    axObj = get(hFig,'CurrentAxes');
    axObj.UserData = [];
    axObj.UserData.plotDims = plotDim;
    axObj.UserData.axLabels = dimNames(plotDim);
    axObj.FontSize = fontSize;
    axObj.FontWeight = 'Bold';
  end

  function scatter2dPlot(plotData)
    try
      gscatter(plotData.x,plotData.y,categorical(plotData.g),plotData.clr,plotData.sym,plotData.siz,'off',plotData.xlabel,plotData.ylabel)
    end
  end

  function scatter3dPlot(plotData)
    %     [uniqueGroups, uga, ugc] = unique(group);
    %     colors = colormap;
    %     markersize = 20;
    %     scatter3(x(:), y(:), z(:), markersize, colors(ugc,:));
    
    try
      [~, ~, groupInd4color] = unique(plotData.g);
      
%       plotData.sym

      scatter3(plotData.x, plotData.y, plotData.z, plotData.siz, plotData.clr(groupInd4color,:), '.');
      
      xlabel(plotData.xlabel)
      ylabel(plotData.ylabel)
      zlabel(plotData.zlabel)
      
%       if handles.MainWindow.legendBool
%         uG = unique(plotData.g);
%         [lH,icons] = legend(uG); % TODO: hide legend before making changes   
% 
%         % Increase legend width
%     %     lPos = lH.Position;
%     %     lPos(3) = lPos(3) * 1.05; % increase width of legend
%     %     lH.Position = lPos;
% 
%         [icons(1:length(uG)).FontSize] = deal(lFontSize);
%         [icons(1:length(uG)).FontUnits] = deal('normalized');
% 
%         shrinkText2Fit(icons(1:length(uG)))
% 
%         [icons(length(uG)+2:2:end).MarkerSize] = deal(lMarkerSize);
%         
% %         legend(hFig,'boxoff')
% %         legend(hFig,'Location','SouthEast')
%       end
    end
  end

  function shrinkText2Fit(txtH)
    for iTxt=1:length(txtH)
      % Check width
      ex = txtH(iTxt).Extent;
      bigBool = ( (ex(1) + ex(3)) > 1 );
      while bigBool
        txtH(iTxt).FontSize = txtH(iTxt).FontSize * 0.99;
        ex = txtH(iTxt).Extent;
        bigBool = ( (ex(1) + ex(3)) > 1 );
      end
    end
  end

end
