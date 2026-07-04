function PL_dB = log_distance_path_loss(d_m, d0_m, n, PL_d0_dB)
% LOG_DISTANCE_PATH_LOSS  General log-distance path-loss model.
%
%   PL_dB = log_distance_path_loss(d_m, d0_m, n, PL_d0_dB)
%
%   Implements the large-scale path-loss law from the "Large-scale
%   fading: path-loss" slide:
%
%       PL(d) = PL(d0) + 10*n*log10(d/d0)
%
%   where n is the path-loss exponent (2 for free space, up to 6 for
%   obstructed indoor environments, see table below).
%
%   INPUTS
%       d_m       - distance(s) at which to evaluate path loss [m]
%       d0_m      - reference distance [m] (typically 1 m indoor, 100 m
%                   or 1 km outdoor)
%       n         - path-loss exponent (see reference table)
%       PL_d0_dB  - path loss at the reference distance d0 [dB]
%
%   OUTPUT
%       PL_dB     - path loss in dB at distance(s) d_m
%
%   REFERENCE TABLE (from slide "Large-scale fading: path-loss"):
%       Environment                     n
%       ---------------------------------------
%       Free space                      2
%       Urban area cellular radio       2.7 - 3.5
%       Urban area cellular (obstructed)3 - 5
%       In-building line-of-sight       1.6 - 1.8
%       Obstructed in-building          4 - 6
%       Obstructed in factories         2 - 3

    PL_dB = PL_d0_dB + 10 * n .* log10(d_m ./ d0_m);
end
