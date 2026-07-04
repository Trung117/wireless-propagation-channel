% RUN_LARGE_SCALE_FADING_DEMO
%
% Reproduces the slide figure that decomposes the observed fading profile
% into three additive (in dB) components:
%
%   P_Rx[dBm] = P_Tx[dBm] + A_PL[dB] + A_S[dB] + A_SS[dB]
%
%   A_PL - deterministic path loss (log-distance model)
%   A_S  - log-normal shadowing (slowly varying random component)
%   A_SS - small-scale fading (fast oscillation, order of a wavelength)
%
% See docs/02_large_scale_fading.md for the theory.

clear; close all;
addpath('../src/path_loss', '../src/shadowing', '../src/fading');

rng(42); % reproducibility

% --- Distance axis (log scale, 1 m to 1000 m) ---
d0 = 1;                       % reference distance [m]
d  = logspace(0, 3, 2000);    % 1 m to 1000 m

% --- 1) Deterministic path loss (urban, n = 3.5) ---
n = 3.5;
PL_d0 = 40; % dB, arbitrary reference loss at d0
A_PL = -log_distance_path_loss(d, d0, n, PL_d0);   % negative = attenuation

% --- 2) Log-normal shadowing (sigma = 6 dB), correlated over distance ---
sigma_shadow = 6;
raw_shadow = lognormal_shadowing(sigma_shadow, numel(d));
% Smooth to make it vary "slowly" over distance (shadowing changes over
% tens of meters, not centimeters) -- a simple moving-average filter:
A_S = filter(ones(1,40)/40, 1, raw_shadow);

% --- 3) Small-scale fading (fast oscillation, Rayleigh in linear scale) ---
alpha = rayleigh_fading_gen(numel(d));
A_SS = 20*log10(alpha);   % power fading in dB, zero-mean-ish fluctuation

% --- Composite ---
P_Tx = 0; % dBm, normalize Tx power to 0 dBm for this illustration
P_Rx_pathloss_only   = P_Tx + A_PL;
P_Rx_with_shadowing  = P_Tx + A_PL + A_S;
P_Rx_full            = P_Tx + A_PL + A_S + A_SS;

% --- Plot (mirrors the slide's 3-panel + composite figure) ---
figure('Position', [100 100 900 700]);

subplot(2,2,1);
plot(log10(d/d0), A_PL, 'LineWidth', 2);
xlabel('log_{10}(d/d_0)'); ylabel('Signal attenuation [dB]');
title('Path-loss (deterministic)'); grid on;

subplot(2,2,2);
plot(log10(d/d0), A_S, 'LineWidth', 1.2);
xlabel('log_{10}(d/d_0)'); ylabel('Shadowing [dB]');
title(sprintf('Shadowing (\\sigma = %d dB)', sigma_shadow)); grid on;

subplot(2,2,3);
plot(log10(d/d0), A_SS, 'LineWidth', 0.8);
xlabel('log_{10}(d/d_0)'); ylabel('Small-scale fading [dB]');
title('Small-scale (Rayleigh) fading'); grid on;

subplot(2,2,4);
plot(log10(d/d0), P_Rx_pathloss_only, 'k--', 'LineWidth', 2); hold on;
plot(log10(d/d0), P_Rx_with_shadowing, 'b:', 'LineWidth', 1.2);
plot(log10(d/d0), P_Rx_full, 'r-', 'LineWidth', 0.6);
xlabel('log_{10}(d/d_0)'); ylabel('Received power [dBm]');
title('Observed fading profile (sum of all three)');
legend('Path loss only', '+ Shadowing', '+ Small-scale fading', 'Location', 'southwest');
grid on;

% (sgtitle is not available in Octave; use annotation for a super-title)
annotation('textbox', [0 0.96 1 0.04], 'String', ...
    'Large-scale fading decomposition: Path-loss + Shadowing + Small-scale fading', ...
    'EdgeColor', 'none', 'HorizontalAlignment', 'center', 'FontWeight', 'bold');

print(gcf, '../results/large_scale_fading_decomposition.png', '-dpng', '-r150');
fprintf('Saved results/large_scale_fading_decomposition.png\n');

% --- Numeric sanity check printed to console ---
fprintf('\n--- Sanity check ---\n');
fprintf('Path loss at d=%.0fm (n=%.1f): %.2f dB\n', d0, n, -A_PL(1));
fprintf('Path loss at d=%.0fm (n=%.1f): %.2f dB\n', d(end), n, -A_PL(end));
fprintf('Expected slope: 10*n = %.1f dB/decade -> observed: %.2f dB/decade\n', ...
    10*n, (-A_PL(end)+A_PL(1))/log10(d(end)/d0));
