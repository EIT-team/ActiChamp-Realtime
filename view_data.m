function handles = view_data(obj) 

    %Do initial plot
    handles = initGUI();
    handles.settings.ChanToPlot =1;
    % set(handles,'XDataMode','manual')

        %Define listeners to respond to GUI/Data events
    addlistener (obj, 'data_buf', 'PostSet', @(o,e) onNewData(handles,e.AffectedObject));
    addlistener (handles.Settings.Range, 'String', 'PostSet', @(o,e) onNewDataRange(handles,e.AffectedObject));
    addlistener (obj, 'channelNames', 'PostSet', @(o,e) onPropChange(handles,e.AffectedObject));
end

function handles = initGUI()

    hFig = figure('Visible','off','Position',[0,0,800,700],'ToolBar','none');
           
    
   %Define tab grounp
   
    hTabGroupPlot = uitabgroup('Parent',hFig, 'Position',[0.2 0.05 0.75 0.9]);
    
    %Settings panel
    hSettingsPanel = uipanel('Parent',hFig, 'Position',[0.02 0.05 0.15 0.9]);
    
    lblHost = uicontrol(    'Parent',hSettingsPanel,'Style','text','String','Host IP:',...
                            'BackgroundColor',get(hFig,'Color'),'Position',[35, 590, 50, 20]);
                        
    editHostIP = uicontrol( 'Parent',hSettingsPanel,'Style','edit','String','128.40.45.70',...
                            'Position',[5,570,100,16]);
                        
    btConnect = uicontrol(  'Parent',hSettingsPanel,'Style','pushbutton','String','Connect',...
                            'Position',[5,550,100,16]);
                        
    lblRange = uicontrol(   'Parent',hSettingsPanel,'Style','text','String','Voltage Range (mV):',...
                            'Position',[0,500,115,16]);
                        
    editRange = uicontrol(  'Parent',hSettingsPanel,'Style','edit','String','10',...
                            'Position',[5,480,100,16]);
                        
    chanSelect = uicontrol ('Parent',hSettingsPanel,'Style','listbox','Position',[5,300,100,160]);
    
    handles_Settings = struct(  'HostIP',editHostIP, 'btConnect',btConnect, 'Range',editRange,...
                                'lstChannels',chanSelect);
    
    % *** Default tab
    hTabPlotEEG = uitab('Parent', hTabGroupPlot, 'Title', 'Default');


                      
    % construct the axes to display time and frequency domain data
    axTime = axes('Parent',hTabPlotEEG,'Units','Pixels','Position',[25,240,590,180]); 
    axFreq = axes('Parent',hTabPlotEEG,'Units','Pixels','Position',[25,25,590,180]); 
   
    hTime = plot(axTime,1:10);
    hFreq = plot(axFreq,1:10);
    
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

function onNewDataRange(handles,obj)
range = 1e3*str2num(get(handles.Settings.Range,'String'));
set(handles.tabDC.ax,'YLim',[-range range]);
set(handles.tabPlotEEG.axTime,'YLim',[-range range]);

end

function onPropChange(handles,obj)
% Populate list box with channel names
set(handles.Settings.lstChannels,'String',obj.props.channelNames);
end