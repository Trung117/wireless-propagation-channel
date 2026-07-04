function Bc = coherence_bandwidth(sigma_tau)
% COHERENCE_BANDWIDTH  Channel coherence bandwidth from RMS delay spread.
%
%   Bc = coherence_bandwidth(sigma_tau)
%
%   From the "Coherence bandwidth" slide:
%
%       Bc ~= 1 / (5*sigma_tau)
%
%   If sigma_tau << T (symbol period)  -> Bc > Bs -> channel is FLAT.
%   If sigma_tau >  T                  -> Bc < Bs -> channel is
%                                          FREQUENCY-SELECTIVE (multipath).
%
%   INPUT
%       sigma_tau - RMS delay spread [s]
%
%   OUTPUT
%       Bc        - coherence bandwidth [Hz]
%
%   VALIDATION (matches slide "Typical values of RMS delay spread"):
%       coherence_bandwidth(5e-6) -> 40 kHz   (LTE ETU worst case)

    Bc = 1 ./ (5 * sigma_tau);
end
