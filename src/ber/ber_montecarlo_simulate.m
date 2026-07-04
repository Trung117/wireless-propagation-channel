function Pe_hat = ber_montecarlo_simulate(snr_linear, Nbits, channel_type)
% BER_MONTECARLO_SIMULATE  Bit-level Monte Carlo BER simulation of
% BPSK/2-PAM transmission, used to empirically validate the closed-form
% expressions in ber_awgn_2pam.m and ber_rayleigh_flat.m.
%
% Implements exactly the decision-variable models from the slides:
%
%   AWGN channel     ("Flat fading channel: BER on AWGN"):
%       x(m) = c_m + n(m)
%
%   Flat Rayleigh fading channel ("BER on flat Rayleigh fading channel"):
%       x(m) = alpha*c_m + n(m),   alpha ~ Rayleigh, E{alpha^2}=1
%
%   Detection rule: bit = 1 if Re{x} > 0, else bit = 0 (matched-filter /
%   coherent detection, since alpha is assumed known at the receiver --
%   equivalent to perfect channel estimation).
%
%   INPUTS
%       snr_linear   - Eb/N0, linear scale (scalar)
%       Nbits        - number of bits to simulate (e.g. 1e6)
%       channel_type - 'awgn' or 'rayleigh'
%
%   OUTPUT
%       Pe_hat       - empirical bit-error rate

    if nargin < 3, channel_type = 'awgn'; end

    % Random equiprobable bits mapped to 2-PAM symbols {-1, +1}
    bits = randi([0 1], 1, Nbits);
    c = 2*bits - 1;              % BPSK symbols, unit energy Ec = 1

    % Noise power for the target Eb/N0 (Ec = 1 => N0 = 1/snr_linear)
    N0 = 1 / snr_linear;
    n = sqrt(N0/2) * randn(1, Nbits);   % real AWGN, matches slide's x(m)=c_m+n(m)

    switch lower(channel_type)
        case 'awgn'
            x = c + n;
        case 'rayleigh'
            alpha = rayleigh_fading_gen_local(Nbits);   % E{alpha^2}=1
            x = alpha .* c + n;
        otherwise
            error('Unknown channel_type: use ''awgn'' or ''rayleigh''');
    end

    bits_hat = (x > 0);
    Pe_hat = mean(bits_hat ~= bits);
end

function alpha = rayleigh_fading_gen_local(N)
    hI = sqrt(0.5) * randn(1, N);
    hQ = sqrt(0.5) * randn(1, N);
    alpha = abs(hI + 1j*hQ);
end
