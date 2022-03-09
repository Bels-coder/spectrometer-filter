function datecal = et2utc(J2000,mk)
% ===============================
%This function converts seconds past J2000 to utc calendar date using cspice_et2utc
%
% SYNTAX :
%	datecal = et2utc(J2000,mk)
%
% INPUT :
%	J2000: time array in second past J2000
%	mk: SPICE metakernel
%
% OUTPUT:
%	datecal: calendar date string corresponding to input time
% ===============================

cspice_kclear;
cspice_furnsh({mk});

datecal = cspice_et2utc(J2000,'C',0);

cspice_kclear;
