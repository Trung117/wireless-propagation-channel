% RUN_FULL_CHANNEL_SIMULATION
%
% Reproduces the slide's capstone worked example, "Fading channel
% example":
%
%   fc = 2.1 GHz, suburban area (sigma_tau = 2 us), mobile speed 90 km/h
%   (v = 25 m/s), signal bandwidth Bs = 2 MHz (=> T ~= 1/Bs = 500 ns).
%
% and uses it to classify the channel along BOTH axes described in
% "Small-scale fading recap":
%   - flat vs. frequency-selective (via delay spread vs. symbol period)
%   - slow vs. fast fading         (via coherence time vs. symbol period)
%
% This script ties together every module built in this project:
%   src/doppler   -> Doppler shift & coherence time
%   src/multipath -> coherence bandwidth
% and prints a full "channel characterization report", the way you would
% for a real link budget / system design exercise.

clear; close all;
addpath('../src/doppler', '../src/multipath', '../src/path_loss');

fprintf('=====================================================\n');
fprintf(' WIRELESS CHANNEL CHARACTERIZATION - WORKED EXAMPLE\n');
fprintf(' (reproduces slide "Fading channel example")\n');
fprintf('=====================================================\n\n');

% --- Scenario parameters ---
fc = 2.1e9;         % carrier frequency [Hz]
v_kmh = 90;         % mobile speed [km/h]
v = v_kmh / 3.6;    % [m/s]
sigma_tau = 2e-6;   % RMS delay spread, suburban area [s]
Bs = 2e6;           % signal bandwidth [Hz]
T = 1/Bs;           % symbol period (approx.) [s]

fprintf('Scenario:\n');
fprintf('  Carrier frequency        fc = %.2f GHz\n', fc/1e9);
fprintf('  Mobile speed             v  = %.0f km/h (%.1f m/s)\n', v_kmh, v);
fprintf('  RMS delay spread         sigma_tau = %.1f us (suburban area)\n', sigma_tau*1e6);
fprintf('  Signal bandwidth         Bs = %.1f MHz\n', Bs/1e6);
fprintf('  Symbol period (approx)   T ~= 1/Bs = %.0f ns\n\n', T*1e9);

% --- Doppler analysis ---
fD = doppler_shift(v, fc);
Tc = coherence_time(fD);

fprintf('Doppler analysis:\n');
fprintf('  Doppler shift   fD = v/lambda = v*fc/c = %.1f Hz\n', fD);
fprintf('  Coherence time  Tc = 1/(2*fD) = %.3f ms\n\n', Tc*1e3);

% --- Delay-spread / coherence-bandwidth analysis ---
Bc = coherence_bandwidth(sigma_tau);

fprintf('Delay-spread analysis:\n');
fprintf('  Coherence bandwidth  Bc = 1/(5*sigma_tau) = %.1f kHz\n\n', Bc/1e3);

% --- Classification (matches slide's conclusion) ---
fprintf('Classification:\n');
if Tc > T
    fading_speed = 'SLOW fading (Tc >> T)';
else
    fading_speed = 'FAST fading (Tc < T)';
end

if Bc < Bs
    freq_selectivity = 'FREQUENCY-SELECTIVE (Bc < Bs, equivalently sigma_tau > T)';
else
    freq_selectivity = 'FLAT (Bc > Bs, equivalently sigma_tau < T)';
end

fprintf('  Time-domain:      %s\n', fading_speed);
fprintf('  Frequency-domain: %s\n\n', freq_selectivity);

fprintf('  --> Matches the slide''s conclusion: "The channel is slow\n');
fprintf('      (Tc >> T or v << fD) and frequency-selective (sigma_tau > T\n');
fprintf('      or T < sigma_tau)."\n\n');

% --- Bonus: sensitivity plot -- classification map across speed & BW ---
v_range_kmh = linspace(3, 300, 200);       % pedestrian to high-speed rail
Bs_range_Hz = logspace(3, 7, 200);         % 1 kHz to 10 MHz

[Vg, Bg] = meshgrid(v_range_kmh, Bs_range_Hz);
Vg_mps = Vg / 3.6;
Tg = 1 ./ Bg;
fDg = doppler_shift(Vg_mps, fc);
Tcg = coherence_time(fDg);

is_fast = Tcg < Tg;                    % 1 = fast fading, 0 = slow
is_freqsel = sigma_tau > Tg;           % 1 = frequency-selective

figure('Position', [100 100 800 650]);
region_code = is_fast*2 + is_freqsel;  % 0..3, four combinations

pcolor(Vg, Bg/1e6, region_code); shading flat;
set(gca, 'YScale', 'log');
colormap([0.6 0.8 1; 1 0.8 0.6; 0.6 1 0.7; 1 0.6 0.6]);
caxis([-0.5 3.5]);   % align integer codes 0..3 to discrete colormap bins
                      % (without this, pcolor's auto color-scaling
                      % misaligns bin edges and mixes up the 4 colors)
hold on;
plot(v_kmh, Bs/1e6, 'kp', 'MarkerSize', 16, 'MarkerFaceColor', 'y');
text(v_kmh, Bs/1e6*1.4, '  This example', 'FontWeight', 'bold');
xlabel('Mobile speed [km/h]'); ylabel('Signal bandwidth [MHz]');
title(sprintf('Channel classification map (f_c = %.1f GHz, \\sigma_\\tau = %.0f \\mus)', fc/1e9, sigma_tau*1e6));

% Manual legend (colorbar tick labeling is unreliable across
% MATLAB/Octave versions, so four labeled color patches are used instead)
legend_labels = {'Slow, Flat', 'Slow, Freq-selective', 'Fast, Flat', 'Fast, Freq-selective'};
legend_colors = [0.6 0.8 1; 1 0.8 0.6; 0.6 1 0.7; 1 0.6 0.6];
hleg = zeros(1,4);
for k = 1:4
    hleg(k) = patch(NaN, NaN, legend_colors(k,:));
end
legend(hleg, legend_labels, 'Location', 'northoutside', 'Orientation', 'horizontal');

print(gcf, '../results/channel_classification_map.png', '-dpng', '-r150');
fprintf('Saved results/channel_classification_map.png\n');
