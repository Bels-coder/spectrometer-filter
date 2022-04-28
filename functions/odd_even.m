function [spe_out,wvl] = odd_even(spe_in,path)
% ===============================
% The funtion applies the odd-even correction to the spectra.
%
% SYNTAX :
%	- spe_out = odd_even(spe_in)
%
% INPUT :
%	- spe_in: input spectra. This must be a matrix [NxM] containing all the spectra from a
%	single slit, where N is the spatial dimension (usually N=256) and M the spectral
%	dimension (M=336).
%       - path: path of the file 'JIRAM_WVL_00.txt' listing JIRAM
%
% OUTPUT:
%	- spe_out: spectra corrected for the odd-even effect affecting all JIRAM spectra.
% ===============================

if nargin < 2 
	rootpath = '../data/';
else
	rootpath = path;
end

wvl = dlmread(fullfile(rootpath,'JIRAM_WVL_00.txt'));   % JIRAM bands 

oe = 1:length(wvl); 
par = oe(mod(oe,2)~=1);                                 % even spectral points
dis = oe(mod(oe,2)~=0);                                 % odd spectral points

sp_dim = size(spe_in,1);	                        % spatial dimension
wl_dim = size(spe_in,2);	                        % spectral dimension

spe_out = nan(size(spe_in));

for i = 1:sp_dim
    if all(isnan(spe_in(i,:)))
	   disp('Skip')	          
	   continue
    end
    sp = spe_in(i,:)).';
    spd = spline(wvl(dis), sp(dis), wvl);  % spline interpolation of the even spectral points
    spp = spline(wvl(par), sp(par), wvl);  % spline interpolation of the odd spectral points
    sp = 0.5*(spd+spp);                    % mean of the even and odd spectra
    spe_out(i,:) = sp;
end   



