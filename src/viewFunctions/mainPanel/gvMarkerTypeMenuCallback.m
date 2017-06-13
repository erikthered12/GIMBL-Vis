function gvMarkerTypeMenuCallback(hObject, eventdata, handles)

% if new val, then replot
if hObject.UserData.lastVal ~= hObject.Value
  handles.PlotWindow.markerType = hObject.String{hObject.Value};
  gvPlot(hObject, eventdata, handles);
  
  %Update last value
  hObject.UserData.lastVal = hObject.Value;

  % Update handles structure
  guidata(hObject, handles);
end

end