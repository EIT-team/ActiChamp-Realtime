function [BV0 X1] = get_BV (Data,EEG,Filt,Freqs,Prt)

elec = 1:EEG.props.channelCount;
N_prt = size(Prt,1);

for i = 1:max(size(Freqs))
    
    Fc = Freqs(i);
    
    %Filter and demodulate at each frequency
    [b,a] = butter(Filt.Order,(Fc+[-Filt.Band,Filt.Band])./(EEG.Fs/2));
    
    X1 = filtfilt(b,a,Data);
    X1 = abs(hilbert(X1));
    X1 = X1(end/10:9*end/10,:);
    BV(i,:)= mean( X1);
    SD(i,:)= std( X1);
    
end


BV0 = 1e-6*cell2mat(arrayfun(@(i)BV(i,setdiff(elec,Prt(i,:))),1:N_prt,...
    'UniformOutput',false))';

end
