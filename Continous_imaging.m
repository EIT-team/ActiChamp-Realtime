%% Get data from ActiChamp and reconstruct
Acti.Close();
imagePeriod = 0.01; %How often to image in seconds
drawnow
% How much data to collect for each image
for i = 1:10 %while(1)
    
    Acti.Go(imagePeriod);
    
    Data  = Acti.data_buf';

    Pert = get_BV_Acti(Data,Acti,Filt,Freqs,Prt);
    dV = Pert - Baseline;
    Y_m = dV(IN);
    
    X=tikhonov_CV_fast(dV,lambda,n_J,U,S,V,k,m,n,l,JJinv_InOut,Y_m,OUT,SD_all);
    

% Update interpolation function with new values, and update plot.
F_interp.V = X;
set(h,'CData',F_interp(Xg,Yg))
% set(plot_text,'String',toc)

drawnow
 
   
end
