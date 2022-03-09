function M=myjiramdati(header,M,n)
ORIG=M;

if isnumeric(M)
	error('Non e'' una stringa')
end
M=strrep(M,'/Volumes/ftp/','~/temporanea/');

remote=false;

if ischar(M)
	
	
	
	k=strfind(M,'/PROCESSED_DATA');
	if isempty(k)
		% li tratto come dati fisici e basta
		cached=false;
	else
		originale=fileparts(M(1:k(1)-1));
		comune=strrep(M,originale,'');
		attuale= '/Users/Utente/Desktop/noise/matlab/Aurorae_INAF/jiramdati_saves/JIRAM_ARCHIVE';	%cambiare con folder dove vanno salvati i dati
		%attuale='~/temporanea/JIRAM_ARCHIVE';
		reale=[attuale comune '.mat'];
		reale2=[attuale comune(1:end-4) '.mat'];
		cached=true;
	end
	
	
	
	if cached && exist(reale,'file')      % prova a caricarlo da cache
		%         disp('JIRAMDATI: carico da cache')
		load(reale)
		
		if header
			M.data=[];
		end
		M.file_=reale;
		
		for h=1:numel(M.ET)
			M.orig{h}=ORIG;
		end
		
		for h=1:numel(M.SCI_SCET)
			M.NN(h)=h;
		end
		return
		
		
		
	elseif cached && exist(reale2,'file')      % prova a caricarlo da cache
		%         disp('JIRAMDATI: carico da cache, vecchio nome')
		load(reale2)
		if header
			M.data=[];
		end
		M.file_=reale2;
		
		for h=1:numel(M.ET)
			M.orig{h}=ORIG;
		end
		return
		
		
		
		
	elseif cached && exist(M,'file')  	% prova a vedere se esiste in locale
		
		
		%         disp('JIRAMDATI: esiste in locale')
		
		
	elseif cached
		[~,output0]=system('ifconfig en0 | grep status');
		[~,output1]=system('ifconfig en1 | grep status');
		[~,output5]=system('ifconfig en5 | grep status');
		if any(strfind(output0,'inactive')) && any(strfind(output1,'inactive')) && any(strfind(output5,'inactive'))
			error('rete non disponibile: controlla che tutte le interfacce siano contemplate')
		end
		while (1)
			
			
			try
				% 			  cason=randi(6);
				cason=1;
				
				switch cason
					case 1
						warning('ftp 1: montaggio')
						[remote,M,originale]=ftp1(comune);
						if remote
							break
						end
					case 2
						warning('ftp 5: montaggio con rsync')
						[remote,M,originale]=ftp5(comune);
						if remote
							break
						end
						
					case 3
						warning('ftp 3: scrive su /tmp') % mount ftp remoto
						
						[remote,M,originale]=ftp3(comune);
						if remote
							break
						end
						
						
					case 4
						warning('ftp 4: scrive su /tmp') % scarico diretto
						[remote,M,originale]=ftp4(comune, header);
						if remote
							break
						end
						
					case 5
						warning('ftp 2: montaggio su NAS')
						[remote,M,originale]=ftp2(comune);
						if remote
							break
						end
						
					case 6
						warning('ftp 6: wget / ftp')
						[remote,M,originale]=ftp6(comune);
						if remote
							break
						end
				end
				
			end
		end
	else
		disp('JIRAMDATI: non trovo il file')
		disp(M)
		error('JIRAMDATI: non trovo il file')
		
	end
	
	
	
	
	
	N=strrep(M,'\','');
	ijk=0;
	while(1)
		ijk=ijk+1;
		try
			M=readstatus(N);
			break
		catch
			
			disp('riprovo')
			system('umount /Volumes/ftp');
			system('umount -f /Volumes/ftp');
			pause(1)
			system('mkdir /Volumes/ftp');
			system('mount_ftp junoadm:Jun0Adm.14@ftp.sic.rm.cnr.it /Volumes/ftp');
			
		end
		if ijk>5
			error('inutile riprovare ancora')
		end
	end
	% else
	%
	% end
	
	%----------------------------------------------\
	% PER TRASFORMARE I CARATTERI IN NUMERI USARE ||
	% str2double([M.SCI_NADIR_OFFSET]) PER ESEMPIO||
	%----------------------------------------------/
	
	
	tic;
	
	if nargin==2
		I=fieldnames(M);
		m2=numel(M.(I{2}));
		m1=1;
		empty=false;
	elseif nargin==3
		
		
		
		if islogical(n)
			empty=~n;
			I=fieldnames(M);
			m2=numel(M.(I{2}));
			m1=1;
		else
			
			I=fieldnames(M);
			empty=false;
			m1=n;
			m2=n;
		end
		
		
		
		
	end
	
	SUB=fileparts(M.file);
	FOL=fileparts(SUB);
	
	if isdir([FOL filesep 'DATA_EDR_MATRIX'])
		predict='DATA_EDR_MATRIX';
	elseif isdir([FOL filesep 'DATA_MATR'])
		predict='DATA_MATR';
	elseif isdir([FOL filesep 'DATI_MATR'])
		predict='DATI_MATR';
	else
		error('non trovata')
	end
	
	for i=m1:m2
		
		if (toc)>5
			disp([num2str(round(i/(m2-m1)*100)) '%'])
			tic;
		end
		
		JUL=datenum(M.GeometryEpoch{i},'yyyy-mm-dd')-datenum(M.GeometryEpoch{1},'yyyy')+1;
		YEA=M.GeometryEpoch{i}(1:4);
		TIM=M.GeometryEpoch{i}(12:19);
		TIM=strrep(TIM,':','');
		switch M.CHANNEL{i};
			case 'Spectrum IR'
				FIL=[FOL filesep predict filesep 'JIR-SPE-EDR-' YEA  num2str(JUL,'%3.3i') 'T' TIM '-V01.mat'];
				% 				FIL=[FOL filesep predict filesep 'JIR-SPE-EDR-' YEA  num2str(JUL-1,'%3.3i') 'T' TIM '-V01.mat'];
			otherwise
				FIL=[FOL filesep predict filesep 'JIR-IMG-EDR-' YEA  num2str(JUL,'%3.3i') 'T' TIM '-V01.mat'];
				%                     FIL=[FOL filesep predict filesep 'JIR-IMG-EDR-' YEA  num2str(JUL-1,'%3.3i') 'T' TIM '-V01.mat'];
		end
		
		
		if ~empty && ~header
			
			try
				tmp=load(FIL);
				M.data{i,1}=tmp.DATA;
				if cached
					M.File_Name_b{i}=strrep(FIL,originale,attuale);
				end
			catch
				
				error('Impossibile leggere il file')
				M.data{i,1}=[];
				M.File_Name_b{i}='Error';
			end
			
		end
	end
	kf=true;
	
	for h=1:numel(M.SCI_SCET)
		M.ET(h)=str2num(M.SCI_SCET{h});
		M.AN(h)=segno(M.NADIR_OFFSET_SIGN{h}) *str2num(M.SCI_NADIR_OFFSET{h})*0.003139005632771;
		M.NN(h)=h;
		
		%         try
		% 	  M.RT(h)=cspice_scs2e(-61999,M.SCLK_SCI{h});
		%         catch
		% 	  if (kf)
		% 	      warning('SPICE KERNELS NOT AVAILABLE TO RECONSTRUCT M.RT')
		% 	      kf=false;
		% 	  end
		%         end
		% E' PERICOLOSO FARLO QUI
		
	end
	
	
	
	if cached
		buf=strrep(fileparts(reale),'IMG_EDR_INDEX','DATA_EDR_MATRIX');
		buf=strrep(buf,'SPE_EDR_INDEX','DATA_EDR_MATRIX');
		if ~exist(buf,'dir')
			%             mkdir(fileparts(reale));
			
			
			mkdir(buf)
			disp('creata directory per geo')
		end
		
		M.file=strrep(M.file,originale,attuale);
		mkdir(fileparts(reale))
		if ~header
			save(reale,'M')
		end
		M.file_=reale;
	end
	
	
	%     if remote
	%         system('umount -f /Volumes/ftp')
	%
	%     end
	
end


for h=1:numel(M.ET)
	M.orig{h}=ORIG;
end

function s=segno(v)
switch(v)
	case('1')
		s=-1;
	case('0')
		s=1;
end
