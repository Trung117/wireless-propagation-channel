function Pe_hat = ber_isi_montecarlo(snr_linear, Nbits, path_gains_var)
% BER_ISI_MONTECARLO  Bit-level BER simulation over a frequency-selective
% (multipath) Rayleigh fading channel WITHOUT equalization, reproducing
% "BER on multipath Rayleigh fading channel":
%
%       x(m) = g(0)*c_m + sum_{k != 0} g(k*T)*c_{m-k} + n(m)
%                          \_____________________/
%                                    ISI
%
%   Each tap g(k) is an independent Rayleigh fading coefficient. With no
%   countermeasures (no equalizer), the ISI term causes an IRREDUCIBLE
%   ERROR FLOOR: Pe stops decreasing even as SNR -> infinity, exactly as
%   plotted in the slide's "Typical BER vs S/N curves".
%
%   INPUTS
%       snr_linear     - Eb/N0, linear scale
%       Nbits          - number of bits to simulate
%       path_gains_var - vector of relative average powers for each tap,
%                        e.g. [1 0.81] mimics the slide's two-ray
%                        h(t) = delta(t) + 0.9*delta(t-tau) (0.9^2=0.81)
%
%   OUTPUT
%       Pe_hat         - empirical bit-error rate (will floor at high SNR)

    if nargin < 3, path_gains_var = [1 0.81]; end

    L = numel(path_gains_var);
    bits = randi([0 1], 1, Nbits + L - 1);
    c = 2*bits - 1;

    N0 = 1 / snr_linear;
    n = sqrt(N0/2) * randn(1, Nbits);

    x = zeros(1, Nbits);
    for k = 1:L
        g_var = path_gains_var(k);
        hI = sqrt(g_var/2) * randn(1, Nbits);
        hQ = sqrt(g_var/2) * randn(1, Nbits);
        g_k = abs(hI + 1j*hQ);          % Rayleigh tap, average power = g_var
        x = x + g_k .* c(k:Nbits+k-1);  % c_{m-(k-1)} aligned so k=1 -> current symbol
    end
    x = x + n;

    bits_hat = (x > 0);
    Pe_hat = mean(bits_hat ~= bits(L:L+Nbits-1));
end
