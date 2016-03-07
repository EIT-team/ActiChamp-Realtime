classdef Viewer < handle
    
    properties
        %Handles
        fig
        tabGroup
        Settings
        tabDC
        tabPlotEEG
        
        
        chansToPlot = 1
        filtOrder = 1
        filtFreq = 10
        filtBW = 5
        Fs = 500
        filtercoeffs
        DataFilt
        DataDemod
        
    end
    
    
    
    methods
        
        function handles = Viewer(Acti)
            
            %Initialise GUI
            handles.initGUI();
            
            %Define listeners to respond to GUI/Data events
            addlistener (Acti, 'data_buf', 'PostSet', @(o,e) handles.onNewData(handles,e.AffectedObject));
            %Populate list box with channels names on start
            addlistener (Acti, 'channelNames', 'PostSet', @(o,e) handles.onPropChange(handles,e.AffectedObject));
        end
        
        function initGUI(self)
            
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
            chkFilter = findobj(hFig,'tag','chkFilter');
            chkDemod  = findobj(hFig,'tag','chkDemod');
            lblFiltOrder = findobj(hFig,'tag','lblFiltOrder');
            popFiltOrder = findobj(hFig,'tag','popFiltOrder');
            lblFiltFreq = findobj(hFig,'tag','lblFiltFreq');
            editFiltFreq = findobj(hFig,'tag','editFiltFreq');
            lblFiltBW = findobj(hFig,'tag','lblFiltBW');
            editFiltBW = findobj(hFig,'tag','editFiltBW');
            lblFs = findobj(hFig,'tag','lblFs');
            
            handles_Settings = struct(  'HostIP',editHostIP, 'btConnect',btConnect, 'Range',editRange,...
                'lstChannels',chanSelect,'Time',editTime,'chkFilter',chkFilter, 'chkDemod',chkDemod,...
                'FiltOrder',popFiltOrder','FiltFreq',editFiltFreq, 'FiltBW',editFiltBW, 'lblFs',lblFs);
            
            
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
            
            self.fig = hFig;
            self.tabGroup = hTabGroupPlot;
            self.Settings = handles_Settings;
            self.tabDC = handles_tabDC;
            self.tabPlotEEG = handles_TabPlotEEG;
            
        end
        
        
        
        function onNewData(self,handles,obj)
            
            %Only update graph for active tab
            active_tab = get(handles.tabGroup,'SelectedIndex');
            switch active_tab
                case 1
                    self.updateEEGPlot(handles,obj)
                    
                case 2
                    self.updateDCOffset(handles,obj)
            end
        end
        
        function updateEEGPlot(self,handles,obj)
            %Update this to plot whichever channel(s) are selected
            
            data_to_plot = obj.data_buf(self.chansToPlot,:);
            
            %Check if filt/demod tick boxes are active
            if (get(handles.Settings.chkFilter,'Value'))
                
                data_to_plot = filtfilt(handles.filtercoeffs.b, handles.filtercoeffs.a, double(data_to_plot));
            end
            
            if (get(handles.Settings.chkDemod,'Value'))
                data_to_plot = abs(hilbert(data_to_plot));
            end
            
            
            set(handles.tabPlotEEG.plotTime,'YData',data_to_plot(:,1:100:end))
            
        end
        
        
        
        function updateDCOffset(self,handles,obj)
            
            set(handles.tabDC.bar,'YData',mean(obj.EEG_packet,2));
            
        end
        
        
        
        function onPropChange(self,handles,obj)
            % Populate list box with channel names
            set(handles.Settings.lstChannels,'String',obj.props.channelNames);
            Fs = 1e6./obj.props.samplingInterval;
            set(handles.Settings.lblFs,'String',['Fs: ' num2str(Fs) 'Hz']);
        end
        
    end
    
end