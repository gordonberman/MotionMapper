function out = gaussianfilterdata(data,sigma)
%convolves a data set with a gaussian of width 'sigma'

    L = length(data);
    xx = (1:L) - round(L/2);
    if iscolumn(data)
        xx = xx';
    end
    
    g = exp(-.5.*xx.^2./sigma^2)/sqrt(2*pi*sigma^2);
    out = fftshift(ifft(fft(data).*fft(g)));