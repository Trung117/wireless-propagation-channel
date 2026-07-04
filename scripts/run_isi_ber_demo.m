% RUN_ISI_BER_DEMO
%
% Reproduces "BER on multipath Rayleigh fading channel": without
% equalization, ISI from a frequency-selective multipath channel causes
% an IRREDUCIBLE ERROR FLOOR -- Pe stops improving even as SNR -> infinity.
%
% This is simulated with a two-tap Rayleigh channel (mimicking the
% slide's h(t) = delta(t) + 0.9*delta(t-tau), tap powers [1, 0.81]) and
% compared against the flat Rayleigh fading curve (no ISI) from
% run_rayleigh_ber_demo.m.
%
% See docs/05_ber_analysis.md for the theory.

clear; close all;
addpath('../src/ber');

rng(7);

SNR_dB  = 0:2:30;
SNR_lin = 10.^(SNR_dB/10);
Nbits = 2e6;

Pe_flat_theory = ber_rayleigh_flat(SNR_lin);
Pe_isi_sim     = zeros(size(SNR_dB));

fprintf('Running ISI Monte Carlo simulation (two-tap Rayleigh channel, no equalization)...\n');
for i = 1:numel(SNR_dB)
    Pe_isi_sim(i) = ber_isi_montecarlo(SNR_lin(i), Nbits, [1 0.81]);
    fprintf('  SNR = %5.1f dB | Frequency-selective (ISI, sim) = %.4e | Flat fading (theory) = %.4e\n', ...
        SNR_dB(i), Pe_isi_sim(i), Pe_flat_theory(i));
end

figure('Position', [100 100 700 550]);
semilogy(SNR_dB, Pe_flat_theory, 'r-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, Pe_isi_sim, 'b-s', 'LineWidth', 1.5, 'MarkerSize', 5);
grid on;
xlabel('SNR = E_b/N_0 [dB]'); ylabel('Bit Error Rate');
legend('Flat Rayleigh fading (no ISI)', 'Frequency-selective, no equalizer (ISI floor)', ...
       'Location', 'southwest');
title('Irreducible error floor caused by unequalized ISI');
ylim([1e-3 1]);

print(gcf, '../results/isi_error_floor.png', '-dpng', '-r150');
fprintf('\nSaved results/isi_error_floor.png\n');

fprintf('\n--- Interpretation ---\n');
fprintf('Flat fading Pe keeps decreasing with SNR (down to %.2e at %d dB).\n', Pe_flat_theory(end), SNR_dB(end));
fprintf('ISI channel Pe flattens out near %.2e and barely improves beyond ~15-20 dB,\n', Pe_isi_sim(end));
fprintf('confirming the "irreducible error-floor" behavior described in the slide.\n');
