function Controller

clear all

Acti = ActiChamp;
handles = Viewer(Acti);

set(handles.fig,'CloseRequestFcn',{@onWindowClose,Acti});
set(handles.Settings.btConnect,'Callback',{@onConnect,Acti});
set(handles.Settings.lstChannels,'Callback',{@onChannelSelect,handles});
set(handles.Settings.Time,'Callback',{@onTimeChange,Acti,handles});
set(handles.Settings.Range,'Callback',{@onRangeChange,handles});

%Callbacks for updating filter if any coefficents changed
set(handles.Settings.chkFilter,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltFreq,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltBW,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltOrder,'Callback',{@initFilter,Acti,handles});

end

function onWindowClose(self,eventdata,obj)

selection = questdlg(['Close MATLAB RDA Client?'],...
    ['Closing...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

obj.finish = 1;

% Delete and close the window
delete(self);



end

function onConnect(self,eventdata,obj)

text = get(self, 'String');
if strcmp(text, 'Connect')
    set(self,'String','Disconnect');
    obj.Go()
else
    obj.finish = 1;
    set(self,'String','Connect');
end

end

function onChannelSelect(self,eventdata,h)
            h.chansToPlot = get(self,'Value');
            
end

function onRangeChange(self,eventdata,h)
Range = 1e3*str2num(get(self,'String'));
if (Range)
    set(h.tabDC.ax,'YLim',[-Range Range]);
    set(h.tabPlotEEG.axTime,'YLim',[-Range Range]);
end
end

function onTimeChange(self,eventdata,Acti,h)

Time = str2num(get(self,'String'));
if (Time)
    Acti.len_data_buf = Time;
    
    %     set(h.tabPlotEEG.axTime,'XLim',[0 Time])
end

end

function initFilter(self,eventdata,Acti,h)

%Get values and check if numeric
h.filtOrder = get(h.Settings.FiltOrder,'Value');
h.filtFreq = str2num(get(h.Settings.FiltFreq,'String'));
h.filtBW = str2num(get(h.Settings.FiltBW,'String'));

if isnumeric([h.filtOrder,h.filtFreq,h.filtBW])
    
    [h.filtercoeffs.b, h.filtercoeffs.a] = butter(...
        h.filtOrder, (h.filtFreq + [-h.filtBW, h.filtBW])./(Acti.Fs./2));
end
end