classdef Viewer < handle
    %Class defintion for Viewer object, containing GUI elements
    
    % Tom Dowrick 8.3.2016
    
    properties (Access = public)
        %Handles to GUI objects
        fig
        tabGroup
        Settings
        tabDC
        tabPlotEEG
        tabNoise
        
        chansToPlot = 1     %Which channels to plot
        filtOrder = 1       %Filter order
        filtFreq = 1000       %Filter centre frequency
        filtBW = 500          %Filter Bandwidth
        filtercoeffs
        filtUpdateTime = 1  %How often to calculate/display filt data
        filt_buf = []
        downsample = 50     %how much to downsample data for plotting
        saveFolder = []    % save data buffer and figures to this dir
        saveFlag = 0        % save when this is set to 1
        
    end
    
    methods
        
        function handles = Viewer(Acti)
            % Constructor. Initialise GUI components and event listners
            % Acti - Actichamp object
            
            handles.initGUI();
            
            %Listen for new data arriving
            addlistener (Acti, 'EEG_packet', 'PostSet', @(o,e) handles.onNewData(e.AffectedObject));
            
            %Set EEG object properties when 1st bit of data comes in
            addlistener (Acti, 'channelNames', 'PostSet', @(o,e) handles.onPropChange(e.AffectedObject));
        end
        
        function initGUI(self)
            %Initialise GUI objects by loading layout from predefined .fig
            %file, created in GUIDE. Edit fig_layout.fig to change layout
            %of elements.
            
            %Load layout from GUIDE figure
            hFig = hgload('fig_layout.fig');
            
            %Define tab group
            %Can't create tabs using GUIDE, so tab position is set to that
            %of a panel in the GUIDE fig.
            hPlotPanel = findobj(hFig,'tag','Plotpanel');
            self.tabGroup = uitabgroup('Parent',hFig, 'Units', get(hPlotPanel,'Units'),'Position',get(hPlotPanel,'Position'));
            hTabPlotEEG = uitab('Parent', self.tabGroup, 'Title', 'EEG Plot');
            hTabDC = uitab('Parent', self.tabGroup, 'Title', 'DC Offset');
            hTabNoise = uitab('Parent', self.tabGroup, 'Title', 'Noise');
            
            %Create settings panel and populate with objects
            hSettingsPanel = findobj(hFig, 'tag' ,'settingsPanel');
            
            lblHost =  findobj(hFig, 'tag' , 'lblHost');
            editHostIP =  findobj(hFig, 'tag' , 'editHostIP');
            btnConnect =  findobj(hFig, 'tag' , 'btConnect');
            lblRange =  findobj(hFig, 'tag' , 'lblRange');
            editRange =  findobj(hFig, 'tag' , 'editRange');
            chanSelect =  findobj(hFig, 'tag' , 'lstChannels');
            lblTime = findobj(hFig,'tag','lblTime');
            editTime = findobj(hFig,'tag','editTime');
            chkDC = findobj(hFig,'tag','chkDC');
            chkFilter = findobj(hFig,'tag','chkFilter');
            chkDemod  = findobj(hFig,'tag','chkDemod');
            lblFiltOrder = findobj(hFig,'tag','lblFiltOrder');
            popFiltOrder = findobj(hFig,'tag','popFiltOrder');
            lblFiltFreq = findobj(hFig,'tag','lblFiltFreq');
            editFiltFreq = findobj(hFig,'tag','editFiltFreq');
            lblFiltBW = findobj(hFig,'tag','lblFiltBW');
            editFiltBW = findobj(hFig,'tag','editFiltBW');
            lblFs = findobj(hFig,'tag','lblFs');
            lblFiltUpdate = findobj(hFig,'tag','lblFiltUpdate');
            editFiltUpdate = findobj(hFig,'tag','editFiltUpdate');
            btnSave =findobj(hFig,'tag','btnSave');
            
            %Create structure of handles
            self.Settings = struct(  'HostIP',editHostIP, 'btnConnect',btnConnect, 'Range',editRange,...
                'lstChannels',chanSelect,'Time',editTime,'chkFilter',chkFilter, 'chkDemod',chkDemod,...
                'FiltOrder',popFiltOrder','FiltFreq',editFiltFreq, 'FiltBW',editFiltBW, 'lblFs',lblFs,...
                'FiltUpdateTime',editFiltUpdate, 'chkDC',chkDC, 'btnSave',btnSave);
            
            % Construct the axes to display time and frequency domain data
            % Axes are defined as children of panel object in GUIDE, need to change
            % this to the tab being used.
            axTime = findobj(hFig,'tag', 'axTime');
            axFilt = findobj(hFig,'tag', 'axFilt');
            
            set(axTime,'Parent',hTabPlotEEG);
            set(axFilt,'Parent',hTabPlotEEG);
            
            %Create plot handles for EEG Plot tab
            hTime = plot(axTime,(1:10));
            hFilt = plot(axFilt,(1:10));
            yrange = 1e3*str2num(get(editRange,'String'));
            
            set(axTime,'YLim',[-yrange yrange]);
            xlabel(axTime,'Time (s)');
            ylabel(axTime, '(uV)');
            
            %Put handles in structure
            self.tabPlotEEG = struct('tab',hTabPlotEEG, 'axTime',axTime, 'axFilt',axFilt, 'plotTime',hTime, 'plotFilt',hFilt);
            
            %Create plot handles for DC offset tab
            axDC = findobj(hFig,'tag', 'axDC');
            set(axDC,'Parent',hTabDC);
            hBar = bar(axDC,1:16,1:16);
            xlabel(axDC,'Channel');
            ylabel(axDC, 'DC Offset (uV)');
            set(axDC,'YLim',[-yrange yrange]);
            
            %Put handles in structure
            self.tabDC = struct('tab',hTabDC, 'ax',axDC, 'bar',hBar);
            
            
            % Noise analysis tab *******************
            
            %Use same axes positions as on Time tab
            axFreq = findobj(hFig,'tag','axFreq');
            axNoise = findobj(hFig,'tag','axNoise');
            
            set(axFreq,'Parent',hTabNoise);

            set(axNoise,'Parent',hTabNoise);
            
            %Create initial plot
            lblFRange = findobj(hFig,'tag','lblFRange');
            editFMin = findobj(hFig,'tag','editFMin');
            editFMax = findobj(hFig,'tag','editFMax');
            
            set(editFMin,'Parent',hTabNoise);
            set(editFMax,'Parent',hTabNoise);
            set(lblFRange,'Parent',hTabNoise);
            
            %Do initial placeholder plot for FFT
            hFreq = semilogy(axFreq,(1:10));
            hNoise = plot(axNoise,(1:10));
            xlabel(axFreq,'Frequency (kHz)')

            
            self.tabNoise = struct('tab',hTabNoise,'axFreq',axFreq,'axNoise',axNoise,...
                'PlotFreq',hFreq, 'PlotNoise', hNoise, 'FreqMin',editFMin, 'FreqMax',editFMax);
            %*********
            set(hFig,'Name','ActiChamp Client')
            % Move the GUI to the center of the screen.
            movegui(hFig,'center')
            % Make the GUI visible.
            set(hFig,'Visible','on');
            
            %Attach figure to object property
            self.fig = hFig;
            
        end
        
        
        
        function onNewData(self,Acti)
            % Update plots whenever new data is read from EEG amp
            % calls appropriate plotting
            % function
            % self - GUI shandles object
            % Acti - Actichamp object
            
            %Update DC offsets
            Acti.V_DCs = mean(Acti.EEG_packet,2);
                      
            %Run plot update for active tab
            active_tab = get(self.tabGroup,'SelectedIndex');
            switch active_tab
                case 1
                    self.updateEEGPlot(Acti)
                case 2
                    self.updateDCOffset(Acti)
                case 3
                    self.updateNoise(Acti)
            end
            
            % If data buffer is longer than max_data_buf, reset buffer to
            % empty.
            % If Acti.saveFlag set to 1, save data buffer and figures
            if Acti.data_buf_len >  Acti.max_data_buf * Acti.Fs
                
                %If a valid save folder has been specified, save data
                if self.saveFlag
                    
                    Acti.Close();
                    self.saveData(Acti);
                    self.saveFlag = 0;
                    
                    set(self.Settings.btnConnect,'String','Connect');
                    
                end
                
                Acti.data_buf = [];
                self.filt_buf = [];
                
            end
            
        end
        
        function updateEEGPlot(self,Acti)
            % Update plots on EEG Plot tab
            % self - GUI handles object
            % Acti - Actichamp object
            
            %Remove DC component if check box is active
            if (get(self.Settings.chkDC,'Value'))
                DC_corr = repmat(Acti.V_DCs,1,Acti.len_packet);
                 Acti.data_buf(:,(Acti.data_buf_len-Acti.len_packet+1):Acti.data_buf_len)=...
                   Acti.data_buf(:,(Acti.data_buf_len-Acti.len_packet+1):Acti.data_buf_len) - DC_corr;
                
            end
            
            if (Acti.data_buf_len) %Don't try to plot if empty
                i = 1:self.downsample:Acti.data_buf_len; %indices to plot
                set(self.tabPlotEEG.plotTime,'XData', i/Acti.Fs) %Time steps
                set(self.tabPlotEEG.plotTime,'YData',Acti.data_buf(self.chansToPlot,i))
            end
            
            %Check if filt/demod tick boxes are active, if so do
            %appropriate processing.
            filtOn = get(self.Settings.chkFilter,'Value');
            demodOn = get(self.Settings.chkDemod,'Value');
            
            if (filtOn || demodOn)
                nSamples = Acti.Fs*self.filtUpdateTime; %How many samples being used for filtering
                
                %Check if data buffer is at a multiple of nSamples, then plot data
                if ~rem(Acti.data_buf_len,nSamples)
                
                    len_filt_buf = size(self.filt_buf,2);
                    filt_data = Acti.data_buf(self.chansToPlot,(Acti.data_buf_len-nSamples+1):Acti.data_buf_len);
                    
                    if filtOn %Do filtering
                        filt_data = filtfilt(self.filtercoeffs.b,self.filtercoeffs.a,double(filt_data));
                    end
                    
                    if demodOn %Do demodulation

                        filt_data = abs(hilbert(filt_data));
                    end
                    
                    %Update buffer length
                    %Cast to int32 to avoid bug with subscript index
                    %mismatch
                    new_len = int32(len_filt_buf+nSamples);
                    self.filt_buf(:,(len_filt_buf+1):new_len) = filt_data; %Append new data
                    len_filt_buf = new_len;
                    
                    if len_filt_buf %Don't try to plot if empty
                        set(self.tabPlotEEG.plotFilt,'XData', (1:self.downsample:len_filt_buf)./Acti.Fs);
                        set(self.tabPlotEEG.plotFilt,'YData',self.filt_buf(1:self.downsample:len_filt_buf));
                    end
                    
                    
                end
            end
            
        end
        
        function updateDCOffset(self,Acti)
            % Update plot on DC offset tab
            % self - GUI shandles object
            % Acti - Actichamp object
            set(self.tabDC.bar,'YData',Acti.V_DCs);
        end
        
        function updateNoise(self,Acti)
            % Update FFT/Pwelch & Noise plots
            
            %Update plot every second
            if ~rem(Acti.data_buf_len,Acti.Fs)
                axes(self.tabNoise.axFreq)
                
                %Calculate FFT
                Y = fft(Acti.data_buf(self.chansToPlot,:));
                P2 = abs(Y/Acti.data_buf_len);
                P1 = P2(1:Acti.data_buf_len/2+1);
                P1(2:end-1)=2*P1(2:end-1);
                f = Acti.Fs *(0:(Acti.data_buf_len/2))/Acti.data_buf_len;
                
                %semilogy(self.tabNoise.axFreq,f,P1)
                
                set(self.tabNoise.PlotFreq,'XData', f/1000) %Time steps
                set(self.tabNoise.PlotFreq,'YData',P1)
                
                %Calculate injection frequency (whichever one has highest
                %FFT value)
                [~,max_ind] = max(P1(2:end)); %Ignore 1st sample (0Hz)
                Fc = round(f(max_ind));
                %Display Fc in title
                set(self.tabNoise.axFreq,'Title', title(['Fc: ' num2str(Fc) 'Hz']));

    
                axes(self.tabNoise.axNoise)
                data = filtfilt(self.filtercoeffs.b,self.filtercoeffs.a,double(Acti.data_buf'));
                data = abs(hilbert(data));
                %Use 10%-90% of the data to exclude filter/demod ripples
                imagesc( cov(data(Acti.Fs/10:9*Acti.Fs/10,:)))
            end
            
        end
        
        function onPropChange(self,Acti)
            % Update EEG properties and channel names in listbox
            % self - GUI handles object
            % Acti - Actichamp object
            
            % Populate list box with channel names
            set(self.Settings.lstChannels,'String',Acti.props.channelNames);
            Acti.Fs = 1e6./Acti.props.samplingInterval;
            set(self.Settings.lblFs,'String',['Fs: ' num2str(Acti.Fs) 'Hz']);
        end
        
        function saveData(self,Acti)
           % Saves data buffer and figures
           % Save location specified by self.saveFolder
           % Method of saving figures is a bit sketchy, don't yet have a better way
           % to do it.
           self.saveFolder= uigetdir('.','Select Save Folder');

           save([self.saveFolder '\Time-series-data.mat'],'Acti');
           
           %Update figures,switch to appropriate tab and save
           self.updateEEGPlot(Acti)
           set(self.tabGroup,'SelectedIndex',1);
           self.save_fig(self.fig, [self.saveFolder '\EEGPlot.png'])
           
           self.updateDCOffset(Acti)
           set(self.tabGroup,'SelectedIndex',2);
           self.save_fig(self.fig, [self.saveFolder '\DCPlot.png'])
           
           
           self.updateNoise(Acti)
           set(self.tabGroup,'SelectedIndex',3);
           self.save_fig(self.fig, [self.saveFolder '\NoisePlot.png'])
           
           %Clear saveFolder, so that data will not be saved again.
         
           
           %Reset button text
           set(self.Settings.btnSave,'String','Save Data');


        end
        
        function save_fig(self,fig,file)
            %Saves figure to specified location
            %Bug with multiple monitors - figure must be on same screen as
            %MATLAB console
            
           F = getframe(fig);
           Image = frame2im(F);
           imwrite(Image,file);
        end
    end
    
end