% RUN_ALL_TESTS  Master test runner for the wireless-propagation-channel
% project. Runs every test_*.m file in this directory and reports a
% summary. Exits with a non-zero status if any test fails (useful for
% CI / GitHub Actions).
%
% Run with (from the tests/ folder):
%   octave --eval "run_all_tests"
% or from MATLAB:
%   run_all_tests

fprintf('=========================================\n');
fprintf(' Running full test suite\n');
fprintf('=========================================\n\n');

test_files = {'test_path_loss', 'test_multipath', 'test_ber', 'test_doppler'};
n_pass = 0;
n_fail = 0;

for i = 1:numel(test_files)
    fname = test_files{i};
    fprintf('--- %s ---\n', fname);
    try
        feval(fname);
        n_pass = n_pass + 1;
    catch err
        fprintf(2, '  [FAILED] %s\n', err.message);
        n_fail = n_fail + 1;
    end
    fprintf('\n');
end

fprintf('=========================================\n');
fprintf(' SUMMARY: %d/%d test files passed\n', n_pass, n_pass + n_fail);
fprintf('=========================================\n');

if n_fail > 0
    error('%d test file(s) failed.', n_fail);
end
