function p = rayleigh_pdf(alpha, sigma2)
% RAYLEIGH_PDF  Probability density function of a Rayleigh-distributed
% channel amplitude, as defined in "Channel gain characterization":
%
%       p(alpha) = (alpha/sigma^2) * exp(-alpha^2 / (2*sigma^2)),  alpha >= 0
%
%   With the normalization used throughout the small-scale fading slides
%   (E{alpha^2} = 1, i.e. sigma^2 = 1/2), this reduces to
%
%       p(alpha) = 2*alpha*exp(-alpha^2)
%
%   INPUTS
%       alpha  - vector of amplitude values (>= 0)
%       sigma2 - variance parameter sigma^2 (default 0.5, i.e. E{alpha^2}=1)
%
%   OUTPUT
%       p      - pdf values, same size as alpha

    if nargin < 2, sigma2 = 0.5; end
    p = zeros(size(alpha));
    idx = alpha >= 0;
    p(idx) = (alpha(idx) ./ sigma2) .* exp(-alpha(idx).^2 ./ (2*sigma2));
end
