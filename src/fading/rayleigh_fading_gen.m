function [alpha, h_complex] = rayleigh_fading_gen(N)
% RAYLEIGH_FADING_GEN  Generate N i.i.d. Rayleigh-distributed channel
% amplitude samples with E{alpha^2} = 1, matching the normalization used
% in the "BER on flat Rayleigh fading channel" slides.
%
% A Rayleigh amplitude is obtained as the magnitude of a complex Gaussian
% random variable h = hI + j*hQ with hI, hQ ~ N(0, 1/2):
%
%       alpha = |h|,   E{alpha^2} = E{hI^2} + E{hQ^2} = 1
%
%   INPUT
%       N          - number of channel samples to generate
%
%   OUTPUTS
%       alpha       - 1xN Rayleigh-distributed amplitude samples
%       h_complex   - 1xN complex Gaussian channel taps (h = alpha*exp(j*phase))

    hI = sqrt(0.5) * randn(1, N);
    hQ = sqrt(0.5) * randn(1, N);
    h_complex = hI + 1j*hQ;
    alpha = abs(h_complex);
end
