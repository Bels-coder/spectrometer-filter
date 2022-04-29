% MAIN SCRIPT
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This script is the 'main' caller, which contains the call to each step of the filter.
% The program must filter a single sequence of a chosen orbit at a time.
%
% The steps that has to be taken are the following:
% STEP 1:  UPLOAD DATA
% STEP 2:  ODD-EVEN CORRECTION
% STEP 3:  NEGATIVE VALUE REMOVAL
% STEP 4a: SPIKE REMOVAL
% STEP 4b: FROM COUNTS TO POWER 
% STEP 5:  RMS FILTER
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear classes; clear functions; dbclear all; clear all;

% Step 1: upload data
rootfolder = '/Users/Utente/Desktop/noise/spectrometer-filter-Data-upload/';
addpath([rootfolder,'functions']);
addpath([rootfolder,'data']);
addpath([rootfolder,'commanding']);
run('data_upload.m');

% Step 2: odd-even correction 
nslit = str2double(input(sprintf('Select the number of the slit from 1 to %s:\n',num2str(numel(M.data))),'s'));
jirfolder= fullfile(rootfolder,'data'); 
[sp_odev,wvl] = odd_even(M.data{nslit},jirfolder);

% Step 3: negative value removal
sp_pstv = rm_negative(sp_odev);

% Step 4a: spike removal
ron = 0.5e-7*2e6;  % readout noise in count
thrsld = 5.6;      % threshold for spike detection
sp_despk = spikeFilter(sp_pstv,ron,thrsld);

% Step 4b: from counts to power
sp = sp_despk/2e6;

% Step 5: RMS filter
%[signal,h3_bands,h3_spe,m_h3_spe,rms,rms_h3_spe,FRMS,DRMS,DSCALE,RES,FINAL] = rmsFilter(sp_despk);
[signal,h3_bands,h3_spe,m_h3_spe,rms,rms_h3_spe,sp_dim,wl_dim,FRMS,DRMS,DSCALE,RES] = rmsFilter(sp);

ORBIT=repmat(strcat('JM0',(num2str(orbnum,'%03.f'))),[sp_dim,1]);
CUBE = repmat(M.Name_cube{nM}(1:25),[sp_dim,1]);
FILE = repmat(M.File_Name_b{nM}(strfind(M.File_Name_b{nM},'JIR-'):133),[sp_dim,1]);
LINDEX = iL.*ones(sp_dim,1);
MINDEX = nM.*ones(sp_dim,1);
NCHAN = wl_dim.*ones(sp_dim,1);

FINAL = table(ORBIT,CUBE,FILE,LINDEX,MINDEX,NCHAN,FRMS,DRMS,DSCALE,RES);

