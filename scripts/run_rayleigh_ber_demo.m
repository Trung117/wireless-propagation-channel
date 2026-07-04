% RUN_RAYLEIGH_BER_DEMO
%
% Reproduces "Flat fading channel: BER on AWGN" and "BER on flat Rayleigh
% fading channel". Runs a bit-level Monte Carlo simulation of BPSK/2-PAM
% over (a) an AWGN channel and (b) a flat Rayleigh fading channel, and
% overlays the closed-form analytical curves:
%
%   AWGN:     Pe = Q(sqrt(2*SNR))
%   Rayleigh: Pe = 0.5*(1 - sqrt(SNR_bar/(1+SNR_bar)))
%
% This is the qualitative headline result of the whole deck: fading
% converts an exponential BER decay into a much slower ~1/SNR decay.
%
% See docs/05_ber_analysis.md for the theory and derivation.

clear; close all;
addpath('../src/ber');

rng(1);

SNR_dB = 0:2:30;
SNR_lin = 10.^(SNR_dB/10);
Nbits = 2e6;  % Monte Carlo trials per SNR point

Pe_awgn_sim      = zeros(size(SNR_dB));
Pe_rayleigh_sim  = zeros(size(SNR_dB));
Pe_awgn_theory     = ber_awgn_2pam(SNR_lin);
Pe_rayleigh_theory = ber_rayleigh_flat(SNR_lin);

fprintf('Running Monte Carlo BER simulation (%.0e bits/point)...\n', Nbits);
for i = 1:numel(SNR_dB)
    Pe_awgn_sim(i)     = ber_montecarlo_simulate(SNR_lin(i), Nbits, 'awgn');
    Pe_rayleigh_sim(i) = ber_montecarlo_simulate(SNR_lin(i), Nbits, 'rayleigh');
    fprintf('  SNR = %5.1f dB | AWGN: sim=%.3e theory=%.3e | Rayleigh: sim=%.3e theory=%.3e\n', ...
        SNR_dB(i), Pe_awgn_sim(i), Pe_awgn_theory(i), Pe_rayleigh_sim(i), Pe_rayleigh_theory(i));
end

figure('Position', [100 100 700 550]);
semilogy(SNR_dB, Pe_awgn_theory, 'k-', 'LineWidth', 2); hold on;
semilogy(SNR_dB, Pe_awgn_sim, 'ko', 'MarkerSize', 5);
semilogy(SNR_dB, Pe_rayleigh_theory, 'r-', 'LineWidth', 2);
semilogy(SNR_dB, Pe_rayleigh_sim, 'rs', 'MarkerSize', 5);
grid on;
xlabel('SNR = E_b/N_0 [dB]'); ylabel('Bit Error Rate');
legend('AWGN (theory)', 'AWGN (Monte Carlo)', ...
       'Rayleigh flat fading (theory)', 'Rayleigh flat fading (Monte Carlo)', ...
       'Location', 'southwest');
title('BPSK/2-PAM: AWGN vs. flat Rayleigh fading channel');
ylim([1e-5 1]);

print(gcf, '../results/rayleigh_ber_awgn_comparison.png', '-dpng', '-r150');
fprintf('\nSaved results/rayleigh_ber_awgn_comparison.png\n');

% --- Sanity check: high-SNR Rayleigh floor should approach 1/(4*SNR) ---
approx_floor = 1 ./ (4*SNR_lin);
rel_err = abs(Pe_rayleigh_theory - approx_floor) ./ Pe_rayleigh_theory;
fprintf('\nHigh-SNR approximation check (Pe ~= 1/(4*SNR_bar)):\n');
fprintf('  At SNR = %d dB: exact=%.4e, approx=%.4e, rel.err=%.2f%%\n', ...
    SNR_dB(end), Pe_rayleigh_theory(end), approx_floor(end), 100*rel_err(end));
