function Pe = ber_awgn_2pam(snr_linear)
% BER_AWGN_2PAM  Analytical bit-error rate of 2-PAM/BPSK over an AWGN
% (no-fading) channel, as in "Flat fading channel: BER on AWGN":
%
%       Pe = Q( sqrt(2*SNR) ) = 0.5*erfc( sqrt(SNR) )
%
%   INPUT
%       snr_linear - E/N0 (or Eb/N0) in LINEAR scale (not dB)
%
%   OUTPUT
%       Pe         - bit-error probability

    Pe = 0.5 * erfc(sqrt(snr_linear));
end
