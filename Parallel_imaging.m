% clear all
% close all
warning('off','MATLAB:colon:nonIntegerIndex')
warning('off','MATLAB:NonIntegerInput')


%% Load mesh and
% still need to implement this properly

Mesh = load('D:\Documents\Experimental Data\SA060.mat');
load('D:\Documents\Experimental Data\SA060-elecs.mat');
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
            
%Create inital plot of the tank
% Fastest way to do this (so far) - could probably be improved
h = surf(Xg,Yg,Vq);
view(2) %Top down view
plot_text = text(   0.8,0.9,'Time','Units','normalized',...
                    'FontSize',16,'FontName','Times New Roman')

% Create interpolation function - works 3-4x faster than using meshgrid()                 
F_interp = TriScatteredInterp(mesh_simple(:,1),mesh_simple(:,2),mesh_simple(:,3));

%% construct the Jacobian
load('D:\Documents\Experimental Data\Parallel Current Source\Evaluation Data\Tank 32 Channel\Jacobian.mat');
load('D:\Documents\Experimental Data\Parallel Current Source\Evaluation Data\Tank 32 Channel\prtfull.mat');

%remove unused from jac/prt/bv0
prt_keep = [1:30 61:120];
J = J (prt_keep, centre_inds);
BV0 = BV0(prt_keep);

%% Gather small (1s or so) amount of data to detect injection electrodes and frequencies
Acti.Go(1);
Data  = Acti.data_buf';
%[Prt Freqs] = Find_Injection_Freqs_And_Elecs(Data,Acti.Fs);
Freqs = [10 ;20; 30];
Prt = [1 2; 3 4; 7 8];

figure
h_prt = plot_prt(elec_pos,Freqs,Prt);

% Generate full protocol
prtfull = gen_prt(Prt,Acti.props.channelCount);


%% precompute recon stuff
recon_speed_up

%% Setup filter
Filt.Order = 1;
Filt.Band = 1;

%% Generate baseline data set
Baseline = get_BV_Acti(Data,Acti,Filt,Freqs,Prt);

%% Keep getting & imaging data
Continuous_imaging

%% Gather data, then image
image_in_steps
