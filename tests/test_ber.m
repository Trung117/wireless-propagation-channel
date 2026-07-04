function test_ber()
% TEST_BER  Validates analytical BER formulas and cross-checks the
% Monte Carlo simulator against them within statistical tolerance.

    addpath('../src/ber');
    rng(123);

    % --- AWGN: known reference values (Q-function tables) ---
    % SNR=0dB (linear=1) -> Pe = 0.5*erfc(1) ~= 0.0786
    Pe0 = ber_awgn_2pam(1);
    assert(abs(Pe0 - 0.0786) < 1e-3, 'FAIL: ber_awgn_2pam(SNR=1) expected ~0.0786, got %.4f', Pe0);
    fprintf('  [PASS] ber_awgn_2pam(SNR=0dB) = %.4f (expected ~0.0786)\n', Pe0);

    % --- Rayleigh flat: at very high SNR, Pe should approach the known
    % 1/(4*SNR) asymptote (derived explicitly on the slide) ---
    snr_hi = 1e4; % 40 dB
    Pe_hi = ber_rayleigh_flat(snr_hi);
    approx = 1/(4*snr_hi);
    rel_err = abs(Pe_hi - approx)/Pe_hi;
    assert(rel_err < 0.01, 'FAIL: high-SNR Rayleigh approx should match within 1%%, got %.2f%%', 100*rel_err);
    fprintf('  [PASS] ber_rayleigh_flat high-SNR asymptote matches 1/(4*SNR) within %.3f%%\n', 100*rel_err);

    % --- Rayleigh is always worse than AWGN at the same SNR ---
    for snr_db = [0 5 10 15 20]
        snr_lin = 10^(snr_db/10);
        assert(ber_rayleigh_flat(snr_lin) > ber_awgn_2pam(snr_lin), ...
            'FAIL: Rayleigh BER should exceed AWGN BER at SNR=%d dB', snr_db);
    end
    fprintf('  [PASS] Rayleigh BER > AWGN BER at all tested SNR points (fading always hurts)\n');

    % --- Monte Carlo cross-check against analytical (loose tolerance,
    % since this is a stochastic test) ---
    snr_lin = 10^(6/10); % 6 dB
    Nbits = 5e5;
    Pe_sim = ber_montecarlo_simulate(snr_lin, Nbits, 'rayleigh');
    Pe_theory = ber_rayleigh_flat(snr_lin);
    rel_err = abs(Pe_sim - Pe_theory)/Pe_theory;
    assert(rel_err < 0.10, ...
        'FAIL: Monte Carlo Rayleigh BER should be within 10%% of theory, got %.1f%% (this is a stochastic test; rerun if it occasionally fails)', 100*rel_err);
    fprintf('  [PASS] Monte Carlo BER (Nbits=%.0e) within %.1f%% of analytical formula\n', Nbits, 100*rel_err);

    % --- ISI channel must show an error floor: Pe at 30dB should not be
    % dramatically lower than Pe at 10dB (unlike the flat-fading case) ---
    Nbits_isi = 5e5;
    Pe_isi_10 = ber_isi_montecarlo(10^(10/10), Nbits_isi, [1 0.81]);
    Pe_isi_30 = ber_isi_montecarlo(10^(30/10), Nbits_isi, [1 0.81]);
    ratio = Pe_isi_10 / Pe_isi_30;
    assert(ratio < 3, ...
        'FAIL: ISI channel should show an error floor (Pe@10dB/Pe@30dB should be small), got ratio=%.2f', ratio);
    fprintf('  [PASS] ISI channel shows error floor: Pe(10dB)/Pe(30dB) = %.2f (flat fading ratio would be ~100x)\n', ratio);

    fprintf('test_ber: ALL TESTS PASSED\n');
end
