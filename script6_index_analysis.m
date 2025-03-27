
%% Script to perform the index analysis
%what is the index analysis? We have a correlation matrix of 6x6 (pairwise
%correlation among our categories). To test the relative distance in the
%object space of the 6 categories, we can perform some calculations on
%that matrix. First, we will extract the correlation values (for instance
%the correlation between hands and tools, let's say = 0.5, or the
%correlation between hands and manipulable, = 0.1). Then, we can calculate
%how the two differ: hands&tools - hands&manipulable = 0.4. Which means
%that hands are much closer (= correlated) with tools than with manipulable
%in that ROI. We do the same calculation for all ROIs along the vector, and
%for all participants, perform t-test, average the results, and plot them
clear, clc, close all

addpath('path\multivariate')
load('SingleSubj_ROIs_RDM.mat') %output of script4

num_Rs = 34;
num_subs = 18;

% Preallocate arrays
Action_hand_allspheres = zeros(num_subs, num_Rs);
Grasp_hand_allspheres = zeros(num_subs, num_Rs);
Action_face_allspheres = zeros(num_subs, num_Rs);
Grasp_face_allspheres = zeros(num_subs, num_Rs);
Action_body_allspheres = zeros(num_subs, num_Rs);
Grasp_body_allspheres = zeros(num_subs, num_Rs);

ActionHands_all = zeros(1, num_Rs);
ActionFaces_all = zeros(1, num_Rs);
ActionBodies_all = zeros(1, num_Rs);

GraspHands_all = zeros(1, num_Rs);
GraspFaces_all = zeros(1, num_Rs);
GraspBodies_all = zeros(1, num_Rs);

std_error_faces_action_all = zeros(1, num_Rs);
std_error_bodies_action_all = zeros(1, num_Rs);
std_error_hands_action_all = zeros(1, num_Rs);

std_error_faces_grasp_all = zeros(1, num_Rs);
std_error_bodies_grasp_all = zeros(1, num_Rs);
std_error_hands_grasp_all = zeros(1, num_Rs);

stats_action_all_hands = cell(1, num_Rs);
stats_action_all_faces = cell(1, num_Rs);
stats_action_all_bodies = cell(1, num_Rs);

stats_grasp_all_hands = cell(1, num_Rs);
stats_grasp_all_faces = cell(1, num_Rs);
stats_grasp_all_bodies = cell(1, num_Rs);

%% Main loop
for rr = 1:num_Rs
    matrix_data = RDM.data{1, rr};
    num_subs = size(matrix_data, 2);
    
    ActionHands = zeros(1, num_subs);
    ActionFaces = zeros(1, num_subs);
    ActionBodies = zeros(1, num_subs);
    
    GraspHands = zeros(1, num_subs);
    GraspFaces = zeros(1, num_subs);
    GraspBodies = zeros(1, num_subs);

    for sub = 1:num_subs
        matrix_temp = 1 - cosmo_squareform(matrix_data(:, sub)); % from dissimilarity to similarity (more intuitive to visualize)

        % Compute indices
        ActionFaces(sub) = matrix_temp(3,4) - matrix_temp(3,5);
        ActionBodies(sub) = matrix_temp(1,4) - matrix_temp(1,5);
        ActionHands(sub) = matrix_temp(2,4) - matrix_temp(2,5);

        GraspHands(sub) = matrix_temp(2,5) - matrix_temp(2,6);
        GraspFaces(sub) = matrix_temp(3,5) - matrix_temp(3,6);
        GraspBodies(sub) = matrix_temp(1,5) - matrix_temp(1,6);
    end
    
    % Store values
    Action_hand_allspheres(:, rr) = ActionHands;
    Grasp_hand_allspheres(:, rr) = GraspHands;
    Action_face_allspheres(:, rr) = ActionFaces;
    Grasp_face_allspheres(:, rr) = GraspFaces;
    Action_body_allspheres(:, rr) = ActionBodies;
    Grasp_body_allspheres(:, rr) = GraspBodies;

    ActionHands_all(rr) = mean(ActionHands);
    ActionFaces_all(rr) = mean(ActionFaces);
    ActionBodies_all(rr) = mean(ActionBodies);
    
    GraspHands_all(rr) = mean(GraspHands);
    GraspFaces_all(rr) = mean(GraspFaces);
    GraspBodies_all(rr) = mean(GraspBodies);

    % Compute standard errors
    std_error_faces_action_all(rr) = std(ActionFaces) / sqrt(num_subs);
    std_error_bodies_action_all(rr) = std(ActionBodies) / sqrt(num_subs);
    std_error_hands_action_all(rr) = std(ActionHands) / sqrt(num_subs);

    std_error_faces_grasp_all(rr) = std(GraspFaces) / sqrt(num_subs);
    std_error_bodies_grasp_all(rr) = std(GraspBodies) / sqrt(num_subs);
    std_error_hands_grasp_all(rr) = std(GraspHands) / sqrt(num_subs);
    
    % Perform and store t-tests
    [~, stats_action_all_hands{rr}] = ttest(ActionHands);
    [~, stats_action_all_faces{rr}] = ttest(ActionFaces);
    [~, stats_action_all_bodies{rr}] = ttest(ActionBodies);
    
    [~, stats_grasp_all_hands{rr}] = ttest(GraspHands);
    [~, stats_grasp_all_faces{rr}] = ttest(GraspFaces);
    [~, stats_grasp_all_bodies{rr}] = ttest(GraspBodies);
end

