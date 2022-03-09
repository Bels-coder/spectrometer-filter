function [lat,lon,phase,solar,em,r,x,y,z, name, kernel]=georeferenzia(M,i,kernel,flag,height,body,delay)
% [lat,lon,phase,solar,em,r,x,y,z, name]=georeferenzia(M,i,kernel,flag,height)
% flag=0,6 standard,
% =1 buono per il nord
% =2 buono per il sud
% =3 buono sempre
% =4 ufficiale F.Tosi,
% negativi = forza al ricalcolo
% =5 forza ad avere il nadir offset comandat
% =7 digital model of JUPITER
% =10 prova prima Tosi altrimente =3
% 666 = cancella la cache


% se si pone mk=NaN non carica l'mk e lascia quello precedente in memoria
% (va quindi caricato prima)
if isfield(M,'RT')
else
	M=datart(M,kernel);
	pause(0)
	warning('datart va chiamato prima altrimenti si spreca un sacco di tempo')
end


if ischar(kernel)
	mkread(kernel);
	iker=true;
else
	iker=false;
end


if nargin<=5
	body='Jupiter';
end
if nargin==4
	height=0;
	
end


if ~exist('delay','var')
	delay=0;
end


if strcmpi(delay,'auto')
	delay=autooffset(M);
end



TRUETIME=M.RT+delay;


%addpath('/doc/progetti/juno/044.spice/matlab')
C=pwd;
if nargin==3
	flag =0;
end


if abs(flag)==10
	try
		[lat,lon,phase,solar,em,r,x,y,z, name]=georeferenzia(M,i,kernel,sign(flag)*4,height,body);
	catch
		[lat,lon,phase,solar,em,r,x,y,z, name]=georeferenzia(M,i,kernel,sign(flag)*3,height,body);
	end
	if iker
		cspice_kclear
	end
	return
end




stepk=mod(abs(flag),1)*10;

stepk=round(stepk);
if stepk==0
	stepk=2;
end


if flag<0
	flag=-flag;
	force=false;
else
	force=true;
end

if strcmp(M.CHANNEL{i},'Image IR')
	
	
	switch M.mode_id{i}
		
		case {'SCI_I1_S1' 'SCI_I1_S0'}
			load VEC_I.mat
			NY=266;
			NX=432;
			frame='JUNO_JIRAM_I';
		case {'SCI_I2_S1' 'SCI_I2_S0'}
			load VEC_M.mat
			NY=128;
			NX=432;
			
			frame='JUNO_JIRAM_I_MBAND';
		case {'SCI_I3_S1' 'SCI_I3_S0'}
			load VEC_L.mat
			NY=128;
			NX=432;
			frame='JUNO_JIRAM_I_LBAND';
	end
	
	
elseif strcmp(M.CHANNEL{i},'Spectrum IR')
	load VEC_S.mat
	NY=1;
	NX=256;
	frame='JUNO_JIRAM_S';
else
	error('qui')
end






nam=strrep(M.File_Name_b{i},'.mat','.geo.mat');
nam=strrep(nam,'/Volumes/ftp','~/temporanea');
namh=strrep(M.File_Name_b{i},'.mat',[num2str(height) 'km.geo.mat']);
namh=strrep(namh,'/Volumes/ftp','~/temporanea');





if flag==666
	try
		delete (namh)
		disp('deleted geo-h file')
	end
	try
		delete (nam)
		disp('deleted geo file')
		
	end
	if iker
		cspice_kclear
	end
	return
	
elseif exist(namh,'file') & force & height>0
	
	
	
	load(namh);
	
	name=namh;
	%      disp('georeferenzia & correggi: cache')
	
	if iker
		cspice_kclear
	end
	return
	
elseif exist(nam,'file') & force & height ==0
	load(nam);
	
	name=nam;
	%      disp('georeferenzia: cache')
	
	if iker
		cspice_kclear
	end
	return
	
	
elseif exist(nam,'file') & force & height >0
	load(nam);
	
	
	%      disp('georeferenzia: cache. correggi: elaborazione')
	
	% elseif (flag==4) & height >0 NON SERVE
	%
	%
	%
	%      disp('georeferenzia: F. Tosi. correggi: elaborazione')
	% 	 addpath ('/doc/progetti/juno/070.geometria')
	% 	 [lat,lon,phase,solar,em,r,x,y,z]=geometrie(M,i);
	
	
	
