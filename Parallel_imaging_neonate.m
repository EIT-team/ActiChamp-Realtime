% clear all
% close all
warning('off','MATLAB:colon:nonIntegerIndex')
warning('off','MATLAB:NonIntegerInput')


%% Load mesh and Jac
% still need to implement this properly

load('D:\Documents\Experimental Data\Jacobians\Neonate\NN_Hex_Mesh_Jac_man_prot.mat');

plot_type = 'scatter';
%Convert to 'simple' mesh that can be used in MATLAB scatter plots
[mesh_simple, centre_inds] = hex_mesh_simplify(Mesh_hex, 5000);

%Use only the mesh elements that are close to 0 on the z axis to reduce
%number of elements and improve computation time later.
mesh_simple = mesh_simple(:,centre_inds)';

%Create grid data for plotting surface
step_size = 1;
[Xg, Yg] = meshgrid(  min(mesh_simple(:,1)):step_size:max(mesh_simple(:,1)),...
    min(mesh_simple(:,2)):step_size:max(mesh_simple(:,2))...
  );
                
Vq = griddata(  mesh_simple(:,1), mesh_simple(:,2), mesh_simple(:,3),...
                Xg,Yg); 
%             
% %Create inital plot of the tank
% % Fastest way to do this (so far) - could probably be improved
% h = surf(Xg,Yg,Vq);
% set(h,'LineStyle','none')   %Turn off mesh lines
% % set(h,'CDataMapping','direct')

plot3(mesh_simple(1:200:end,1),mesh_simple(1:200:end,2),mesh_simple(1:200:end,3),'LineStyle','none',...
    'Marker','x','MarkerEdgeColor','red')
hold on
h=plot3(mesh_simple(:,1),mesh_simple(:,2),mesh_simple(:,3),'LineStyle','none','Marker','o')


view(2) %Top down view
plot_text = text(   0.8,0.9,'Time','Units','normalized',...
                    'FontSize',16,'FontName','Times New Roman')

% Create interpolation function - works 3-4x faster than using meshgrid()                 
F_interp = TriScatteredInterp(mesh_simple(:,1),mesh_simple(:,2),mesh_simple(:,3));



%% Gather small (1s or so) amount of data to detect injection electrodes and frequencies
Acti = ActiChamp;
Acti.Go(1);
Data  = Acti.data_buf';
[Prt Freqs] = Find_Injection_Freqs_And_Elecs(Data,Acti.Fs);
% Freqs = [10 ;20; 30];
% Prt = [1 2; 3 4; 7 8];

 unwantedPrt = [1];
 Prt(unwantedPrt,:) = [];
 Freqs(unwantedPrt,:) = [];

  Prt = [5 20; 6 21 ; 22 7; 11 16];
Freqs = [4852;8761;10644;11740];
h_prt = plot_prt(elec_pos,Freqs,Prt);




%%
% construct the Jacobian
load('D:\Documents\Experimental Data\Jacobians\Neonate\NN2016Prt_para_man.mat');
J = J_hex; clear J_hex
prtfull = NN_Prt_para_man;
% Generate full protocol
prt_exp = gen_prt(Prt,Acti.props.channelCount);
prt_keep = index_protocol(prt_exp,prtfull);

prt_good = [];
for i = 1:size(prt_exp,1)
    if intersect(prt_exp(i,3),prt_exp(i,1:2))
    else
                prt_good(end+1)= i;

            end
end

prt_keep = prt_keep(prt_keep>0);


prt_keep = prt_keep(prt_good,:);

J = J (prt_keep, centre_inds);

% precompute recon stuff

Tik.precompute(J)

%% Setup filter
Filt.Order = 5;
Filt.Band = 100;

%% Generate baseline data set
Acti.Go(1);
Data  = Acti.data_buf';
Baseline = get_BV_Acti(Data,Acti,Filt,Freqs,Prt);
m = 1;
%% Keep getting & imaging data
% Continuous_imaging
% 
% %% Gather data, then image
% image_in_steps
