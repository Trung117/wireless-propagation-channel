function [h_t, H_f, t_axis, f_axis] = multipath_channel_response(alpha, tau, T, Nt, Nf)
% MULTIPATH_CHANNEL_RESPONSE  Build impulse & frequency response of an
% L-path multipath channel, as in "Multipath channel in frequency":
%
%       h(t) = sum_l alpha_l * exp(j*phi_l) * delta(t - tau_l)
%       H(f) = sum_l alpha_l * exp(j*phi_l) * exp(-j*2*pi*f*tau_l)
%
%   This function reproduces the slide's "Two-path channel" example
%   h(t) = delta(t) + 0.9*delta(t-tau) when called with
%   alpha = [1 0.9], tau = [0 tau_value].
%
%   Path phases are taken as phi_l = 0 for all l (as in the slide's
%   two-ray worked examples, which only show magnitude/real taps).
%
%   INPUTS
%       alpha - vector of path gains [a0, a1, ..., a_{L-1}]
%       tau   - vector of path delays [tau0, tau1, ...] (same units as T)
%       T     - symbol period, used only to build the normalized time axis
%       Nt    - number of points for the plotted impulse-response time axis
%       Nf    - number of points for the normalized-frequency axis (over
%               fT in [-0.5, 0.5], matching the slide's plots)
%
%   OUTPUTS
%       h_t     - impulse response sampled on t_axis (delta modeled as
%                 stem values, for plotting only)
%       H_f     - complex channel frequency response sampled on f_axis
%                 (fT normalized frequency)
%       t_axis  - normalized time axis, t/T in [0, 5] (as in slide plots)
%       f_axis  - normalized frequency axis, fT in [-0.5, 0.5]

    if nargin < 4, Nt = 500; end
    if nargin < 5, Nf = 1000; end

    alpha = alpha(:)';
    tau   = tau(:)';
    L = numel(alpha);

    % --- Impulse response (for stem plotting) ---
    t_axis = linspace(0, 5*T, Nt);
    h_t = zeros(1, Nt);
    for l = 1:L
        [~, idx] = min(abs(t_axis - tau(l)));
        h_t(idx) = h_t(idx) + alpha(l);
    end

    % --- Frequency response: H(f) = sum_l alpha_l * exp(-j*2*pi*f*tau_l) ---
    fT = linspace(-0.5, 0.5, Nf);   % normalized frequency f*T
    f_axis = fT;
    H_f = zeros(1, Nf);
    for l = 1:L
        H_f = H_f + alpha(l) * exp(-1j*2*pi*fT*(tau(l)/T));
    end
end
