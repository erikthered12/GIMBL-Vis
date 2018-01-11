function plotData(pluginObj, index)
% TODO: handle missing data

% update stored index
pluginObj.lastIndex = index;

modelObj = pluginObj.controller.model;

if isfield(modelObj.activeHypercube.meta, 'simData')
  data = modelObj.activeHypercube.meta.simData;
else
  wprintf('DS Data not imported. Tip: click the "Import All DS Data" button in DsPlot');
  return
end

figH = pluginObj.handles.fig;

if ~isempty(data) && length(data) >= index
  thisData = data(index);
  
  clf(figH);
  plotAxH = makeBlankAxes(figH);
  addTextToBlankAx(plotAxH, sprintf('Plotting index %i...', index) );
  
  % plot
  plotFn = str2func(pluginObj.metadata.plotFn);
  try
    plotFnOpts = eval(['{' pluginObj.metadata.plotFnOpts ' ''visible'',''off''' '}']);
  catch
    wprintf('Could not evaluate dsPlot "Function Options".')
    pluginObj.fig2copy = [];
    close(plotFn)
    return
  end
  plotH = feval(plotFn, thisData, plotFnOpts{:});
  pluginObj.fig2copy = plotH; % allows lock in Callback_mouseMove
  
  % copy axes from plotFn handle output
  axh = findobj(plotH,'type','axes');
  copyobj(axh, figH);
  plotAxH = findobj(figH.Children,'type','axes');
  
  % close hidden plot from plotFn eval
  pluginObj.fig2copy = [];
  close(plotH)
    
  % fig title
  figTitle = sprintf('SimID:%i; Vary:', index);
  for varInd = 1:length(thisData.varied)
    thisVary = thisData.varied{varInd};
    figTitle = sprintf('%s %s=%g,', figTitle, strrep(thisVary,'_','\_'), thisData.(thisVary)); % replace '_' with '\_' to avoid subscript
  end
  figTitle(end) = ''; % remove trailing comma
  
  suptitle2(figTitle, figH);
else
  clf(figH);
  plotAxH = makeBlankAxes(figH);

  addTextToBlankAx(plotAxH, sprintf('No data found for index %i', index) );
end

end

%% Local Fn
function addTextToBlankAx(axH, str)
text(axH, 0.1,0.5, str,...
  'FontUnits','normalized', 'FontSize',0.06);
end