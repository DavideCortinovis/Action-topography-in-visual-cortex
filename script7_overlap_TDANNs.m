clear, clc;

%% Overlap values
% Here I wrote the overlap values as generated with the code from Margalit
% et al. 2024

animate_animate = [0.56, 0.79, 0.70, 0.79, 0.6; ...
                   0.64, 0.70, 0.69, 0.76, 0.67; ...
                   0.56, 0.70, 0.68, 0.64, 0.66];

animate_inanimate = [0.49, 0.58, 0.52, 0.6, 0.4; ...
                     0.50, 0.50, 0.42, 0.5, 0.42; ...
                     0.41, 0.41, 0.46, 0.37, 0.42; ...
                     0.57, 0.66, 0.52, 0.64, 0.57; ...
                     0.58, 0.54, 0.53, 0.59, 0.59; ...
                     0.39, 0.44, 0.42, 0.47, 0.43; ...
                     0.57, 0.61, 0.55, 0.67, 0.55; ...
                     0.58, 0.56, 0.63, 0.62, 0.58; ...
                     0.46, 0.42, 0.47, 0.48, 0.46];

inanimate_inanimate = [0.90, 0.87, 0.57, 0.83, 0.79; ...
                       0.73, 0.81, 0.55, 0.78, 0.75; ...
                       0.69, 0.79, 0.50, 0.73, 0.75];

hand_tool = [0.57, 0.61, 0.55, 0.67, 0.55];
hand_mani = [0.58, 0.56, 0.63, 0.62, 0.58];
hand_nman = [0.46, 0.42, 0.47, 0.48, 0.46];

tool_mani = [0.9, 0.87, 0.57, 0.83, 0.79];
tool_nman = [0.73, 0.81, 0.55, 0.78, 0.75];
mani_nman = [0.69, 0.79, 0.5, 0.73, 0.75];

% Calculate means across models
mean_animate_animate = mean(animate_animate, 1);
mean_animate_inanimate = mean(animate_inanimate, 1);
mean_inanimate_inanimate = mean(inanimate_inanimate, 1);
mean_hand_tool = mean(hand_tool, 1);
mean_hand_mani = mean(hand_mani, 1);
mean_hand_nman = mean(hand_nman, 1);
mean_tool_mani = mean(tool_mani, 1);
mean_tool_nman = mean(tool_nman, 1);
mean_mani_nman = mean(mani_nman, 1);

% Perform paired t-tests
[h1, p1, ci1, stats1] = ttest(mean_inanimate_inanimate, mean_animate_animate);
[h2, p2, ci2, stats2] = ttest(mean_inanimate_inanimate, mean_animate_inanimate);
[h3, p3, ci3, stats3] = ttest(mean_animate_animate, mean_animate_inanimate);
[h4, p4, ci4, stats4] = ttest(mean_hand_tool, mean_hand_mani);

% Display results
disp('Comparison: Inanimate-Inanimate vs Animate-Animate');
disp(['t-value: ', num2str(stats1.tstat), ', p-value: ', num2str(p1)]);
disp(['95% CI: [', num2str(ci1(1)), ', ', num2str(ci1(2)), ']']);

disp('Comparison: Inanimate-Inanimate vs Animate-Inanimate');
disp(['t-value: ', num2str(stats2.tstat), ', p-value: ', num2str(p2)]);
disp(['95% CI: [', num2str(ci2(1)), ', ', num2str(ci2(2)), ']']);

disp('Comparison: Animate-Animate vs Animate-Inanimate');
disp(['t-value: ', num2str(stats3.tstat), ', p-value: ', num2str(p3)]);
disp(['95% CI: [', num2str(ci3(1)), ', ', num2str(ci3(2)), ']']);

%% Plot results
figure;

% Subplot 1: Animate and Inanimate Overlaps
subplot(1, 3, 1); % Create first subplot
% Group means
means_animate = [mean(mean_animate_animate), mean(mean_inanimate_inanimate), mean(mean_animate_inanimate)];

% Standard error (SEM) for each group
sem_animate_animate = std(mean_animate_animate) / sqrt(length(mean_animate_animate));
sem_animate_inanimate = std(mean_animate_inanimate) / sqrt(length(mean_animate_inanimate));
sem_inanimate_inanimate = std(mean_inanimate_inanimate) / sqrt(length(mean_inanimate_inanimate));
sems_animate = [sem_animate_animate, sem_inanimate_inanimate, sem_animate_inanimate];

% Plot with error bars
bars = bar(means_animate, 'FaceColor', 'flat', 'EdgeColor', 'none'); % No black contour
hold on;
errorbar(1:3, means_animate, sems_animate, 'Color', [0.5, 0.5, 0.5], 'LineStyle', 'none', 'LineWidth', 0.75); % Grey thinner error bars

% Set bar colors
bars.CData = [0.9, 0, 0; ... % Dark red for animate-animate
              0, 0, 0.9; ... % Blue for inanimate-inanimate
              1, 0.5, 0];    % Magenta for animate-inanimate

