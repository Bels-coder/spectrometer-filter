function spe_out = spikeFilter(spe_in,RO,thrs)
% ===============================
%This function remove the spikes from the spectra of a single slit of the JIRAM 
%spectrometer. 
%The algorithm is adapted from Takeuchi et al., 1993 (DOI:10.1366/0003702934048578)
%
% SYNTAX :
%	- spe_out = spikeFilter(spe_in,RO,thrs)
%
% INPUT :
%	- spe_in: input spectra. This must be a matrix [NxM] containing all the spectra from a
%	single slit, where N is the spatial dimension (usually N=256) and M the spectral
%	dimension (M=336). The input spectra must be in counts. IMPORTANT: Negative values in
%	the matrix might lead to incorrect results.
%	- RO: readout noise in count (scalar integer);
%	- thrs: threshold for spike detection. This value multiplies the root-mean-square noise 
%	of each wavelength (Ni). The default value is 5.6*Ni, which means that 95% of the noise 
%	other than spike is expected to have peak-to-peak amplitude under the threshold. Other 
%	useful values are 7.3 (99%) and 4.7 (90%). See Takeuchi et al., 1993 for additional details.
%
% OUTPUT:
%	- spe_out: spectra without spikes.
% ===============================

if nargin < 2
	error('Not enough inputs. At least input spectra and readout noise must be provided.')
end
if nargin < 3
	disp('Default threshold for spike detection was assumed.')
	thrs = 5.6;
end

Ti = sum(spe_in,2,'omitnan');	% total power in each spectrum
sp_dim = size(spe_in,1);	%spatial dimension
wl_dim = size(spe_in,2);	%spectral dimension

spe_out = nan(size(spe_in));
for i = 1:sp_dim-1
	for j = 1:wl_dim
		if isnan(spe_in(i,j))
			disp('Skip')	%This disp is just for debugging purpose.
			continue
		end
		I1 = spe_in(i,j);
		I2 = spe_in(i+1,j)*Ti(i)/Ti(i+1);	%the ratio between the total powers re-scale the two spectra to make them comparable.
		Si = min([I1 I2]);	
		Ni = sqrt(Si+RO^2);	%root-mean-square noise
		if abs(I1-I2) > thrs*Ni	
			spe_out(i,j) = min([I1 I2]);	%if the difference is above the root-mean-square noise (i.e: a spike is detected), replace the j-th band in the i-th spectrum with the minimum between the i-th and i+1-th spectrum in the same band.
		else
			spe_out(i,j) = I1;	%if a spike is not detected, leave the j-th band as it is.
		end
	end
end
spe_out(sp_dim,:) = spe_in(sp_dim,:);