else
	disp('georeferenzia: elaborazione')
	
	if abs(flag)~=4
		%         [fo,fi,ex]=fileparts(kernel);
		%         cd(fo);
		%         cspice_furnsh([fi ex]);
		%         cd (C);
		
	end
	
	
	
	
	
	switch flag
		
		case {0,6}
			% caso ideale, valorizza tutti
			
			[flag,lon,lat,phase,solar,em,r,x,y,z]=interseca(vec, TRUETIME(i), body, 'Juno', ['IAU_' upper(body)], frame);
			lat=reshape(lat,NY,NX);
			lon=reshape(lon,NY,NX);
			x=reshape(x,NY,NX);
			y=reshape(y,NY,NX);
			z=reshape(z,NY,NX);
			em=reshape(em,NY,NX);
			phase=reshape(phase,NY,NX);
			solar=reshape(solar,NY,NX);
			r=reshape(r,NY,NX);
			
		case {7}
			% caso digitale
			
			[flag,lon,lat,phase,solar,em,r,x,y,z]=interseca(vec, TRUETIME(i), body, 'Juno', ['IAU_' upper(body)], frame,'DSK/UNPRIORITIZED');
			lat=reshape(lat,NY,NX);
			lon=reshape(lon,NY,NX);
			x=reshape(x,NY,NX);
			y=reshape(y,NY,NX);
			z=reshape(z,NY,NX);
			em=reshape(em,NY,NX);
			phase=reshape(phase,NY,NX);
			solar=reshape(solar,NY,NX);
			r=reshape(r,NY,NX);
			
			
			
		case 1
			% caso 1:4:end, con singolarita' al polo sud (buono per nord ed
			% equatore
			
			
			
			KI=[(1:2:NY-1) NY];
			KJ=[(1:2:NX-1) NX];
			
			HI=(1:NY);
			HJ=(1:NX);
			
			
			[flag,lon,lat,phase,solar,em,r]=interseca(vec(:,KI,KJ), TRUETIME(i), body, 'Juno', ['IAU_' upper(body)], frame);
			
			lat=reshape(lat,numel(KI),numel(KJ));
			lon=reshape(lon,numel(KI),numel(KJ));
			em=reshape(em,numel(KI),numel(KJ));
			solar=reshape(solar,numel(KI),numel(KJ));
			phase=reshape(phase,numel(KI),numel(KJ));
			r=reshape(r,numel(KI),numel(KJ));
			
			x=(90-lat).*cosd(lon);
			y=(90-lat).*sind(lon);
			
			em=interp2(KJ,KI',em,HJ,HI');
			solar=interp2(KJ,KI',solar,HJ,HI');
			phase=interp2(KJ,KI',phase,HJ,HI');
			r=interp2(KJ,KI',r,HJ,HI');
			
			xx=interp2(KJ,KI',x,HJ,HI');
			yy=interp2(KJ,KI',y,HJ,HI');
			
			lon=atan2(yy,xx)*180/pi;
			lat=interp2(KJ,KI',lat,HJ,HI');
			
			x=r.*cosd(lat).*cosd(lon);
			y=r.*cosd(lat).*sind(lon);
			z=r.*sind(lat);
			
			
			warning('sarebbe meglio non usarlo piu''')
			
		case 2
			% caso 1:2:end, con singolarita' al polo nord (buono per sud ed
			% equatore
			
			
			
			KI=[(1:2:NY-1) NY];
			KJ=[(1:2:NX-1) NX];
			
			HI=(1:NY);
			HJ=(1:NX);
			
			
			[flag,lon,lat,phase,solar,em,r]=interseca(vec(:,KI,KJ), TRUETIME(i), body, 'Juno', ['IAU_' upper(body)], frame);
			
			lat=reshape(lat,numel(KI),numel(KJ));
			lon=reshape(lon,numel(KI),numel(KJ));
			em=reshape(em,numel(KI),numel(KJ));
			solar=reshape(solar,numel(KI),numel(KJ));
			phase=reshape(phase,numel(KI),numel(KJ));
			r=reshape(r,numel(KI),numel(KJ));
			
			
			x=(90+lat).*cosd(lon);
			y=(90+lat).*sind(lon);
			
			em=interp2(KJ,KI',em,HJ,HI');
			solar=interp2(KJ,KI',solar,HJ,HI');
			phase=interp2(KJ,KI',phase,HJ,HI');
			r=interp2(KJ,KI',r,HJ,HI');
			
			xx=interp2(KJ,KI',x,HJ,HI');
			yy=interp2(KJ,KI',y,HJ,HI');
			
			lon=atan2(yy,xx)*180/pi;
			lat=interp2(KJ,KI',lat,HJ,HI');
			
			
			
			x=r.*cosd(lat).*cosd(lon);
			y=r.*cosd(lat).*sind(lon);
			z=r.*sind(lat);
			
			warning('sarebbe meglio non usarlo piu''')
		case {3 3.2 3.4 3.8}
			% interpola su x y z
			
			
			
			KI=[(1:stepk:NY-1) NY];
			KJ=[(1:stepk:NX-1) NX];
			
			HI=(1:NY);
			HJ=(1:NX);
			
			
			[flag,lon,lat,phase,solar,em,r,x,y,z]=interseca(vec(:,KI,KJ), TRUETIME(i), body, 'Juno', ['IAU_' upper(body)], frame);
			
			x=reshape(x,numel(KI),numel(KJ));
			y=reshape(y,numel(KI),numel(KJ));
			z=reshape(z,numel(KI),numel(KJ));
			r=reshape(r,numel(KI),numel(KJ));
			lat=reshape(lat,numel(KI),numel(KJ));
			
			em=reshape(em,numel(KI),numel(KJ));
			solar=reshape(solar,numel(KI),numel(KJ));
			phase=reshape(phase,numel(KI),numel(KJ));
			
			
			
			
			em=interp2(KJ,KI',em,HJ,HI');
			solar=interp2(KJ,KI',solar,HJ,HI');
			phase=interp2(KJ,KI',phase,HJ,HI');
			r=interp2(KJ,KI',r,HJ,HI');
			
			x=interp2(KJ,KI',x,HJ,HI');
			y=interp2(KJ,KI',y,HJ,HI');
			z=interp2(KJ,KI',z,HJ,HI');
			
			lon=atan2(y,x)*180/pi;
			lat=interp2(KJ,KI',lat,HJ,HI');
			
			
		case 4 % TOSI
			
			
			%                disp('georeferenzia: F. Tosi. correggi: n/a')
			addpath ('/doc/progetti/juno/070.geometria')
			[lat,lon,phase,solar,em,r,x,y,z,name]=geometrie(M,i);
			
		otherwise
			
			
			error('non trovato')
			
			% TOSI ERA INF PRIMA
	end
	if ~isdir(fileparts(nam))
		mkdir(fileparts(nam))
	end
	save(nam,'lat','lon','em','solar','phase','r','x','y','z','kernel');
	
