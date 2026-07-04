function [h_t, t_axis] = jakes_fading_timeseries(fD, fs, N)
% JAKES_FADING_TIMESERIES  Generate a time-varying flat Rayleigh fading
% channel h(t) whose power spectral density matches the Jakes' Doppler
% spectrum, using the classical "filtered white noise" method:
%
%   1) Generate complex white Gaussian noise W[f] in the frequency domain.
%   2) Shape it by sqrt(S_D(f)) (the Jakes PSD from jakes_doppler_spectrum.m).
%   3) Inverse-FFT back to the time domain to obtain correlated,
%      Rayleigh-distributed fading samples h(t) with the desired Doppler
%      spread fD.
%
%   This numerically reproduces the theoretical result stated in
%   "Time varying channel as a stochastic process":
%
%       rho(t) = J0(2*pi*fD*t)  <=>  S_D(f)
%
%   i.e. the autocorrelation of |h(t)| (or of h(t) itself, for the
%   complex Gaussian case) is the 0th-order Bessel function of the first
%   kind. See scripts/run_doppler_spectrum_demo.m, which verifies this by
%   comparing the empirical autocorrelation of a generated realization to
%   J0(2*pi*fD*t).
%
%   INPUTS
%       fD - Doppler shift / spread [Hz]
%       fs - sampling frequency [Hz]  (must satisfy fs > 2*fD, i.e.
%            fs is the rate at which channel snapshots are taken)
%       N  - number of time-domain samples to generate
%
%   OUTPUTS
%       h_t     - 1xN complex fading process, E{|h_t|^2} = 1
%       t_axis  - 1xN time axis [s]

    if fs <= 2*fD
        warning('jakes_fading_timeseries:aliasing', ...
            'fs (%g Hz) should be > 2*fD (%g Hz) to avoid aliasing the Doppler spectrum.', fs, 2*fD);
    end

    f_axis = (-N/2:N/2-1) * (fs/N);       % frequency bins for the FFT
    S = jakes_doppler_spectrum(f_axis, fD);

    % Avoid the (integrable) singularities at f = +-fD when N is small
    S(~isfinite(S)) = 0;

    % Complex white Gaussian noise, shaped by sqrt(PSD)
    W = (randn(1, N) + 1j*randn(1, N)) / sqrt(2);
    Hshaped = W .* sqrt(S);

    h_t = ifft(ifftshift(Hshaped)) * N;   % scale so time-domain power ~ sum(S)

    % Normalize so that E{|h_t|^2} = 1 (unit average channel power)
    h_t = h_t / sqrt(mean(abs(h_t).^2));

    t_axis = (0:N-1) / fs;
end