% Dashed line at y = 0.5
yline(0.5, 'k--', 'LineWidth', 1.5);

% Stars and lines
% text(1, 0.81, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
% text(2, 0.81, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
plot([1, 3], [0.85, 0.85], 'k-', 'LineWidth', 1.5); % Line 1-3
text(mean([1, 3]), 0.86, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
plot([2, 3], [0.9, 0.9], 'k-', 'LineWidth', 1.5); % Line 2-3
text(mean([2, 3]), 0.91, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');

set(gca, 'YTickLabel', get(gca, 'YTickLabel'), 'FontSize', 15);
set(gca, 'TickLength', [0 0])

% Configure subplot 1 appearance
% set(gca, 'XTickLabel', {'Animate-Animate', 'Inanimate-Inanimate', 'Animate-Inanimate'}, 'FontSize', 8);
ylim([0 1]);
% ylabel('Overlap Score', 'FontSize', 12);
% title('Animate/Inanimate Overlaps', 'FontSize', 15);
% grid on;
box off; % Remove black box around the plot
axis square;

% Subplot 2: Hand Overlaps
subplot(1, 3, 2); % Create second subplot
means_hand = [mean(mean_hand_tool), mean(mean_hand_mani), mean(mean_hand_nman)];

% SEM for hand overlaps
sem_hand_tool = std(hand_tool) / sqrt(length(hand_tool));
sem_hand_mani = std(hand_mani) / sqrt(length(hand_mani));
sem_hand_nman = std(hand_nman) / sqrt(length(hand_nman));
sems_hand = [sem_hand_tool, sem_hand_mani, sem_hand_nman];

% Plot with error bars
bars_hand = bar(means_hand, 'FaceColor', 'flat', 'EdgeColor', 'none'); % No black contour
hold on;
errorbar(1:3, means_hand, sems_hand, 'Color', [0.5, 0.5, 0.5], 'LineStyle', 'none', 'LineWidth', 0.75); % Grey thinner error bars

% Set bar colors
bars_hand.CData = [1, 0.9, 0; ... % Green for hand-tool
                   1, 0.5, 0; ...
                   1, 0.1, 0];    % Orange for hand-mani

% Dashed line at y = 0.5
yline(0.5, 'k--', 'LineWidth', 1.5);

% text(1, 0.67, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
% text(2, 0.67, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');

set(gca, 'YTick', [], 'FontSize', 15);

% Configure subplot 2 appearance
% set(gca, 'XTickLabel', {'Hand-Tool', 'Hand-Manip', 'Hand-Non-Manip'}, 'FontSize', 8);
ylim([0 1]);
% ylabel('Overlap Score', 'FontSize', 12);
% title('Hand Overlaps', 'FontSize', 12);
box off; % Remove black box around the plot
axis square;

% Overall Figure Title
sgtitle('Category and Hand Overlaps', 'FontSize', 20); % Add a shared title

%% subplot 3
subplot(1, 3, 3); % Create second subplot
means_tools = [mean(mean_tool_mani), mean(mean_tool_nman), mean(mean_mani_nman)];

% SEM for hand overlaps
sem_tool_mani = std(tool_mani) / sqrt(length(tool_mani));
sem_tool_nman = std(tool_nman) / sqrt(length(tool_nman));
sem_mani_nman = std(mani_nman) / sqrt(length(mani_nman));
sems_tools = [sem_tool_mani, sem_tool_nman, sem_mani_nman];

% Plot with error bars
bars_hand = bar(means_tools, 'FaceColor', 'flat', 'EdgeColor', 'none'); % No black contour
hold on;
errorbar(1:3, means_tools, sems_tools, 'Color', [0.5, 0.5, 0.5], 'LineStyle', 'none', 'LineWidth', 0.75); % Grey thinner error bars

% Set bar colors
bars_hand.CData = [0, 0, 1; ...
                   0, 0, 0.75; ...
                   0, 0, 0.5];  

% Dashed line at y = 0.5
yline(0.5, 'k--', 'LineWidth', 1.5);

% text(1, 0.87, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
% text(2, 0.87, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
% text(3, 0.87, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');
plot([1, 3], [0.9, 0.9], 'k-', 'LineWidth', 1.5); % Line 1-3
text(mean([1, 3]), 0.91, '*', 'HorizontalAlignment', 'center', 'FontSize', 15, 'FontWeight', 'bold');

set(gca, 'YTick', [], 'FontSize', 15);

% Configure subplot 2 appearance
% set(gca, 'XTickLabel', {'Hand-Tool', 'Hand-Manip', 'Hand-Non-Manip'}, 'FontSize', 8);
ylim([0 1]);
% ylabel('Overlap Score', 'FontSize', 12);
% title('Hand Overlaps', 'FontSize', 12);
box off; % Remove black box around the plot
axis square;

% Overall Figure Title
sgtitle('Category and Hand Overlaps', 'FontSize', 20); % Add a shared title