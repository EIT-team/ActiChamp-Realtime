function [BV0 X1] = get_BV (Data,Fs,Filt,Freqs,Prt)

elec = 1:size(Data,2);
N_prt = size(Prt,1);

for i = 1:max(size(Freqs))
    
    Fc = Freqs(i);
    
    %Filter and demodulate at each frequency
    [b,a] = butter(Filt.Order,(Fc+[-Filt.Band,Filt.Band])./(Fs/2));
    
    X1{i} = filtfilt(b,a,Data);
    X1{i} = abs(hilbert(X1{i}));
    X1{i} = X1{i}(end/10:9*end/10,:);
    BV(i,:)= mean( X1{i});
    SD(i,:)= std( X1{i});
    
end


BV0 = 1e-6*cell2mat(arrayfun(@(i)BV(i,setdiff(elec,Prt(i,:))),1:N_prt,...
    'UniformOutput',false))';

end
