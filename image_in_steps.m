%%
timeTotal = 2;
timeStep =1e-3;
sampleStep = Acti.Fs*timeStep;
N_prt = size(Prt,1);
elec = 1:Acti.props.channelCount;

%%
Acti.Close();
Acti.Go(timeTotal);
Data = Acti.data_buf';
[~,Demod] =  get_BV_Acti(Data,Acti,Filt,Freqs,Prt);

%%
nData = size(Demod{1},1);

tic
for j = 1:sampleStep:nData
    
    for i = 1:size(Freqs,1)
        
    BV(i,:) = mean(Demod{i}(j:j+sampleStep,:));
    end
    
    Pert = 1e-6*cell2mat(arrayfun(@(i)BV(i,setdiff(elec,Prt(i,:))),1:N_prt,...
    'UniformOutput',false))';



dV = Pert(prt_good) - Baseline(prt_good);
Y_m = dV(IN);

    X=tikhonov_CV_fast(dV,lambda,n_J,U,S,V,k,m,n,l,JJinv_InOut,Y_m,OUT,SD_all);
    
%        disp ( ['Recon ' num2str(toc)]); tic

F_interp.V = X;

A = F_interp(Xg,Yg);
     A(abs(A)<12) = 0;
%      A(abs(A)>=12) = 1;
set(h,'CData',abs(A))

  set(plot_text,'String',[num2str(1000*j/Acti.Fs) 'ms'])
drawnow
end
toc

