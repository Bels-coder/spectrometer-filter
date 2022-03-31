function spe_out= rm_negative(spe_in)
% ===============================
% This function removes negative values in the spectra
% SYNTAX :
%	- spe_out= rm_negative(spe_in)
%
% INPUT :
%	- spe_in: input spectra. This must be a matrix [NxM] containing all the spectra from a
%	single slit, where N is the spatial dimension (usually N=256) and M the spectral
%	dimension (M=336). 
%
% OUTPUT:
%	- spe_out: spectra where negative values have been set to NaN.
% ===============================

spe_in(spe_in<0) = nan;
spe_out = spe_in;

end