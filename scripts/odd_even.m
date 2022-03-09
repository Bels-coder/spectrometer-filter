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


wave = ;                               % ADD WAVELENGTHS from file 'JIRAM_WVL_00.txt'
oe = double(wvl);
par = rem(oe, 2) == 0;
dis = rem(oe, 2) == 1;
spectrum = double(256,336) ;           % SELECT THE SLIT

for i = 0,size(spectrum(256,:)) 

 sp = (spectrum(i,:));
 spp = spline(sp(par), wave(par), wave);
 spd = spline(sp(dis), wave(dis), wave);
 sp = 0.5*(spd+spp);
 spectrum(i, :) = sp;
 
end


