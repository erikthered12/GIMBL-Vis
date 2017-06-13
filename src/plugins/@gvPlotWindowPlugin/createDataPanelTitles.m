function createDataPanelTitles(pluginObj, parentHandle)
%% createDataPanelTitles
%
% Input: parentHandle - handle for uicontrol parent

fontSize = pluginObj.fontSize;
titleFontWeight = 'bold';

padding = 5; % px

dataTitlesHbox = uix.HBox('Parent',parentHandle, 'Padding', padding);

uiControlsHandles = struct();

% varTitle
uiControlsHandles.varTitle = uicontrol(...
  'Tag','varTitle',...
  'Style','text',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'FontWeight',titleFontWeight,...
  'String','Variables',...
  'Value',get(0,'defaultuicontrolValue'),...
  'Parent',dataTitlesHbox);

% valueTitle
uiControlsHandles.valueTitle = uicontrol(...
  'Tag','valueTitle',...
  'Style','text',...
  'FontUnits','points',...
  'FontSize',fontSize,...
  'FontWeight',titleFontWeight,...
  'String','Value',...
  'Parent',dataTitlesHbox);

uix.Empty('Parent',dataTitlesHbox);

% viewTitle
uiControlsHandles.viewTitle = uicontrol(...
  'Tag','viewTitle',...
  'Style','text',...
  'FontUnits','points',...
  'FontWeight',titleFontWeight,...
  'String','View',...
  'FontSize',fontSize,...
  'Parent',dataTitlesHbox);

% lockTitle
uiControlsHandles.lockTitle = uicontrol(...
  'Tag','lockTitle',...
  'Style','text',...
  'FontUnits','points',...
  'FontWeight',titleFontWeight,...
  'String','Lock',...
  'FontSize',fontSize,...
  'Parent',dataTitlesHbox);

set(dataTitlesHbox, 'Widths',[-5,-6,-2.5,40,40])

% Store Handles
% pluginObj.handles.dataPanel.controls = uiControlsHandles;

end
