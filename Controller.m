function Controller
% Creates Actichamp and GUI objects
% Sets up callbacks for GUI elements
% Tom Dowrick 8.3.2016

%Suppress warnings
warning('off','MATLAB:colon:nonIntegerIndex') %Non-integer indexes used on Noise tab
warning('off','MATLAB:uitabgroup:OldVersion') %uitabgroup command is depricated

clear all

Acti = ActiChamp;
handles = Viewer(Acti);

%Create callbacks for buttons, text boxes etc
set(handles.fig,'CloseRequestFcn',{@onWindowClose,Acti});
set(handles.Settings.btConnect,'Callback',{@onConnect,Acti});
set(handles.Settings.lstChannels,'Callback',{@onChannelSelect,handles});
set(handles.Settings.Time,'Callback',{@onTimeChange,Acti,handles});
set(handles.Settings.Range,'Callback',{@onRangeChange,handles});
set(handles.Settings.HostIP,'Callback',{@onNewIP,Acti});

%Callbacks for updating filter if any coefficents changed
set(handles.Settings.chkFilter,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltFreq,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltBW,'Callback',{@initFilter,Acti,handles});
set(handles.Settings.FiltOrder,'Callback',{@initFilter,Acti,handles});

set(handles.Settings.FiltUpdateTime,'Callback',{@updateFiltTime,handles});


%Set filter to initial values
initFilter([],[],Acti,handles)
end

function onWindowClose(self,eventdata,Acti)
% Delete Actichamp object on window close
%   self - triggering object
%   eventdata - not used
%   Acti - Actichamp object

selection = questdlg(['Close Actichamp Client?'],...
    ['Closing...'],...
    'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

Acti.finish = 1;

% Delete and close the window
delete(self);



end

function onConnect(self,eventdata,Acti)
% Connect/disconnect to Actichamp hardware
%   self - triggering object
%   eventdata - not used
%   Acti - Actichamp object

text = get(self, 'String');
if strcmp(text, 'Connect')
    set(self,'String','Disconnect');
    Acti.Go()
else
    Acti.finish = 1;
    set(self,'String','Connect');
end

end

function onChannelSelect(self,eventdata,h)
% Choose what channel(s) to plot
% self - triggering object
% eventdata - not used
% h - handles to GUI objects

h.chansToPlot = get(self,'Value');

end

function onRangeChange(self,eventdata,h)
% Update voltage range (y-axis)
% self - triggering object
% eventdata - not used
% h - handles to GUI objects

Range = 1e3*str2num(get(self,'String'));
if (Range)
    set(h.tabDC.ax,'YLim',[-Range Range]);
    set(h.tabPlotEEG.axTime,'YLim',[-Range Range]);
    
end
end

function onTimeChange(self,eventdata,Acti,h)
% Update Time range (x-axis)
% self - triggering object
% eventdata - not used
% h - handles to GUI objects

Time = str2num(get(self,'String'));
if (Time)
    Acti.max_data_buf = Time;
    set(h.tabPlotEEG.axTime,'XLim',[0 Time])
    set(h.tabPlotEEG.axFilt,'XLim',[0 Time])
end

end

function onNewIP(self,eventdata,Acti)
Acti.IP = get(self,'String');
end

function initFilter(self,eventdata,Acti,h)
% Compute filter coefficients
% self - triggering object
% eventdata - not used
% Acti - Actichamp object
% h - handles to GUI objects

%Get values and check if numeric
h.filtOrder = get(h.Settings.FiltOrder,'Value');
h.filtFreq = str2num(get(h.Settings.FiltFreq,'String'));
h.filtBW = str2num(get(h.Settings.FiltBW,'String'));

if isnumeric([h.filtOrder,h.filtFreq,h.filtBW])
    %Set coefficients
    [h.filtercoeffs.b, h.filtercoeffs.a] = butter(...
        h.filtOrder, (h.filtFreq + [-h.filtBW, h.filtBW])./(Acti.Fs./2));
end
end

function updateFiltTime(self,eventdata,h)
% Set how often filter plot is updated (in seconds)
% self - triggering object
% eventdata - not used
% % h - handles to GUI objects

Time = str2num(get(self,'String'));
if (Time)
    h.filtUpdateTime = Time;
end

end