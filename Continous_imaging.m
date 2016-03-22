%% Get data from ActiChamp and reconstruct
Acti.Close();
imagePeriod = 0.1; %How often to image in seconds
drawnow
% How much data to collect for each image
for i = 1:100 %while(1)
    tic
     Acti.Go(imagePeriod);
     
     Data  = Acti.data_buf';

    Pert = get_BV_Acti(Data,Acti,Filt,Freqs,Prt);
    dV = Pert(prt_good) - Baseline(prt_good);
    Y_m = dV(IN);
    
    X=tikhonov_CV_fast(dV,lambda,n_J,U,S,V,k,m,n,l,JJinv_InOut,Y_m,OUT,SD_all);
    

% Update interpolation function with new values, and update plot.
F_interp.V = X;
A = F_interp(Xg,Yg);
%      A(abs(A)<12) = 0;
%      A(abs(A)>=12) = 1;
set(h,'CData',abs(A))

set(plot_text,'String',toc)

drawnow
 
   
end