end





if height>0
	name=namh;
	%     [fo,fi,ex]=fileparts(kernel);
	%     cd(fo);
	%     cspice_furnsh([fi ex]);
	%     cd (C);
	
	try
		load nam
	catch
		
		JU=cspice_spkpos('Juno',TRUETIME(i),'IAU_JUPITER','CN+S','Jupiter');
		
		%           hh=height./cosd(em);
		%           e' un problema di triangoli, in cui abbiamo due lati (r , r+h) e l'angolo di
		%           emissione (per cui l'angolo interno al triangolo e' 180-em
		%         teorema dei seni:
		sin_r=r.*sind(180-em)./(r+height);
		% trovo l'ultimo angolo
		%           beta=180-(180-em)-asind(sin_r);
		beta=em-asind(sin_r);
		%           terzo=sqrt(r.^2+(r+height).^2-2*r*(r+height).*cosd(beta));
		hh=sqrt(height^2+2*(r.^2+r*height).*(1-cosd(beta)));
		
		
		% i vecchi file non avevano xyx
		
		if ~exist('x','var')
			x=r.*cosd(lat).*cosd(lon);
			y=r.*cosd(lat).*sind(lon);
			z=r.*sind(lat);
		end
		
		
		dd=sqrt((x-JU(1)).^2+(y-JU(2)).^2+(z-JU(3)).^2);
		
		p=hh./dd;
		
		x=x.*(1-p)+JU(1)*p;
		y=y.*(1-p)+JU(2)*p;
		z=z.*(1-p)+JU(3)*p;
		
		r=sqrt(x.^2+y.^2+z.^2);
		lat=asin(z./r)*180/pi;
		lon=atan2(y,x)*180/pi;
		
		
		save(namh,'lat','lon','em','solar','phase','r','x','y','z','kernel');
	end
	
else
	name=nam;
end


if iker
	cspice_kclear
end


