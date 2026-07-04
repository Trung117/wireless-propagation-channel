function As_dB = lognormal_shadowing(sigma_dB, N)
% LOGNORMAL_SHADOWING  Generate log-normal shadowing samples.
%
%   As_dB = lognormal_shadowing(sigma_dB, N)
%
%   From "Large-scale fading: shadowing": shadowing accounts for random
%   variations of the average channel attenuation around the
%   deterministic path-loss curve. It is modeled, in dB, as a zero-mean
%   Gaussian random variable:
%
%       As ~ N(0, sigma_dB^2)   with pdf
%       p(As) = 1/sqrt(2*pi*sigma_dB^2) * exp(-As^2 / (2*sigma_dB^2))
%
%   Typical sigma_dB values quoted on the slide: 0-9 dB.
%
%   INPUTS
%       sigma_dB - shadowing standard deviation in dB (0-9 dB typical)
%       N        - number of samples to generate (default 1)
%
%   OUTPUT
%       As_dB    - N shadowing samples in dB, to be ADDED to the
%                  deterministic path loss: PL_total = PL + As (in dB)

    if nargin < 2, N = 1; end
    As_dB = sigma_dB * randn(1, N);
end
