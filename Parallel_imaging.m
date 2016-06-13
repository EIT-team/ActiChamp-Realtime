% clear all
% close all
warning('off','MATLAB:colon:nonIntegerIndex')
warning('off','MATLAB:NonIntegerInput')


%% Load mesh and
% still need to implement this properly

Mesh = load('D:\Documents\Experimental Data\SA060.mat');
load('D:\Documents\Experimental Data\SA060-elecs.mat');

plot_type = 'scatter';
%Convert to 'simple' mesh that can be used in MATLAB scatter plots
[mesh_simple, centre_inds] = cylindrical_tank_mesh_simplify(Mesh, 5);

%Use only the mesh elements that are close to 0 on the z axis to reduce
%number of elements and improve computation time later.
mesh_simple = mesh_simple(:,centre_inds)';

%Create grid data for plotting surface
step_size = 0.25;
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

  Prt = [2 18; 10 26 ; 5 21; 13 29];
Freqs = [4852;8761;10644;11740];
h_prt = plot_prt(elec_pos,Freqs,Prt);




%%
% construct the Jacobian
load('D:\Documents\Experimental Data\Jacobians\tank-polar.mat');

% Generate full protocol
prt_exp = gen_prt(Prt,Acti.props.channelCount);
prt_keep = index_protocol(prt_exp,prtfull);

prt_good = [];
for i = 1:size(prt_exp,1)
    if intersect(prt_exp(i,3),[1,2,5,10,11,14,18,19,21,26,29,31,32])
    else
                prt_good(end+1)= i;

            end
end

prt_keep = prt_keep(prt_keep>0);


prt_keep = prt_keep(prt_good,:);

J = J (prt_keep, centre_inds);

% precompute recon stuff
recon_speed_up

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
