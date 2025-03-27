%This script creates dissimilarity matrix using "CosmoMVPA". While creating these matrices, it also computes 10000
%permutations that will be necessary for statistical analysis.

clear
config=cosmo_config();

%% Set the number of permutations

niter=10000; %number of permutations.
num_stim=72; %the number of stimuli

%% Load data
% %create ds for DNNs
dnn_ds=[];

dnns = {'network_name'}; %name of the file saved using external codes
numDNNs = size (dnns, 2);

for d = 1:numDNNs
    
    %load DNNs
    dnn_filepath=fullfile('path\DNN_activations'); % the path to where you saved the files from external code
    filename=fullfile([dnn_filepath, dnns{d}]);
    load (filename, 'deepnn');
   
    %this for loop is based on the toolbox "CosmoMVPA"
    %This loop is taking the features extracted from the first script,
    %removing any value below 0, ang generating a vector containing the
    %pairwise comparison among all stimuli
    for l= 1:size(deepnn.layer_samples, 2)
        temp_layer=deepnn.layer_samples{l}';
        temp_layer(temp_layer < 0) = 0;
               
        % construct ds for cosmo with 
        %1)dnn_fs.samples(raw dnn features data)
        %2)dnn_fs.sa.targets (n stimuli)
        dnn_ds.samples=temp_layer;
        nstim=(1:num_stim)'; 
        dnn_ds.sa.targets=nstim;
        
        % %         % compute dissimilarity matrix
        ds_dsm_dnn = cosmo_dissimilarity_matrix_measure(dnn_ds,'metric','correlation', 'center_data', true); %apply Fisher transformation (inside the function), 'correlation = Pearson', 'center_data' = normalisation
        [samples, labels, values]=cosmo_unflatten(ds_dsm_dnn,1,'set_missing_to',NaN);
        %         ds_dsm_unflatten(:,:,s)=samples;
        
        %%create permutations (for statistical significance testing)
        acc0=zeros(size(ds_dsm_dnn.samples,1), niter); % allocate space for permuted accuracies
        ds0=dnn_ds; % make a copy of the dataset
            
        for k=1:niter
            ix = randperm(size(ds0.samples,1));
            ds0.samples=ds0.samples(ix,:);
            ds0_dsm=cosmo_dissimilarity_matrix_measure(ds0,'metric','correlation','center_data',true);
            temp=ds0_dsm.samples;
            acc0(:,k)=temp;
            iterations(:,k)=ix';
           
        end
        %store results dsm;        
        acc0_all{l}=acc0;
        acc0_iterations{l}=iterations;
        tem_rdm{l}=ds_dsm_dnn.samples;
       
    end
      
        cnn.acc0=acc0_all;
        cnn.iterations=acc0_iterations;
        cnn.RDM=tem_rdm;
end

 results_path=fullfile('path\DNN_results');
 name_file=fullfile([results_path, 'name_network_cnn']);
 save(name_file, 'cnn', '-v7.3'); % the '-v7.3' is necessary when the file is very big (when having 10000 permutations for example)