function Pe = ber_rayleigh_flat(snr_bar_linear)
% BER_RAYLEIGH_FLAT  Analytical average BER of 2-PAM/BPSK over a flat
% Rayleigh-fading channel, derived in "2-PAM BER on a flat fading
% channel" by averaging the conditional AWGN error probability over the
% Rayleigh pdf of the channel amplitude:
%
%       Pe = Integral_0^inf  Q(alpha*sqrt(2*SNR)) * p(alpha) d(alpha)
%          = 0.5 * ( 1 - sqrt( SNR_bar / (1 + SNR_bar) ) )
%
%   where SNR_bar = Eb/N0 is the AVERAGE per-bit SNR (i.e. E{alpha^2}*Eb/N0
%   with E{alpha^2} = 1).
%
%   For large SNR_bar, this slide shows the well-known 1/SNR floor:
%
%       Pe ~= 1 / (4*SNR_bar)     (compare to AWGN's exponential decay!)
%
%   This is the key qualitative result of the whole deck: fading turns an
%   exponentially-decaying AWGN error curve into one that only decays as
%   1/SNR -- i.e. you pay a huge SNR penalty just from multipath fading,
%   before even considering ISI.
%
%   INPUT
%       snr_bar_linear - average SNR (Eb/N0), LINEAR scale
%
%   OUTPUT
%       Pe             - average bit-error probability

    Pe = 0.5 * (1 - sqrt(snr_bar_linear ./ (1 + snr_bar_linear)));
end
