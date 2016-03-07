function Controller
% Reads one data packet at a time and plots

clear all

Acti = ActiChamp;
h = view_data(Acti);

set(h.fig,'CloseRequestFcn',{@onWindowClose,Acti});
set(h.Settings.btConnect,'Callback',{@onConnect,Acti});
set(h.Settings.lstChannels,'Callback',{@onChannelSelect,h});
set(h.Settings.Time,'Callback',{@onTimeChange,Acti});
set(h.Settings.Range,'Callback',{@onRangeChange,h});

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

function onRangeChange(self,eventdata,h)
Range = 1e3*str2num(get(self,'String'));
if (Range)
set(h.tabDC.ax,'YLim',[-Range Range]);
set(h.tabPlotEEG.axTime,'YLim',[-Range Range]);
end
end

function onTimeChange(self,eventdata,obj)

Time = str2num(get(self,'String'));
if (Time)
obj.len_data_buf = Time;
end

end