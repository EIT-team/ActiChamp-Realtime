function handles = view_data(obj)

    %Do initial plot
    handles = initGUI();

    % set(handles,'XDataMode','manual')

    addlistener (obj, 'data_buf', 'PostSet', @(o,e) onNewData(handles,e.AffectedObject));
    addlistener (handles.tabDC.Range, 'String', 'PostSet', @(o,e) onNewDataCRange(handles,e.AffectedObject));
    
end

function handles = initGUI()

    hFig = figure('Visible','off','Position',[0,0,640,480]);
           
   
   %Define tab ground and individual tabs
    hTabGroup = uitabgroup('Parent',hFig);
    
    % *** Default tab
    hTabPlotEEG = uitab('Parent', hTabGroup, 'Title', 'Default');

    lblHost = uicontrol('Parent',hTabPlotEEG,'Style','text','String','Host:',...
                        'BackgroundColor',get(hFig,'Color'),'Position',[25,428,50,16]);
    editHostIP = uicontrol('Parent',hTabPlotEEG,'Style','edit','String','128.40.45.70',...
                         'Position',[75,430,150,16]);
    btConnect = uicontrol('Parent',hTabPlotEEG,'Style','pushbutton','String','Connect',...
                          'Position',[230,430,100,16]);
                      
    % construct the axes to display time and frequency domain data
    axTime = axes('Parent',hTabPlotEEG,'Units','Pixels','Position',[25,240,590,180]); 
    axFreq = axes('Parent',hTabPlotEEG,'Units','Pixels','Position',[25,25,590,180]); 
   
    handles_TabPlotEEG = struct('tab',hTabPlotEEG, 'HostIP',editHostIP, 'ConnectBtn',btConnect, ...
                            'axTime',axTime, 'axFreq',axFreq);
    
    % *** DC Offset Tab ***
    hTabDC = uitab('Parent', hTabGroup, 'Title', 'DC Offset');

    lblRange = uicontrol('Parent',hTabDC,'Style','text','String','Voltage Range (mV):',...
                        'BackgroundColor',get(hFig,'Color'),'Position',[25,25,100,16]);
    editRange = uicontrol('Parent',hTabDC,'Style','edit','String','10',...
                         'Position',[125,25,150,16]);
                     
    axDC = axes('Parent',hTabDC,'Units','Pixels','Position',[25,240,590,180]);
    hBar = bar(axDC,1:32,1:32);

    handles_tabDC = struct('tab',hTabDC, 'Range',editRange', 'ax',axDC, 'bar',hBar);
    
    % Assign the GUI a name to appear in the window title.
    set(hFig,'Name','Brain Vision RDA Client for MATLAB')
    % Move the GUI to the center of the screen.
    movegui(hFig,'center')
    % Make the GUI visible.
    set(hFig,'Visible','on'); 

    handles = struct('fig',hFig, 'tabGroup',hTabGroup, 'tabDC',handles_tabDC, 'tabPlotEEG',handles_TabPlotEEG);

    
end

function onNewData(handles,obj)

    %Only update graph for active tab
    active_tab = get(handles.tabGroup,'SelectedIndex');
    switch active_tab
        case 2
            updateDCOffset(handles,obj)
    end
end

function updateDCOffset(handles,obj)

    set(handles.tabDC.bar,'YData',mean(obj.EEG_packet,2));
    
end

function onNewDataCRange(handles,obj)
range = 1e3*str2num(get(handles.tabDC.Range,'String'));
set(handles.tabDC.ax,'YLim',[-range range]);
end
    
%% ***********************************************************************   
% --- Closing reques handler: executes when user attempts to close formRDA.
function RDA_CloseRequestFcn(hObject, eventdata)
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB

    selection = questdlg(['Close MATLAB RDA Client?'],...
                         ['Closing...'],...
                         'Yes','No','Yes');
    if strcmp(selection,'No')
        return;
    end
    A.finish = 1;
    % Close open connections to recorder if exist
    CloseConnection();
    
    % Delete and close the window
    delete(hObject);
end
