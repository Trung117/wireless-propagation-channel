% RUN_DOPPLER_SPECTRUM_DEMO
%
% Reproduces "Time varying channel as a stochastic process" and
% "Channel's coherence time":
%   1) Plots the Jakes' Doppler PSD S_D(f).
%   2) Generates a time-varying Rayleigh fading realization h(t) whose
%      PSD matches S_D(f) (filtered white-noise method).
%   3) Empirically estimates the autocorrelation of h(t) and compares it
%      to the theoretical rho(t) = J0(2*pi*fD*t) (0th-order Bessel
%      function of the first kind) -- this is the key theoretical claim
%      of the slide, verified numerically here.
%   4) Marks the coherence time Tc = 1/(2*fD) on the autocorrelation plot.
%
% See docs/04_doppler_time_varying.md for the theory.

clear; close all;
addpath('../src/doppler');

fD = 100;              % Doppler shift [Hz] (e.g. ~120 km/h at 900 MHz-ish)
fs = 1000;             % channel sampling rate [Hz] (fs > 2*fD required)
N  = 8192;             % number of time-domain samples

rng(3);

% --- 1) Jakes' Doppler PSD ---
f_axis_psd = linspace(-1.2*fD, 1.2*fD, 2000);
S = jakes_doppler_spectrum(f_axis_psd, fD);

figure('Position', [100 100 900 700]);
subplot(2,2,1);
plot(f_axis_psd, S, 'LineWidth', 1.5);
xlabel('Frequency [Hz]'); ylabel('S_D(f)');
title(sprintf('Jakes'' Doppler spectrum (f_D = %d Hz)', fD));
grid on;

% --- 2) Generate time-varying Rayleigh fading with this PSD ---
[h_t, t_axis] = jakes_fading_timeseries(fD, fs, N);

subplot(2,2,2);
plot(t_axis*1000, 20*log10(abs(h_t)), 'LineWidth', 1);
xlabel('Time [ms]'); ylabel('Channel gain |h(t)| [dB]');
title('Generated time-varying Rayleigh fading realization');
grid on;

% --- 3) Empirical autocorrelation vs. theoretical J0 Bessel function ---
max_lag = round(fs / (2*fD) * 4);   % show a few coherence times
lags = 0:max_lag;
acf = zeros(1, numel(lags));
c0 = mean(abs(h_t).^2);   % zero-lag autocorrelation (normalization)
for k = 1:numel(lags)
    L = lags(k);
    acf(k) = real(mean(h_t(1:end-L) .* conj(h_t(1+L:end)))) / c0;
end
t_lags = lags / fs;

rho_theory = besselj(0, 2*pi*fD*t_lags);

subplot(2,2,3);
plot(t_lags*1000, acf, 'b-', 'LineWidth', 1.5); hold on;
plot(t_lags*1000, rho_theory, 'r--', 'LineWidth', 1.5);
xlabel('Time lag [ms]'); ylabel('Autocorrelation \rho(\tau)');
title('Empirical autocorrelation vs. theoretical J_0(2\pi f_D \tau)');
legend('Empirical (simulated channel)', 'Theory: J_0(2\pi f_D \tau)', 'Location', 'northeast');
grid on;

% --- 4) Coherence time ---
Tc = coherence_time(fD);
subplot(2,2,4);
plot(t_lags*1000, acf, 'b-', 'LineWidth', 1.5); hold on;
plot(t_lags*1000, rho_theory, 'r--', 'LineWidth', 1.5);
xline_Tc = Tc*1000;
plot([xline_Tc xline_Tc], [-0.5 1], 'k:', 'LineWidth', 1.5);
text(xline_Tc, 0.6, sprintf('  T_c = %.2f ms', xline_Tc), 'FontSize', 9);
xlabel('Time lag [ms]'); ylabel('Autocorrelation \rho(\tau)');
title('Coherence time T_c = 1/(2f_D)');
grid on;

print(gcf, '../results/doppler_spectrum_and_coherence_time.png', '-dpng', '-r150');
fprintf('Saved results/doppler_spectrum_and_coherence_time.png\n');

% --- Numeric validation ---
rmse = sqrt(mean((acf - rho_theory).^2));
fprintf('\n--- Validation ---\n');
fprintf('Doppler shift fD = %d Hz -> theoretical Tc = 1/(2*fD) = %.4f ms\n', fD, Tc*1000);
fprintf('RMSE between empirical autocorrelation and J0(2*pi*fD*t): %.4f\n', rmse);
fprintf('(Low RMSE confirms the simulated channel reproduces the classical Jakes spectrum.)\n');
