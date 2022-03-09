% The script applies the odd-even correction to the spectra

%% IDL code
  % oe = findgen(n_elements(wave))
  % par= where(oe mod 2 eq 0, complement= dis )
  % spet = speto*0

  % for i = 0,dim1-1 do begin
  %  for j = 0,dim2-1 do begin

  %  sp = reform(speto(i,j,*))
  %  spp = 0
  %  spd = 0
  
  %  spp = interpol( sp(par), wave(par), wave, /spline)
  %  spd = interpol( sp(dis), wave(dis), wave, /spline)
  %  sp = 0.5*(spd+spp)
  %  spet(i, j, *) = sp

  %  endfor
  % endfor

%%

wvl = dlmread('JIRAM_WVL_00.txt');                               % UPLOAD 'JIRAM_WVL_00.txt' FILE
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



