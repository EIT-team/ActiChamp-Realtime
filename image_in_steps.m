%%
timeTotal = 1;
timeStep =1e-3;
sampleStep = Acti.Fs*timeStep;
N_prt = size(Prt,1);
elec = 1:Acti.props.channelCount;

%%
Acti.Go(timeTotal);
Data = Acti.data_buf';
[~,Demod] =  get_BV_Acti(Data,Acti,Filt,Freqs,Prt);

%%
nData = size(Demod,1);

tic
for j = sampleStep:sampleStep:nData-sampleStep
    
    
    BV = mean(Demod(j:j+sampleStep,:));
    Pert = 1e-6*cell2mat(arrayfun(@(i)BV(setdiff(elec,Prt(i,:))),1:N_prt,...
    'UniformOutput',false))';


    dV = Pert-Baseline;
        Y_m = dV(IN);

    X=tikhonov_CV_fast(dV,lambda,n_J,U,S,V,k,m,n,l,JJinv_InOut,Y_m,OUT,SD_all);
    
%        disp ( ['Recon ' num2str(toc)]); tic

F_interp.V = X;
set(h,'CData',F_interp(Xg,Yg))

 set(plot_text,'String',[num2str(1000*j/Acti.Fs) 'ms'])
drawnow
end
toc

