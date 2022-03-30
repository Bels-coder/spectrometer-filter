function [ rms ] = frms( S )
% ===============================
% FRMS uses Parseval's theorem to calculate the RMS of a signal 
% by examining the frequency domain of the signal.
%
% SYNTAX :
%	- [rms] = frms(S)
%
% INPUT :
%	- S: is the signal in the frequency domain (i.e. fft(s(t))). 
%
% OUTPUT:
%	- rms: root-mean-square value of the signal.
% ===============================
    
    rms = sqrt(sum((abs(S)/length(S)).^2));

end
