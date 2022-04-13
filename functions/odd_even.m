function spe_out = odd_even(spe_in)
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
%
% OUTPUT:
%	- spe_out: spectra corrected for the odd-even effect affecting all JIRAM spectra.
% ===============================

wvl = dlmread('JIRAM_WVL_00.txt');         % JIRAM bands  
% attenzione al path di dlmread, potrebbe non trovare il file da leggere. 
% Per ovviare a questa cosa puoi usare i path assoluti, che puoi includere in ogni funzione oppure aggiungere un argomento opzionale che e' il percorso radice.
% cerco di scrivere un esempio qui
%
% function spe_out = odd_even(spe_in, path)
%
% if nargin < 2  %nargin e' "number of argument input", cioe' il numero di argomenti di input della funzione
% 	rootpath = '/home/chiara/documents/matlab/';
% else
%	rootpath = path;
% end

oe = 1:1:size(wvl); 
% se non specifichi l'incremento, matlab assume 1, quindi puoi scrivere oe = 1:size(wvl). Questo vale anche per i cicli for.
% occhio che size(wvl) in generale non e' uno scalare, e infatti in questo caso e' un array 336x1. Se non ha errori o problemi penso sia un caso,
% e' probabile che prenda come ultimo valore di oe il primo elemento di size(wvl). Alternative a questo hai
% - size(wvl,1)
% - length(wvl), che e' uguale a max(size(wvl)), quindi ti da la massima dimensione di wvl.
% - numel(wvl) che e' il numero di elementi di wvl.
% In alcuni casi sono equivalenti alcune di queste scritture, ma non sempre.

par = oe(mod(oe,2)~=1);                    % even spectral points
dis = oe(mod(oe,2)~=0);                    % odd spectral points

sp_dim = size(spe_in,1);	                 % spatial dimension
wl_dim = size(spe_in,2);	                 % spectral dimension

spe_out = nan(size(spe_in));

for i = 1:1:sp_dim
    if isnan(spe_in(i,:))
    	% ATTENZIONE! isnan(spe_in(i,:)) e' un'array di lunghezza wl_dim, e non e' ovvio come if interpreti un array.
	% Facendo un paio di esperimenti mi pare che interpreti isnan(spe_in(i,:)) = 1 solo se tutti gli elementi dell'array sono nan, altrimenti = 0.
	% In caso, per rendere piu' sicuro il tutto puoi usare le funzioni "any" e "all" a seconda di cosa vuoi.
	   disp('Skip')	          
	   continue
    end
    sp = spe_in(i,:)).';
    spd = spline(wvl(dis), sp(dis), wvl);  % spline interpolation of the even spectral points
    spp = spline(wvl(par), sp(par), wvl);  % spline interpolation of the odd spectral points
    sp = 0.5*(spd+spp);                    % mean of the even and odd spectra
    spe_out(i,:) = sp;
end   



