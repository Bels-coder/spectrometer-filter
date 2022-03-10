% The script applies the odd-even correction to the spectra

wvl = dlmread('JIRAM_WVL_00.txt');                               
oe = 1:1:size(wvl); 
par = oe(mod(oe,2)~=1);
dis = oe(mod(oe,2)~=0);

% Sample file
filename = 'JM0071_limbs_00193.txt'; 
file = fopen(filename);
spectrum = textscan(file,'%f %f %f','HeaderLines',21);
spectrum = cell2mat(spectrum);
fclose(file);
signal = spectrum(:,2);                                                   
%

sp = signal.';
spd = spline(wvl(dis), sp(dis), wvl);
spp = spline(wvl(par), sp(par),  wvl);
sp = 0.5*(spd+spp);
signal_corrected = sp;



