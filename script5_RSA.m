clear, clc, close all
data_filepath=fullfile('path\multivariate\');

%% Load models
%the three models were generated in different ways:
%1) shape model was calculated based on the aspect-ratio of the images,
%using the formula as in Bao et al. 2020 (Nature);
%2)animacy model and 3) action model were generated based on behavioral
%ratings
load('models_vectors')
models = models_vec; %three vectors representing the three models (shape - animacy - action)

%% Load neural data
load ([data_filepath, 'SingleSubj_ROIs_RDM']); %variable generated with script 4
neural_data = RDM.data;

% Initialize cell array to store partial correlation results
partial_corr_results = cell(size(neural_data));

% Compute partial correlation for each model
for i = 1:numel(neural_data)
    % Extract neural data for current cell
    neural_data_cell = neural_data{i};
    
    % Initialize matrix to store results for current cell
    partial_corr_results_cell = zeros(size(models, 2), size(neural_data_cell, 2));
    
    % Compute partial correlation for the current cell
    for j = 1:size(models, 2)
        % Select the current model for partial correlation
        model = models(:, j);

        % Remove the current model from the models matrix
        other_models = models;
        other_models(:, j) = [];

        % Compute partial correlation for the current model
        partial_corr_results_cell(j, :) = (partialcorri(neural_data_cell, model, 'Type', 'Pearson', 'Rows', 'complete'));
        partial_corr_results_cell_atanh(j, :) = atanh(partialcorri(neural_data_cell, model, 'Type', 'Pearson', 'Rows', 'complete')); %Fisher transformation for statistical analysis
    end
    
    % Store partial correlation results for current cell
    partial_corr_results{i} = partial_corr_results_cell;
    partial_corr_results_atanh{i} = partial_corr_results_cell_atanh;
end

% Initialize cell array to store standard error for each model in each ROI
stats = cell(size(neural_data));

% Compute standard error for each model in each ROI
for i = 1:numel(neural_data)
    % Extract partial correlation results for current ROI
    partial_corr_results_cell = (partial_corr_results{i});
    
    % Compute standard error for each model
    std_error_models = std(partial_corr_results_cell, 0, 2) / sqrt(size(neural_data_cell, 2));
    
    % Store standard error for each model in current ROI
    stats{i} = std_error_models;
end

% Initialize matrix to store mean partial correlation values for each model
mean_partial_corr_models = zeros(size(models, 2), numel(neural_data));

% Initialize matrix to store noise ceiling for each cell
noise_ceiling = zeros(numel(neural_data), 1);

% Compute mean partial correlation and noise ceiling for each cell
for i = 1:numel(neural_data)
    % Extract partial correlation results for current cell
    partial_corr_results_cell = (partial_corr_results{i});
    
    % Compute mean partial correlation for each model
    mean_partial_corr_models(:, i) = mean(partial_corr_results_cell, 2);
    
    % Compute noise ceiling for current cell
    neural_vect = neural_data{i};
    for s = 1:size(neural_vect, 2)
        singleSubj = neural_vect(:, s);
        maskMin = neural_vect;
        maskMin(:, s) = NaN;
        Group = nanmean(maskMin, 2);
        noise_ceiling(i) = noise_ceiling(i) + corr(singleSubj, Group);
    end
    noise_ceiling(i) = noise_ceiling(i) / size(neural_vect, 2);
end

%% Select only the first 34 ROIs.
% Why only 34: this is for visualization purposes, mostly because the last
% 6 were posterior to TOS and very little signal can be found there
mean_partial_corr_models = mean_partial_corr_models(:, 1:34);
noise_ceiling = noise_ceiling(1:34);
partial_corr_results = partial_corr_results(1:34);
neural_data = neural_data(1:34);

%% plot
condition_names = {'PHC', 'mFG', 'lFG', 'OTS', 'aITG', 'pITG', 'LOS', 'TOS'};
condition_positions = [1, 5.5, 10, 14, 19.5, 24.5, 29.5, 34]; %approximate positions of areas based on our coordinates

figure;
set(gcf, 'Color', [0.9 0.9 0.9]); 
% Compute standard error for each model
std_error_models = std(partial_corr_results_cell, 0, 2) / sqrt(size(neural_data_cell, 2));

% Plot mean partial correlation for each model
models_labels = {'Shape', 'Animacy', 'Action'};
model_colors = {'b', 'r', [1 0.8 0]}; % Assign colors for each model

for i = 1:size(mean_partial_corr_models, 1)
    plot(1:numel(neural_data), mean_partial_corr_models(i, :), 'Color', model_colors{i}, 'LineWidth', 3.5);
    hold on;
