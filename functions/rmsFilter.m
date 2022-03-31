function [signal,h3_bands,h3_spe,m_h3_spe,rms,rms_h3_spe,FRMS,DRMS,DSCALE,RES,FINAL] = rmsFilter(spe_in)
% ===============================
% This function filters the spectra based on the comparison between the
% value of the RMS computed both for the original spectrum and the same
% spectrum set to zero everywhere except in correspondence of the H3+ bands. 
%
% The spectra should be corrected for the odd-even effect before run this
% funtion, to enance the fainter signals. For this purpose use the
% 'odd_even.m' function.
%
% The removal of the most evident spikes before the filtering process,
% reduces the probability of erroneus results. For this purpose use the
% 'spikeFilter.m' function.
% 
% SYNTAX :
%	- [signal,h3_bands,h3_spe,m_h3_spe,rms,rms_h3_spe,FRMS,DRMS,DSCALE,RES,FINAL] = rms_filtering(spe_in)
%
% FUNCTIONS :
%   - This funtion runs 'frms.m' and 'trms.m' functions.
%
% INPUT :
%	- spe_in: input spectra. This must be a matrix [NxM] containing all the spectra from a
%	single slit, where N is the spatial dimension (usually N=256) and M the spectral
%	dimension (M=336). The input spectra must be in counts. IMPORTANT: Negative values in
%	the matrix might lead to incorrect results.
%
% OUTPUT:
%	- signal: original spectra.
%   - h3_bands: signals in the H3+ bands.
%   - h3_spe: originil spectra set to zero everywhere except in the H3+ bands. 
%   - m_h3_spe = mean signal of 'h3_spe'
%   - rms = root-mean-square of the original signal.
%   - rms_h3_spe = root-mean-square of the signal in the H3+ bands.
%   - FRMS = ratio between the rms of the original spectrum and that
%   computed for the H3+ bands 
%   - DRMS = difference between the rms of the original spectrum and that
%   computed for the H3+ bands.
%   - DSCALE = product between DRMS and FRMS.
%   - RES = result of the filtering process : Reject or Save the spectrum.
%   - FINAL = summary table of the values used to estimate the quality of
%   the observation.
% ===============================

idx = [147,154,158,162,171,186];            % index of the H3+ bands 

sp_dim = size(spe_in,1);	                % spatial dimension
wl_dim = size(spe_in,2);	                % spectral dimension

signal= zeros(size(spe_in));
h3_bands= zeros(size(spe_in,1),6);
h3_spe = zeros(size(spe_in));
m_h3_spe = zeros(size(spe_in,1),1);

rms = zeros(size(spe_in,1),1);
rms_h3_spe = zeros(size(spe_in,1),1);

FRMS = zeros(size(spe_in,1),1); 
DRMS = zeros(size(spe_in,1),1);
DSCALE = zeros(size(spe_in,1),1);
RES = string(zeros(size(spe_in,1),1));


for i = 1:1:sp_dim
    
    signal(i,:)= spe_in(i,:);                     
    h3_bands(i,:) = signal(i,idx);                
    h3_spe(i,idx) = h3_bands(i,:);
    m_h3_spe(i) = mean(h3_spe(i,:));

    rms = frms(signal(i,:));                                               
    rms_h3_spe = frms(h3_spe(i,:));               

    
    % Thresholds
    FRMS(i) = (rms_h3_spe(i)/rms(i));
    DRMS(i) = rms(i)-rms_h3_spe(i);
    DSCALE(i) = DRMS(i)*FRMS(i);

    if FRMS(i) < 1E-2 || DSCALE(i) > 5.0E-6 || m_h3_spe(i) < 0              
        RES(i) = 'Reject';                                                                                               
    else                                                                   
        RES(i) = 'Save';
    end
   
end

FINAL = table(FRMS, DRMS, DSCALE, RES);
% FINAL = table(filename, FRMS, DRMS, DSCALE, RES);   % ADD THE INFORMATION ABOUT FILENAME


