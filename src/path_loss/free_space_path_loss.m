function [Pr_dBm, PL_dB] = free_space_path_loss(Pt_dBm, freq_Hz, d_m, Gt, Gr)
% FREE_SPACE_PATH_LOSS  Friis free-space propagation model.
%
%   [Pr_dBm, PL_dB] = free_space_path_loss(Pt_dBm, freq_Hz, d_m, Gt, Gr)
%
%   Implements the physics described in the "Physics of wireless signal
%   propagation" slide:
%
%       Pr = Pt * A / (4*pi*d^2),   A = (1/pi)*(lambda/2)^2
%
%   which is algebraically equivalent to the classic Friis equation
%
%       Pr = Pt * Gt * Gr * (lambda / (4*pi*d))^2
%
%   INPUTS
%       Pt_dBm   - transmit power in dBm
%       freq_Hz  - carrier frequency in Hz
%       d_m      - Tx-Rx separation distance in meters (scalar or vector)
%       Gt, Gr   - (optional) linear Tx/Rx antenna gains, default = 1 (isotropic)
%
%   OUTPUTS
%       Pr_dBm   - received power in dBm (same size as d_m)
%       PL_dB    - path loss in dB, PL = Pt_dBm - Pr_dBm
%
%   EXAMPLE (reproduces the slide's worked example at 3 GHz):
%       [Pr, PL] = free_space_path_loss(0, 3e9, [1 10]);
%       % Pr ~= [-42, -62] dBm  -> matches "0.006% at 1m (-42dB)" etc.

    if nargin < 4, Gt = 1; end
    if nargin < 5, Gr = 1; end

    c = 3e8;                       % speed of light [m/s]
    lambda = c / freq_Hz;          % wavelength [m]

    % Free-space path loss (Friis), in linear scale:
    % Pr/Pt = Gt*Gr*(lambda/(4*pi*d))^2
    ratio = Gt .* Gr .* (lambda ./ (4*pi*d_m)).^2;

    PL_dB  = -10*log10(ratio);     % path loss (positive, in dB)
    Pr_dBm = Pt_dBm - PL_dB;       % received power in dBm
end
