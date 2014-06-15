function out = morletConjFT(w,omega0)
%morletConjFT is used by fastWavelet_morlet_convolution_parallel to find
%the Morlet wavelet transform resulting from a time series

    out = pi^(-1/4).*exp(-.5.*(w-omega0).^2);