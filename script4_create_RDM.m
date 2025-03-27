%% this script creates RDMs based on the condition (ds structure) extracted with script2. These will then be used to perform RSA and index analyses

clear, clc, close all
config=cosmo_config();

study_path=fullfile('path\ds\'); %path to the ds structure

ROIs = cell(1, 40); % Initialize naROI as a cell array with 40 empty elements
 
% Populate naROI with variable names "vector1" to "vector40"
for i = 1:40
    ROIs{i} = ['roi_sphere', num2str(i)];
end

nameROIs = numel(ROIs); % Get the number of elements in naROI

%%%

subjs =  {'sub01', 'sub02', 'sub03', 'sub04', 'sub05', 'sub06', 'sub07', 'sub08', 'sub09', 'sub10', 'sub11', 'sub12', 'sub13', 'sub14', ...
    'sub16', 'sub17', 'sub18', 'sub19'};

numSubjs = size(subjs, 2);
numROIs = numel(ROIs); % Get the number of elements in ROI

%Load ds structure
for r = 1:numROIs
    for s = 1:numSubjs
data_path=fullfile([study_path, subjs{s}, '_', ROIs{r}, '_ds']);
filename=fullfile(data_path);
load (filename, 'ds');

% simple sanity check to ensure all attributes are set properly
cosmo_check_dataset(ds);

%remove constant features
ds=cosmo_remove_useless_data(ds);

%% Compute avg across runs with cosmo cosmo_fx
f_ds=cosmo_fx(ds, @(x)mean(x,1), 'targets');
% remove the conditions that are not relevant for the study (monkey body,
% hand, face, and chairs)
f_ds.samples(10,:) = [];
f_ds.sa.targets(10) = [];
f_ds.samples(6,:) = [];
f_ds.sa.targets(6) = [];
f_ds.samples(4,:) = [];
f_ds.sa.targets(4) = [];
f_ds.samples(2,:) = [];
f_ds.sa.targets(2) = [];

%% Compute RDM with cosmo_dissimilarity_matrix_measure
ds_dsm = cosmo_dissimilarity_matrix_measure(f_ds,'metric','correlation','center_data',true);

%  visualize RDM
[samples, labels, values]=cosmo_unflatten(ds_dsm,1,'set_missing_to',NaN);

% store results
RDMvectortemp=ds_dsm.samples;
dsm_all(:,s) = RDMvectortemp;

RDMtemp = samples;
dsm_mat_all(:,:,s) = RDMtemp;

    end
    dsm_vect{r} = dsm_all;
    dsm_unflatten{r} = dsm_mat_all;
end
%store results in a single variable "RDM"
RDM.data = dsm_vect;
RDM.data_unflatten = dsm_unflatten;
RDM.ROIs = ROIs;
RDM.subjs = subjs;

%visualisation
figure(1);
Regions = ROIs;

for i = 1:size(RDM.data_unflatten,2)
    temp_mat = RDM.data_unflatten{i};
    mean_rdm = mean(temp_mat, 3);
    subplot(1,numROIs,i)
    imagesc(mean_rdm)
    axis equal tight
    hold on
    axis off
    title(sprintf('%s', Regions{i}));
    set(gcf, 'color', 'w');
    colorbar
end

%save results
results_path=fullfile('path\multivariate\');
name_file=fullfile([results_path, 'SingleSubj_ROIs_RDM']); %this is the variable that we will use for next analyses
save(name_file, 'RDM');