end

set(gca, 'XTick', condition_positions, 'XTickLabel', condition_names, 'FontSize', 30, 'TickLength', [0 0]);
hold on
%Plot noise ceiling
plot(1:numel(neural_data), noise_ceiling, '--', 'Color', [0.5 0.5 0.5], 'LineWidth', 2);

% Add labels and legend
% xlabel('ROIs', 'FontSize', 35);
ylabel('Mean Partial Correlation', 'FontSize', 30);
title('RSA', 'FontSize', 30);
leg1 = legend([models_labels], 'Location', 'southoutside', 'Orientation','horizontal', 'AutoUpdate','off'); % Add labels for each model and noise ceiling
set(leg1, 'Box', 'off')

% Plot shaded regions for standard error
x = 1:numel(neural_data); % Define x as the number of ROIs (34)
for i = 1:3 % Loop over the three models
    mean_vals = mean_partial_corr_models(i, :); % Extract the mean values for model i
    
    % Initialize vector to store the standard errors for the current model
    std_error = zeros(1, numel(neural_data));
    
    % Extract standard error for the current model across ROIs
    for roi = 1:numel(neural_data)
        std_error(roi) = stats{roi}(i); % stats{roi}(i) gives the std error for model i at ROI roi
    end
    
    % Plot the shaded area for the standard error
    fill([x, fliplr(x)], [mean_vals + std_error, fliplr(mean_vals - std_error)], ...
        model_colors{i}, 'FaceAlpha', 0.2, 'EdgeColor', 'none');
    
    hold on; % Keep the plot for the next model
end

xlim([min(x) - 0.5, max(x) + 0.5]);

%%significance
% Define significance threshold
significance_threshold = 0.00147; %Bonferroni correction (0.05 % 34). Results do not change if we include all 40 spheres

% Preallocate vectors for significant regions
significant_regions = cell(1, 3); % One for each model

% set(gcf, 'Color', [0.95 0.95 0.95]); % Set the figure background color to light gray
% set(gca, 'Color', [0.95 0.95 0.95]);

% Loop over each model to compute p-values and find significant ROIs
for model_idx = 1:3
    significant_ROIs = []; % Store significant ROI indices for current model
    
    for roi_idx = 1:numel(partial_corr_results)
        % Extract partial correlation results for the current model and ROI
        partial_corr_data = partial_corr_results{roi_idx}(model_idx, :);
        
        % Perform t-test
        [h, p] = ttest(partial_corr_data);
        
        % Check if the p-value is below the significance threshold
        if p < significance_threshold
            significant_ROIs = [significant_ROIs, roi_idx];
        end
    end
    
    % Store significant ROIs for the current model
    significant_regions{model_idx} = significant_ROIs;
end

% Define y-positions for the significance lines
y_positions = [0.95, 1, 1.05];

% Plot significant regions as lines above the plot
hold on;
for i = 1:3
    sig_x = significant_regions{i}; % x-coordinates (ROIs) where the model is significant
    sig_y = y_positions(i);         % y-coordinate for the current model's line
    plot(sig_x, sig_y * ones(size(sig_x)), 'Color', model_colors{i}, 'LineWidth', 3);
end

% Adjust y-axis range
ylim([-0.1, 1.1]); % Set y-axis from 0 to 1.2

%% Add significance for Action vs Shape (just for visualization)
% Define significance threshold
significance_threshold = 0.05;

% Preallocate vector for ROIs where Action is significantly higher than Shape
significant_action_vs_shape = [];

% Perform paired t-test between Action and Shape models
for roi_idx = 1:numel(partial_corr_results)
    % Extract partial correlation results for Action and Shape models
    action_data = partial_corr_results{roi_idx}(3, :); % Action is the 3rd model
    shape_data = partial_corr_results{roi_idx}(1, :);  % Shape is the 1st model
    
    % Perform paired t-test
    [h, p] = ttest(action_data, shape_data, 'Tail', 'right'); % One-tailed test: Action > Shape
    
    % Check if p-value is below significance threshold
    if p < significance_threshold
        significant_action_vs_shape = [significant_action_vs_shape, roi_idx];
    end
end

% Plot the dotted line for significant ROIs
hold on;
y_dotted = 1.05; % Set the y-coordinate for the dotted line
plot(significant_action_vs_shape, y_dotted * ones(size(significant_action_vs_shape)), 'k--', 'LineWidth', 2);

% Adjust y-axis range
ylim([-0.1, 1.1]); % Set y-axis from 0 to 1.2

hold off;