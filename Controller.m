function Controller
% Reads one data packet at a time and plots

clear all

Acti = ActiChamp;
h = view_data(Acti);

set(h.fig,'CloseRequestFcn',{@onWindowClose,Acti});
set(h.Settings.btConnect,'Callback',{@onConnect,Acti});
set(h.Settings.lstChannels,'Callback',{@onChannelSelect,h});

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

end