action_cell = {Action_face_allspheres', Action_body_allspheres', Action_hand_allspheres'};
grasp_cell = {Grasp_face_allspheres', Grasp_body_allspheres', Grasp_hand_allspheres'};

condition_names = {'PHC', 'mFG', 'lFG', 'OTS', 'aITG', 'pITG', 'LOS', 'TOS'};
condition_positions = [1, 5.5, 10, 14, 19.5, 24.5, 29.5, 34];

%% Plotting
figure;

x = 1:num_Rs;
plot(x, ActionFaces_all, 'Color', [0.87 0.05 0.05], 'LineWidth', 3.5);
hold on;
plot(x, ActionBodies_all, 'Color', [1 0.4 0], 'LineWidth', 3.5);
plot(x, ActionHands_all, 'Color', [1 0.9 0], 'LineWidth', 3.5);

% Plot shaded regions for standard error
fill([x, fliplr(x)], [ActionFaces_all + std_error_faces_action_all, fliplr(ActionFaces_all - std_error_faces_action_all)], 'r', 'FaceAlpha', 0.2, 'EdgeColor','none');
fill([x, fliplr(x)], [ActionBodies_all + std_error_bodies_action_all, fliplr(ActionBodies_all - std_error_bodies_action_all)], [1 0.65 0], 'FaceAlpha', 0.2, 'EdgeColor','none');
fill([x, fliplr(x)], [ActionHands_all + std_error_hands_action_all, fliplr(ActionHands_all - std_error_hands_action_all)], [1 1 0], 'FaceAlpha', 0.2, 'EdgeColor','none');

% Add dashed horizontal line at y = 0
line([min(x), max(x)], [0, 0], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');

% Positions for significant lines
y_pos_hands = max(ActionHands_all) + 0.15; % Adjust as needed
y_pos_faces = max(ActionHands_all) + 0.10; % Adjust as needed
y_pos_bodies = max(ActionHands_all) + 0.125; % Adjust as needed

% Add horizontal lines for significant ActionHands_all, ActionFaces_all, ActionBodies_all
for rr = 1:num_Rs
    if stats_action_all_hands{rr} < 0.0015 && ActionHands_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_hands, y_pos_hands], 'Color', [1 0.9 0], 'LineWidth', 3);
    end
    if stats_action_all_faces{rr} < 0.0015 && ActionFaces_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_faces, y_pos_faces], 'Color', [0.87 0.05 0.05], 'LineWidth', 3);
    end
    if stats_action_all_bodies{rr} < 0.0015 && ActionBodies_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_bodies, y_pos_bodies], 'Color', [1 0.4 0], 'LineWidth', 3);
    end
end

xlim([min(x) - 0.5, max(x) + 0.5]);

% Customize axes and labels
set(gca, 'XTick', condition_positions, 'XTickLabel', condition_names, 'FontSize', 30, 'TickLength', [0 0]);
ylabel('Correlation', 'FontSize', 30);
title('Action Index', 'FontSize', 30);
legend('Faces', 'Bodies', 'Hands', 'FontSize', 30, 'Location', 'southoutside', 'Orientation', 'horizontal');
legend boxoff;
grid on;


%%%% GRASP
figure;

% Plot Grasp index
x = 1:num_Rs;
plot(x, GraspFaces_all, 'Color', [0.87 0.05 0.05], 'LineWidth', 3.5);
hold on;
plot(x, GraspBodies_all, 'Color', [1 0.4 0], 'LineWidth', 3.5);
plot(x, GraspHands_all, 'Color', [1 0.9 0], 'LineWidth', 3.5);
ylim([-1 1])
% Plot shaded regions for standard error
fill([x, fliplr(x)], [GraspFaces_all + std_error_faces_grasp_all, fliplr(GraspFaces_all - std_error_faces_grasp_all)], 'r', 'FaceAlpha', 0.2, 'EdgeColor','none');
fill([x, fliplr(x)], [GraspBodies_all + std_error_bodies_grasp_all, fliplr(GraspBodies_all - std_error_bodies_grasp_all)], [1 0.65 0], 'FaceAlpha', 0.2, 'EdgeColor','none');
fill([x, fliplr(x)], [GraspHands_all + std_error_hands_grasp_all, fliplr(GraspHands_all - std_error_hands_grasp_all)], [1 1 0], 'FaceAlpha', 0.2, 'EdgeColor','none');

% Add vertical black line at y = 0
hold on;
line([min(x), max(x)], [0, 0], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');

% Add dashed horizontal line at y = 0
line([min(x), max(x)], [0, 0], 'Color', 'k', 'LineWidth', 2, 'LineStyle', '--');

% Add horizontal lines for significant GraspHands_all, GraspFaces_all, GraspBodies_all
for rr = 1:num_Rs
    if stats_grasp_all_hands{rr} < 0.0015 && GraspHands_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_hands, y_pos_hands], 'Color', [1 0.9 0], 'LineWidth', 3);
    end
    if stats_grasp_all_faces{rr} < 0.0015 && GraspFaces_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_faces, y_pos_faces], 'Color', [0.87 0.05 0.05], 'LineWidth', 3);
    end
    if stats_grasp_all_bodies{rr} < 0.0015 && GraspBodies_all(rr) > 0
        line([rr-0.5, rr+0.5], [y_pos_bodies, y_pos_bodies], 'Color', [1 0.4 0], 'LineWidth', 3);
    end
end

xlim([min(x) - 0.5, max(x) + 0.5]);

set(gca, 'XTick', condition_positions, 'XTickLabel', condition_names, 'FontSize', 30, 'TickLength', [0 0]);
% xlabel('ROIs', 'FontSize', 20);
ylabel('Correlation', 'FontSize', 30);
title('Grasp Index', 'FontSize', 30);
legend('Faces', 'Bodies', 'Hands', 'FontSize', 30, 'Location', 'southoutside', 'Orientation','horizontal');
legend boxoff      
grid on;