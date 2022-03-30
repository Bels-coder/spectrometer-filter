function x = trms(a)
% ===============================
% Return the root mean square of all the elements of *s*, flattened out.
%
% SYNTAX :
%	- time_rms = trms(s)
%
% INPUT :
%	- s: is the signal in the time domain.
%
% OUTPUT:
%	- time_rms: root-mean-square value of the signal.
% ===============================
 
   time_rms = sqrt(mean(abs(s).^2));
   
end
