function Tc = coherence_time(fD)
% COHERENCE_TIME  Channel coherence time from the Doppler shift, as in
% "Channel's coherence time":
%
%       Tc = 1 / (2*fD)
%
%   Derived from the fact that the autocorrelation rho(t) = J0(2*pi*fD*t)
%   (0th-order Bessel function of the first kind) first crosses zero near
%   fD*t = 1/2.
%
%   If Tc > T (symbol period)  -> SLOW fading (channel ~ constant over a
%                                  symbol -> negligible Doppler distortion)
%   If Tc < T                  -> FAST fading (channel varies within a
%                                  symbol -> synchronization/BER problems)
%
%   INPUT
%       fD - Doppler shift / spread [Hz]
%
%   OUTPUT
%       Tc - coherence time [s]
%
%   VALIDATION (matches slide "Fading channel example"):
%       coherence_time(175) -> ~2.857 ms (slide rounds to "~3 ms")

    Tc = 1 ./ (2*fD);
end
