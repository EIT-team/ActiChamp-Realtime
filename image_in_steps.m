%%
timeTotal = 1;
timeStep =1e-3;
sampleStep = Acti.Fs*timeStep;
N_prt = size(Prt,1);
elec = 1:Acti.props.channelCount;Acti


%%
Filt.Order = 5;
Filt.Band = 1000;
%%
Acti.Close();
Acti.Go(timeTotal);
Data = Acti.data_buf';
[Baseline,Demod] =  get_BV_Acti(Data,Acti,Filt,Freqs,Prt);

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

    X=tikhonov_CV_fast(dV,lambda,U,sv,V,JJinv_CV_sets,SD_all);
    
%        disp ( ['Recon ' num2str(toc)]); tic

% F_interp.V = X;
% 
% A = F_interp(Xg,Yg);
%      A(abs(A)<12) = 0;
% %      A(abs(A)>=12) = 1;
% set(h,'CData',abs(A))
A = mesh_simple(:,3);
A(abs(X)<XThreshold)=NaN;
set(h,'ZData',A);
drawnow
 
  set(plot_text,'String',[num2str(1000*j/Acti.Fs) 'ms'])
drawnow
end
toc

