function openWindow(pluginObj)

% check for main window
warnBool = true;
mainWindowExistBool = pluginObj.view.checkMainWindowExists(warnBool);

if mainWindowExistBool && ~pluginObj.checkWindowExists()
    %% Make Image Window
    if pluginObj.makeFig() ~= 0
      return % error
    end
    
    pluginObj.addWindowOpenedListenerToPlotPlugin();
    pluginObj.addMouseButtonCallbackToPlotFig();
    
    % reset fig2copy
    pluginObj.fig2copy = [];
    
    notify(pluginObj, 'windowOpened');
end

end