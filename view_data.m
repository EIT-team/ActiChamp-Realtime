function handles = view_data(obj) 

    %Do initial plot
    handles = initGUI();
    handles.settings.ChanToPlot =1;
    % set(handles,'XDataMode','manual')

        %Define listeners to respond to GUI/Data events
    addlistener (obj, 'data_buf', 'PostSet', @(o,e) onNewData(handles,e.AffectedObject));
    addlistener (obj, 'channelNames', 'PostSet', @(o,e) onPropChange(handles,e.AffectedObject));
end

function handles = initGUI()

    %Load layout from GUIDE figure
    hFig = hgload('fig_layout.fig');
           
    
   %Define tab grounp
   
   %Can't create tabs using GUIDE, so get tabs location from 'helper' panel
   %object.
   hPlotPanel = findobj(hFig,'tag','Plotpanel');
   hTabGroupPlot = uitabgroup('Parent',hFig, 'Units', get(hPlotPanel,'Units'),'Position',get(hPlotPanel,'Position'));
    
    %Settings panel
    hSettingsPanel = findobj(hFig, 'tag' ,'settingsPanel');
    
    lblHost =  findobj(hFig, 'tag' , 'lblHost');
    editHostIP =  findobj(hFig, 'tag' , 'editHostIP');
    btConnect =  findobj(hFig, 'tag' , 'btConnect');
    lblRange =  findobj(hFig, 'tag' , 'lblRange');
    editRange =  findobj(hFig, 'tag' , 'editRange');
    chanSelect =  findobj(hFig, 'tag' , 'lstChannels');
    lblTime = findobj(hFig,'tag','lblTime');
    editTime = findobj(hFig,'tag','editTime');
    
    
    handles_Settings = struct(  'HostIP',editHostIP, 'btConnect',btConnect, 'Range',editRange,...
                                'lstChannels',chanSelect,'Time',editTime);
    
    % *** Default tab
    
    hTabPlotEEG = uitab('Parent', hTabGroupPlot, 'Title', 'Default');
                      
    % construct the axes to display time and frequency domain data
    % Axes are defined as children of panel object in GUIDE, need to change
    % this to the tab being used.
    axTime = findobj(hFig,'tag', 'axTime');
    set(axTime,'Parent',hTabPlotEEG);
    axFreq = findobj(hFig,'tag', 'axFreq');
    set(axFreq,'Parent',hTabPlotEEG);  
    
    hTime = plot(axTime,(1:10)/10);
    hFreq = plot(axFreq,(1:10)/10);
    
    handles_TabPlotEEG = struct('tab',hTabPlotEEG, 'axTime',axTime, 'axFreq',axFreq, 'plotTime',hTime, 'plotFreq',hFreq);
    
    % *** DC Offset Tab ***
    hTabDC = uitab('Parent', hTabGroupPlot, 'Title', 'DC Offset');


                     
    axDC = axes('Parent',hTabDC,'Units','Pixels','Position',[75,75,500,500]);
    hBar = bar(axDC,1:16,1:16);
    xlabel('Channel');
    ylabel( 'DC Offset (mV)');

    handles_tabDC = struct('tab',hTabDC, 'ax',axDC, 'bar',hBar);
    
    % Assign the GUI a name to appear in the window title.
    set(hFig,'Name','Brain Vision RDA Client for MATLAB')
    % Move the GUI to the center of the screen.
    movegui(hFig,'center')
    % Make the GUI visible.
    set(hFig,'Visible','on'); 

    handles = struct('fig',hFig, 'tabGroup',hTabGroupPlot, 'Settings',handles_Settings, 'tabDC',handles_tabDC, 'tabPlotEEG',handles_TabPlotEEG);

    
end

function onNewData(handles,obj)

    %Only update graph for active tab
    active_tab = get(handles.tabGroup,'SelectedIndex');
    switch active_tab
        case 1
            updateEEGPlot(handles,obj)
            
        case 2
            updateDCOffset(handles,obj)
    end
end

function updateEEGPlot(handles,obj)
%Update this to plot whichever channel(s) are selected
selectedChan = get(handles.Settings.lstChannels,'Value');
set(handles.tabPlotEEG.plotTime,'YData',obj.data_buf(selectedChan,:))

end

function updateDCOffset(handles,obj)

    set(handles.tabDC.bar,'YData',mean(obj.EEG_packet,2));

end



function onPropChange(handles,obj)
% Populate list box with channel names
set(handles.Settings.lstChannels,'String',obj.props.channelNames);
end