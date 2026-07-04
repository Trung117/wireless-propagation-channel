function [tau_bar, tau_rms, p] = delay_spread(alpha, tau)
% DELAY_SPREAD  Mean excess delay and RMS delay spread of a multipath
% channel, as defined in "Channel's delay spread":
%
%       p_l      = alpha_l^2 / sum(alpha_l^2)      (empirical mass prob.)
%       tau_bar  = sum(p_l * tau_l)                 (mean excess delay)
%       tau2_bar = sum(p_l * tau_l^2)
%       tau_rms  = sqrt(tau2_bar - tau_bar^2)        (RMS delay spread)
%
%   INPUTS
%       alpha - vector of path gains
%       tau   - vector of path delays (same units, e.g. seconds or
%               multiples of symbol period T)
%
%   OUTPUTS
%       tau_bar - mean excess delay
%       tau_rms - RMS delay spread (sigma_tau in the slides)
%       p       - normalized power weights p_l (sum(p) = 1)
%
%   VALIDATION (matches slide "Two-path channel" worked examples):
%       delay_spread([1 0.9], [0 0.1])  -> tau_bar ~= 0.045, tau_rms ~= 0.05
%       delay_spread([1 0.9], [0 1])    -> tau_bar ~= 0.45,  tau_rms ~= 0.5
%       delay_spread([1 0.9], [0 1.5])  -> tau_bar ~= 0.7,   tau_rms ~= 0.6
%       delay_spread([1 0.9], [0 4])    -> tau_bar ~= 1.8,   tau_rms ~= 2.3
%   (values are in units of T, since the slide normalizes tau by T)

    alpha = alpha(:)';
    tau   = tau(:)';

    p = (alpha.^2) / sum(alpha.^2);

    tau_bar  = sum(p .* tau);
    tau2_bar = sum(p .* tau.^2);
    tau_rms  = sqrt(tau2_bar - tau_bar^2);
end
