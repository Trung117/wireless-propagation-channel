function test_doppler()
% TEST_DOPPLER  Validates Doppler shift, coherence time, and Jakes'
% spectrum against the slide's "Fading channel example" worked numbers.

    addpath('../src/doppler');
    tol = 1.0; % Hz tolerance

    % --- Doppler shift: fc=2.1GHz, v=90km/h=25m/s -> fD ~= 175 Hz ---
    v = 90/3.6;
    fD = doppler_shift(v, 2.1e9);
    assert(abs(fD - 175) < tol, 'FAIL: doppler_shift expected ~175Hz, got %.2f', fD);
    fprintf('  [PASS] doppler_shift(25 m/s, 2.1 GHz) = %.2f Hz (slide: ~175 Hz)\n', fD);

    % --- Coherence time: Tc = 1/(2*fD) ~= 2.857 ms for fD=175Hz ---
    Tc = coherence_time(175);
    assert(abs(Tc - 2.857e-3) < 1e-4, 'FAIL: coherence_time(175) expected ~2.857ms, got %.4fms', Tc*1e3);
    fprintf('  [PASS] coherence_time(175 Hz) = %.3f ms (slide: ~3 ms)\n', Tc*1e3);

    % --- Jakes spectrum: must be symmetric, and diverge (be very large)
    % near f = +-fD, while being 0 outside [-fD, fD] ---
    fD_test = 100;
    f = linspace(-150, 150, 3001);
    S = jakes_doppler_spectrum(f, fD_test);
    assert(all(S(abs(f) > fD_test) == 0), 'FAIL: Jakes spectrum should be 0 for |f| > fD');
    assert(max(S) > 10*S(f==0 | abs(f)<1), 'FAIL: Jakes spectrum should peak near f=+-fD (bathtub shape)');
    % symmetry check
    S_pos = jakes_doppler_spectrum(50, fD_test);
    S_neg = jakes_doppler_spectrum(-50, fD_test);
    assert(abs(S_pos - S_neg) < 1e-9, 'FAIL: Jakes spectrum should be symmetric in f');
    fprintf('  [PASS] jakes_doppler_spectrum: zero outside [-fD,fD], symmetric, bathtub-shaped\n');

    fprintf('test_doppler: ALL TESTS PASSED\n');
end
