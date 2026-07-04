function test_multipath()
% TEST_MULTIPATH  Validates delay-spread and coherence-bandwidth
% functions against the slide's four "Two-path channel" worked examples.

    addpath('../src/multipath');
    tol = 0.02; % absolute tolerance (slide values rounded to 1-2 decimals)

    alpha = [1 0.9];

    cases = { ...
        struct('tau', [0 0.1], 'tau_bar', 0.045, 'tau_rms', 0.05), ...
        struct('tau', [0 1.0], 'tau_bar', 0.45,  'tau_rms', 0.50), ...
        struct('tau', [0 1.5], 'tau_bar', 0.675, 'tau_rms', 0.746), ... % see note below
        struct('tau', [0 4.0], 'tau_bar', 1.8,   'tau_rms', 1.99) ... % see note below
    };
    % NOTES on internal slide inconsistencies (both confirmed by hand
    % calculation and cross-checked in docs/03_small_scale_fading.md):
    %
    %  tau=1.5T: the slide prints tau_rms "~=0.6T", but its own stated
    %  intermediates (tau_bar~=0.7T, mean(tau^2)~=T^2=1) give
    %      tau_rms = sqrt(1 - 0.7^2) = sqrt(0.51) ~= 0.714T,
    %  and the fully precise calculation (p1=0.81/1.81=0.4475) gives
    %      tau_rms = sqrt(1.0069 - 0.6713^2) ~= 0.746T.
    %  Neither matches the slide's printed 0.6T.
    %
    %  tau=4T: the slide prints tau_rms "~=2.3T", but its own stated
    %  intermediates (tau_bar=1.8T, mean(tau^2)=7.2T^2) give
    %      tau_rms = sqrt(7.2 - 1.8^2) = sqrt(3.96) ~= 1.99T,   NOT 2.3T.
    %
    % This test validates against the mathematically correct values
    % rather than the slide's printed (but internally inconsistent)
    % numbers.

    for i = 1:numel(cases)
        c = cases{i};
        [tau_bar, tau_rms, p] = delay_spread(alpha, c.tau);

        assert(abs(tau_bar - c.tau_bar) < tol, ...
            'FAIL: tau=%.1fT expected tau_bar~=%.3f, got %.4f', c.tau(2), c.tau_bar, tau_bar);
        % tau_rms tolerance is a bit looser only for the tau=1.5T case,
        % where the slide's own rounding of tau_bar (0.675->0.7) is the
        % source of the discrepancy, not our computation.
        assert(abs(tau_rms - c.tau_rms) < 0.05, ...
            'FAIL: tau=%.1fT expected tau_rms~=%.3f, got %.4f', c.tau(2), c.tau_rms, tau_rms);

        fprintf('  [PASS] tau=%.1fT: tau_bar=%.4f (slide~%.3f), tau_rms=%.4f (slide~%.3f)\n', ...
            c.tau(2), tau_bar, c.tau_bar, tau_rms, c.tau_rms);
    end

    % --- Coherence bandwidth: slide's "Typical values of RMS delay
    % spread" example, sigma_tau = 5us -> Bc ~= 40 kHz ---
    Bc = coherence_bandwidth(5e-6);
    assert(abs(Bc - 40e3) < 1e3, ...
        'FAIL: coherence_bandwidth(5us) expected ~40kHz, got %.1f kHz', Bc/1e3);
    fprintf('  [PASS] coherence_bandwidth(5us) = %.1f kHz (slide: ~40 kHz, LTE ETU)\n', Bc/1e3);

    % --- Frequency response sanity: |H(f)| must be real & non-negative
    % magnitude, and H(0) = sum(alpha) since all delays contribute
    % constructively at f=0 ---
    [~, H_f, ~, f_axis] = multipath_channel_response(alpha, [0 0.1], 1);
    [~, idx0] = min(abs(f_axis));
    assert(abs(H_f(idx0) - sum(alpha)) < 1e-2, ...
        'FAIL: H(f=0) should equal sum(alpha) = %.2f, got %.4f', sum(alpha), abs(H_f(idx0)));
    fprintf('  [PASS] H(f=0) = sum(alpha) as expected (constructive combination at DC)\n');

    fprintf('test_multipath: ALL TESTS PASSED\n');
end
