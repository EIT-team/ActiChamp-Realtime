classdef ActiChamp < handle
    
    properties (SetObservable = true)
        ip = '128.40.45.70'
        con                 %TCP connection
        port = 51244       %Port for 32-bit data on ActiChamp
        header_size = 24    %Data packet header size
        finish = false;     %Data collection completed
        hdr                 %Message header
        props               %EEG properties (sampling rate etc)
        datahdr             %Data block headers
        EEGData             %Data in 'samples x channels' format
        data                %Block of data
        data1s
        markers             %Markers/triggers
        msec_to_read = 100   %How many mseconds of data to read
        msec_read            %How many mseconds read so far
        lastBlock
        print_markers = 0   %Set to 1 to print marker/trigger info to console
    end
    
    properties (SetAccess = private)
    end
    
    properties (Dependent = true)
    end
    
    
    
    methods
        
        
        function Connect(obj)
            % Create TCP connection to EEG amp
            obj.con = pnet('tcpconnect', obj.ip, obj.port);
            
            stat = pnet(obj.con,'status');
            if stat > 0
                disp('Connection Established');
            else
                disp('Connection Not Established');
            end
            
        end
        
        function ReadHeader(obj)
            % define a struct for the header
            obj.hdr = struct('uid',[],'size',[],'type',[]);
            
            % read id, size and type of the message
            % swapbytes is important for correct byte order of MATLAB variables
            % pnet behaves somehow strange with byte order option
            obj.hdr.uid = pnet(obj.con,'read', 16);
            obj.hdr.size = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            obj.hdr.type = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            
            
        end
        
        function ReadStartMessage(obj)
            
            % define a struct for the EEG properties
            obj.props = struct('channelCount',[],'samplingInterval',[],'resolutions',[],'channelNames',[]);
            
            % read EEG properties
            obj.props.channelCount = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            obj.props.samplingInterval = swapbytes(pnet(obj.con,'read', 1, 'double', 'network'));
            obj.props.resolutions = swapbytes(pnet(obj.con,'read', obj.props.channelCount, 'double', 'network'));
            allChannelNames = pnet(obj.con,'read', obj.hdr.size - 36 - obj.props.channelCount * 8);
            obj.props.channelNames = obj.SplitChannelNames(allChannelNames);
        end
        
        function channelNames = SplitChannelNames(obj,allChannelNames)
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
        
        function ReadDataMessage(obj)
            % Define data header struct and read data header
            obj.datahdr = struct('block',[],'points',[],'markerCount',[]);
            
            obj.datahdr.block = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            obj.datahdr.points = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            obj.datahdr.markerCount = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
            
            % Read data in float format
            obj.data = swapbytes(pnet(obj.con,'read', obj.props.channelCount * obj.datahdr.points, 'single', 'network'));
            obj.EEGData = reshape(obj.data, obj.props.channelCount, length(obj.data) / obj.props.channelCount);
            % Define markers struct and read markers
            obj.markers = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
            for m = 1:obj.datahdr.markerCount
                marker = struct('size',[],'position',[],'points',[],'channel',[],'type',[],'description',[]);
                
                % Read integer information of markers
                marker.size = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
                marker.position = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
                marker.points = swapbytes(pnet(obj.con,'read', 1, 'uint32', 'network'));
                marker.channel = swapbytes(pnet(obj.con,'read', 1, 'int32', 'network'));
                
                % type and description of markers are zero-terminated char arrays
                % of unknown length
                c = pnet(obj.con,'read', 1);
                while c ~= 0
                    marker.type = [marker.type c];
                    c = pnet(obj.con,'read', 1);
                end
                
                c = pnet(obj.con,'read', 1);
                while c ~= 0
                    marker.description = [marker.description c];
                    c = pnet(obj.con,'read', 1);
                end
                
                % Add marker to array
                obj.markers(m) = marker;
            end
            
        end
        
        function Go(obj)
            %Reset seconds read
            packet_read = 0;
            %Open TCP connection
            if isempty(obj.con)
                obj.Connect()
            end
            
            while ~packet_read % Main loop
                try
                    % check for existing data in socket buffer
                    tryheader = pnet(obj.con, 'read', obj.header_size, 'byte', 'network', 'view', 'noblock');
                    
                    while ~isempty(tryheader)
                        
                        % Read header of RDA message
                        obj.ReadHeader();
                        
                        switch obj.hdr.type
                            case 1       % Start, Setup information like EEG properties
                                disp('Start');
                                % Read and display EEG properties
                                obj.ReadStartMessage();
                                disp(obj.props);
                                
                                % Reset block counter to check overflows
                                obj.lastBlock = -1;
                                
                                % set data buffer to empty
                                obj.data1s = [];
                                
                            case 4       % 32Bit Data block
                                % Read data and markers from message
                                obj.ReadDataMessage();
                                
                                % check tcpip buffer overflow
                                if obj.lastBlock ~= -1 && obj.datahdr.block > obj.lastBlock + 1
                                    disp(['******* Overflow with ' int2str(datahdr.block - obj.lastBlock) ' blocks ******']);
                                end
                                obj.lastBlock = obj.datahdr.block;
                                
                                % print marker info to MATLAB console
                                if obj.datahdr.markerCount > 0 && obj.print_markers
                                    for m = 1:obj.datahdr.markerCount
                                        disp(obj.markers(m));
                                    end
                                    
                                    %Update how many seconds have been
                                    %recorded
                                end
                                packet_read = 1;
                           
                                % Process EEG data,
                                % in this case extract last recorded second,
                                %                         EEGData = reshape(data, props.channelCount, length(data) / props.channelCount);
                                %                         data1s = [data1s EEGData];
                                %                         dims = size(data1s);
                                %                         if dims(2) > 1000000 / props.samplingInterval
                                %                             data1s = data1s(:, dims(2) - 1000000 / props.samplingInterval : dims(2));
                                %                             %avg = mean(mean(data1s.*data1s));
                                %                             %disp(['Average power: ' num2str(avg)]);
                                %                             bar(mean(data1s,2))
                                %                             drawnow
                                %                             % set data buffer to empty for next full second
                                %                             data1s = [];
                        %end

                        case 3       % Stop message
                            disp('Stop');
                            obj.data = pnet(obj.con, 'read', obj.hdr.size - obj.header_size);
                            obj.finish = true;
                            
                            otherwise    % ignore all unknown types, but read the package from buffer
                                obj.data = pnet(obj.con, 'read', obj.hdr.size - obj.header_size);
                    end
                    tryheader = pnet(obj.con, 'read', obj.header_size, 'byte', 'network', 'view', 'noblock');
                end
                catch
                    er = lasterror;
                    disp(er.message);
            end
        end 
        

        
        end
        
        function Close(obj)
            % Close all open socket connections
            pnet('closeall');
            obj.con = [];
            
            % Display a message
            disp('connection closed');
            
        end
    
end
end
