classdef ActiChamp < handle
    % Class definition for ActiChamp Object
    % Tom Dowrick 8.3.2016
    % Mostly based on code provided by ActiChamp
    properties (SetObservable = true)
        %Use these to trigger listeners to update GUI elements
        EEG_packet = []     %Single packet of EEG data in 'samples x channels' format  
        channelNames = []
    end
    
    properties
        ip = '128.40.45.70'
        con                 %TCP connection
        port = 51244        %Port for 32-bit data on ActiChamp
        header_size = 24    %Data packet header size
        finish = 0;         %Data collection completed
        hdr                 %Message header
        datahdr             %Data block headers
        data_buf            %data buffer          
        data                %Block of data
        max_data_buf = 1    %How much data to buffer (in seconds)
        markers             %Markers/triggers
        data_buf_len=[]       %How many mseconds read so far
        lastBlock   = -1        %Index of most recently read data block
        print_markers = 0   %Set to 1 to print marker/trigger info to console
        props            %EEG properties (sampling rate etc)
        Fs
        V_DCs
        len_packet          %length of EEG packet (in samples)
        
    end
    

    
    methods

        function Connect(self)
            % Create TCP connection to EEG amp
            self.con = pnet('tcpconnect', self.ip, self.port);
            stat = pnet(self.con,'status');
            if stat > 0
                disp('Connection Established');
            else
                disp('Connection Not Established');
            end
            
        end
        
        function ReadHeader(self)
            % define a struct for the header
            self.hdr = struct('uid',[],'size',[],'type',[]);
            
            % read id, size and type of the message
            % swapbytes is important for correct byte order of MATLAB variables
            % pnet behaves somehow strange with byte order option
            self.hdr.uid = pnet(self.con,'read', 16);
            self.hdr.size = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
            self.hdr.type = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));

        end
        
        function ReadStartMessage(self)
            
            % define a struct for the EEG properties
            self.props = struct('channelCount',[],'samplingInterval',[],'resolutions',[],'channelNames',[]);
            
            % read EEG properties
            self.props.channelCount = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
            self.props.samplingInterval = swapbytes(pnet(self.con,'read', 1, 'double', 'network'));
            self.props.resolutions = swapbytes(pnet(self.con,'read', self.props.channelCount, 'double', 'network'));
            allChannelNames = pnet(self.con,'read', self.hdr.size - 36 - self.props.channelCount * 8);
            
            %Storing channelNames in two places to trigger GUI listener
            %Working for now, not optimal method of doing it.
            self.props.channelNames = self.SplitChannelNames(allChannelNames);
            self.channelNames = self.props.channelNames;
            
            %Set sampling frequency
            self.Fs = 1./(self.props.samplingInterval/1e6);
            
        end
        
        function channelNames = SplitChannelNames(self,allChannelNames)
            % allChannelNames   all channel names together in an array of char
            % channelNames      channel names splitted in a cell array of strings
            
            % cell array to return
            channelNames = {};
            
            % helper for actual name in loop
            name = [];
            
            % loop over all chars in array
            for i = 1:length(allChannelNames)
                if allChannelNames(i) ~= 0
                    % if not a terminating zero, add char to actual name
                    name = [name allChannelNames(i)];
                else
                    % add name to cell array and clear helper for reading next name
                    channelNames = [channelNames {name}];
                    name = [];
                end
            end
        end
        
        function ReadDataMessage(self)
            % Define data header struct and read data header
            self.datahdr = struct('block',[],'points',[],'markerCount',[]);
            
            self.datahdr.block = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
            self.datahdr.points = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
            self.datahdr.markerCount = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
            
            % Read data in float format
            self.data = swapbytes(pnet(self.con,'read', self.props.channelCount * self.datahdr.points, 'single', 'network'));
            self.EEG_packet = reshape(self.data, self.props.channelCount, length(self.data) / self.props.channelCount);
            self.len_packet = size(self.EEG_packet,2);
            
            % Define markers struct and read markers
            self.markers = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
            for m = 1:self.datahdr.markerCount
                marker = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
                
                % Read integer information of markers
                marker.size = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
                marker.position = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
                marker.points = swapbytes(pnet(self.con,'read', 1, 'uint32', 'network'));
                marker.channel = swapbytes(pnet(self.con,'read', 1, 'int32', 'network'));
                
                % type and description of markers are zero-terminated char arrays
                % of unknown length
                c = pnet(self.con,'read', 1);
                while c ~= 0
                    marker.type = [marker.type c];
                    c = pnet(self.con,'read', 1);
                end
                
                c = pnet(self.con,'read', 1);
                while c ~= 0
                    marker.description = [marker.description c];
                    c = pnet(self.con,'read', 1);
                end
                
                % Add marker to array
                self.markers(m) = marker;
            end
            
        end
        
       
        function GetDataBlock(self)
            % Read data from EEG until a data packet is received
            %
            %
            
            %             disp(self.lastBlock)
            packet_read = 0;
            %Open TCP connection
            if isempty(self.con)
                self.Connect()
            end
            
            while ~packet_read % Main loop
                try
                    % check for existing data in socket buffer
                    tryheader = pnet(self.con, 'read', self.header_size, 'byte', 'network', 'view', 'noblock');
                    
                    while ~isempty(tryheader)
                        
                        % Read header of RDA message
                        self.ReadHeader();
                        
                        switch self.hdr.type
                            case 1       % Start, Setup information like EEG properties
                                disp('Start');
                                % Read and display EEG properties
                                self.ReadStartMessage();
                                disp(self.props);
                                
                                % Reset block counter to check overflows
                                %                                 self.lastBlock = -1;
                                
                                % set data buffer to empty
                                self.data_buf = [];
                                
                            case 4       % 32Bit Data block
                                % Read data and markers from message
                                self.ReadDataMessage();
                                
                                % check tcpip buffer overflow
                                if self.lastBlock ~= -1 && self.datahdr.block > self.lastBlock + 1
                                    disp(['******* Overflow with ' int2str(datahdr.block - self.lastBlock) ' blocks ******']);
                                end
                                self.lastBlock = self.datahdr.block;
                                
                                % print marker info to MATLAB console
                                if self.datahdr.markerCount > 0 && self.print_markers
                                    for m = 1:self.datahdr.markerCount
                                        disp(self.markers(m));
                                    end
                                    
                                    %Update how many seconds have been
                                    %recorded
                                end
                                packet_read = 1;
                                
                                
                                
                            case 3       % Stop message
                                disp('Stop');
                                self.data = pnet(self.con, 'read', self.hdr.size - self.header_size);
                                self.finish = true;
                                
                            otherwise    % ignore all unknown types, but read the package from buffer
                                self.data = pnet(self.con, 'read', self.hdr.size - self.header_size);
                        end
                        tryheader = pnet(self.con, 'read', self.header_size, 'byte', 'network', 'view', 'noblock');
                    end
                catch
                    er = lasterror;
                    disp(er.message);
                end
            end
            
            
            
        end
        
        function Go(self)
            self.finish = 0;
            self.lastBlock = -1;
            while ~self.finish
                % Get Block of data and append to data buffer
                self.GetDataBlock()
                
            end
            disp('Finished')
            
            self.Close()
        end
        
        function Close(self)
            % Close all open socket connections
            pnet('closeall');
            self.con = [];
            
            % Display a message
            disp('connection closed');
            
        end
        
        
        
    end
end
