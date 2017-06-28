function makePlotPanelControls(pluginObj, parentHandle)
%% makePlotPanelControls
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
spacing = 2; % px
padding = 2; % px

uiControlsHandles = struct();

% Make grid
grid = uix.Grid('Parent',parentHandle, 'Spacing',spacing, 'Padding',padding);

% (1,1)
% openPlotButton
thisTag = pluginObj.panelTag('openPlotButton');
uiControlsHandles.openPlotButton = uicontrol(...
'Tag',thisTag,...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Open Plot',...
'UserData',pluginObj.userData,...
'Callback',pluginObj.callbackHandle(thisTag),...
'Parent',grid);

% (1,2)
% showLegendButton
thisTag = pluginObj.panelTag('showLegendButton');
uiControlsHandles.showLegendButton = uicontrol(...
'Tag',thisTag,...
'Style','pushbutton',...
'FontUnits','points',...
'FontSize',fontSize,...
'String','Show Legend',...
'UserData',pluginObj.userData,...
'Callback',pluginObj.callbackHandle(thisTag),...
'Parent',grid);

% Set layout sizes
set(grid, 'Heights',[-1], 'Widths',[-1 -1]);

end
