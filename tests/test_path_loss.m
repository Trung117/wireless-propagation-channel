function test_path_loss()
% TEST_PATH_LOSS  Validates path-loss functions against the slide's
% worked numerical examples.

    addpath('../src/path_loss');
    tol = 0.5; % dB tolerance (slide values are rounded)

    % --- Free-space path loss: slide's "Physics of wireless signal
    % propagation" example at 3 GHz ---
    [Pr_1m, ~]  = free_space_path_loss(0, 3e9, 1);
    [Pr_10m, ~] = free_space_path_loss(0, 3e9, 10);
    assert(abs(Pr_1m - (-42)) < tol, ...
        'FAIL: free_space_path_loss at 1m expected ~-42dBm, got %.2f', Pr_1m);
    assert(abs(Pr_10m - (-62)) < tol, ...
        'FAIL: free_space_path_loss at 10m expected ~-62dBm, got %.2f', Pr_10m);
    fprintf('  [PASS] free_space_path_loss matches slide example (-42dBm@1m, -62dBm@10m)\n');

    % --- Log-distance model: free-space exponent (n=2) should match
    % Friis exactly (both are the same physical law) ---
    d0 = 1; PL_d0 = -Pr_1m; % path loss at 1m from the Friis computation
    PL_10 = log_distance_path_loss(10, d0, 2, PL_d0);
    expected_PL_10 = -Pr_10m;
    assert(abs(PL_10 - expected_PL_10) < 1e-6, ...
        'FAIL: log-distance model with n=2 should reduce to free-space law');
    fprintf('  [PASS] log_distance_path_loss(n=2) matches free-space law exactly\n');

    % --- 10*n dB/decade slope check for an arbitrary exponent ---
    n = 3.5;
    PL_1  = log_distance_path_loss(1, 1, n, 0);
    PL_10 = log_distance_path_loss(10, 1, n, 0);
    assert(abs((PL_10 - PL_1) - 10*n) < 1e-9, ...
        'FAIL: path loss should increase by exactly 10*n dB per decade');
    fprintf('  [PASS] log_distance_path_loss slope = 10*n dB/decade (n=%.1f)\n', n);

    fprintf('test_path_loss: ALL TESTS PASSED\n');
end
