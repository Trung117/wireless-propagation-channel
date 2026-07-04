function S = jakes_doppler_spectrum(f, fD)
% JAKES_DOPPLER_SPECTRUM  Jakes' (classical) Doppler power spectral
% density, from "Time varying channel as a stochastic process":
%
%       S_D(f) = 1 / (pi*fD*sqrt(1 - (f/fD)^2)),   |f| < fD
%              = 0,                                 |f| >= fD
%
%   This is the PSD seen under uniform scattering (2D isotropic
%   scattering, all arrival angles equally likely) -- the classic
%   "bathtub"-shaped spectrum.
%
%   INPUTS
%       f  - frequency vector [Hz] at which to evaluate the PSD
%       fD - maximum Doppler shift [Hz]
%
%   OUTPUT
%       S  - Jakes PSD values, same size as f (0 outside |f|<fD, and the
%            (integrable) singularities at f = +-fD are clipped for
%            numerical plotting)

    S = zeros(size(f));
    inside = abs(f) < fD;
    S(inside) = 1 ./ (pi * fD * sqrt(1 - (f(inside)/fD).^2));
end
