%% this script plots the univariate analysis with the vector-of-ROIs
clear all; clc; close all;

% Load DS structure (as saved by script2)
subjs =  {'sub01', 'sub02', 'sub03', 'sub04', 'sub05', 'sub06', 'sub07', 'sub08', 'sub09', 'sub10', 'sub11', 'sub12', 'sub13', 'sub14', ...
    'sub16', 'sub17', 'sub18', 'sub19'};
numSubjs = numel(subjs);

% Define ROIs
naROI = arrayfun(@(i) sprintf('roi_sphere%d', i), 1:40, 'UniformOutput', false);
resROIs = numel(naROI);

% Define categories to extract
category_indices = [1, 3, 5, 7, 8, 9]; %categories 2, 4, 6 (monkey bodies, hands, and faces) were excluded from analysis because not relevant for the present study; ...
% category 10 was the control chair condition
numCategories = numel(category_indices);

% Initialize 3D matrix (categories x ROIs x subjects)
beta_values_matrix = zeros(numCategories, resROIs, numSubjs);

% path to saved ds files
ds_filepath = 'path\ds\'; %change this path

%here we load the ds structure for each roi in each participant and we
%average across runs with a cosmo function
for r = 1:resROIs
    for s = 1:numSubjs
        % Load dataset
        filename = fullfile([ds_filepath, subjs{s}, '_', naROI{r}, '_ds']);
        load(filename, 'ds');
        
        % Compute average across runs
        f_ds = cosmo_fx(ds, @(x) mean(x, 1), 'targets');
        
        % Extract and average beta values across categories
        beta_values_matrix(:, r, s) = mean(f_ds.samples(category_indices, :), 2);  
    end
end

% Compute mean across subjects
beta_values_final = mean(beta_values_matrix, 3);
sem = std(beta_values_matrix, 0, 3) / sqrt(numSubjs);

% Compute the average beta values for each ROI across all categories
beta_avg_all_categories = mean(beta_values_final, 1);

% Subtract the average of all categories from each category's values for each ROI
beta_values_adjusted = beta_values_final - beta_avg_all_categories;

% Adjust SEM for the difference
sem_adjusted = std(beta_values_matrix - mean(beta_values_matrix, 1), 0, 3) / sqrt(numSubjs);

% Define custom colors for each category
category_colors = [1 0.5 0; % Bodies (orange)
    1 0.9 0; % Hands (yellow)
    0.7 0.05 0.05; % Faces (red)
    0 0 0.5; % Tools (dark blue)
    0 0 1; % Manip (blue)
    0.7 0.7 1]; %non-Manip (light blue)

condition_names = {'PHC', 'mFG', 'lFG', 'OTS', 'aITG', 'pITG', 'LOS', 'TOS'};
condition_positions = [1, 5.5, 10, 14, 19.5, 24.5, 29.5, 34];

% Limit to the first 35 conditions
beta_values_adjusted = beta_values_adjusted(:, 1:34);
sem_adjusted = sem_adjusted(:, 1:34);

% Plot the mean betas for each category
figure;
x = 1:size(beta_values_adjusted, 2);
plot_handles = zeros(size(beta_values_adjusted, 1), 1);
for i = 1:size(beta_values_adjusted, 1)
    xi = linspace(1, size(beta_values_adjusted, 2), 1000);
    yi = spline(x, beta_values_adjusted(i, :), xi);
    plot_handles(i) = plot(xi, yi, '-', 'LineWidth', 7, 'Color', category_colors(i, :));
    hold on;
    errorbar(x, beta_values_adjusted(i, :), sem_adjusted(i, :), 'LineWidth', 0.5, 'Color', category_colors(i, :));
end

% Add reference lines at 0
line([min(x), max(x)], [0, 0], 'LineStyle', '--', 'Color', 'k');

set(gca, 'XTick', condition_positions, 'XTickLabel', condition_names, 'FontSize', 20, 'TickLength', [0 0]);
ylim([-0.8 0.8]);
xlim([min(x) - 0.5, max(x) + 0.5]);

% Labels and legend
ylabel('Betas', 'FontSize', 20);
reordered_plot_handles = [plot_handles(3); plot_handles(1); plot_handles(2); plot_handles(4); plot_handles(5); plot_handles(6)];
lgd = legend(reordered_plot_handles, {'Faces', 'Bodies', 'Hands', 'Tools', 'Manipulable', 'Non-manipulable'}, 'Orientation', 'horizontal', 'Location', 'southoutside');
lgd.FontSize = 30;
set(lgd, 'Box', 'off');

% Grid and figure properties
grid on;
set(gcf, 'Color', 'w');
hold off;

