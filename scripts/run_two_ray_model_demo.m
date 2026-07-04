% RUN_TWO_RAY_MODEL_DEMO
%
% Reproduces the slide sequence "Two-path channel h(t) = delta(t) +
% 0.9*delta(t-tau)" for tau = 0.1T, T, 1.5T, 4T, showing:
%   - impulse response (stem plot)
%   - frequency response |H(f)| in dB
%   - delay spread (p0, p1, tau_bar, tau_rms) printed and cross-checked
%     against the slide's worked numbers.
%
% See docs/03_small_scale_fading.md for the theory.

clear; close all;
addpath('../src/multipath');

T = 1;                       % normalize symbol period T = 1
tau_values = [0.1 1 1.5 4] * T;
alpha = [1 0.9];

figure('Position', [100 100 1000 800]);

expected = struct( ...
    't01', struct('tau_bar', 0.045, 'tau_rms', 0.05), ...
    't1',  struct('tau_bar', 0.45,  'tau_rms', 0.5), ...
    't15', struct('tau_bar', 0.7,   'tau_rms', 0.6), ...
    't4',  struct('tau_bar', 1.8,   'tau_rms', 2.3) );
exp_fields = {'t01','t1','t15','t4'};

fprintf('%-8s %-8s %-8s %-10s %-10s %-14s %-14s\n', ...
    'tau/T', 'p0', 'p1', 'tau_bar', 'tau_rms', 'tau_bar(slide)', 'tau_rms(slide)');

for i = 1:numel(tau_values)
    tau = [0, tau_values(i)];
    [h_t, H_f, t_axis, f_axis] = multipath_channel_response(alpha, tau, T);
    [tau_bar, tau_rms, p] = delay_spread(alpha, tau);

    exp_i = expected.(exp_fields{i});
    fprintf('%-8.2f %-8.3f %-8.3f %-10.4f %-10.4f %-14.3f %-14.3f\n', ...
        tau_values(i), p(1), p(2), tau_bar, tau_rms, exp_i.tau_bar, exp_i.tau_rms);

    % --- Impulse response ---
    subplot(4,2,2*i-1);
    stem(t_axis, h_t, 'filled', 'MarkerSize', 3);
    xlim([0 5]); ylim([0 1.2]);
    xlabel('Normalized time, t/T'); ylabel('Path gain');
    title(sprintf('Impulse response, \\tau = %.1fT', tau_values(i)));
    grid on;

    % --- Frequency response (dB) ---
    subplot(4,2,2*i);
    plot(f_axis, 20*log10(abs(H_f)), 'LineWidth', 1.5);
    xlim([-0.5 0.5]);
    xlabel('Normalized frequency, fT'); ylabel('Channel gain [dB]');
    title(sprintf('Frequency response, \\tau = %.1fT', tau_values(i)));
    grid on;
end

print(gcf, '../results/two_ray_channel_model.png', '-dpng', '-r150');
fprintf('\nSaved results/two_ray_channel_model.png\n');
