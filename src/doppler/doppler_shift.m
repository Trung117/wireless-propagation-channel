function fD = doppler_shift(v_mps, fc_Hz)
% DOPPLER_SHIFT  Single Doppler shift for a mobile moving at constant
% velocity relative to the source, as derived in "Doppler shift":
%
%       fD = -fc*v/c = -v/lambda
%
%   Sign convention (as stated on the slide):
%       v > 0 (moving away from base)   -> fD < 0
%       v < 0 (moving towards base)     -> fD > 0
%   This function returns the MAGNITUDE, |fD| = v/lambda, since most
%   downstream quantities (Doppler spread, coherence time) only depend on
%   |fD|.
%
%   INPUTS
%       v_mps  - relative velocity magnitude [m/s]
%       fc_Hz  - carrier frequency [Hz]
%
%   OUTPUT
%       fD     - Doppler shift magnitude [Hz]
%
%   VALIDATION (matches slide "Fading channel example"):
%       doppler_shift(25, 2.1e9) -> ~175 Hz

    c = 3e8;
    lambda = c / fc_Hz;
    fD = abs(v_mps) / lambda;
end
