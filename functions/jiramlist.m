function varargout=jiramlist(fil,myseqid,tmpx,dwld,ins,backflag,mk)
% jiramlist(fil,myseqid,tmpx,dwld,ins,backflag,mk)

fil=strrep(fil,'\','');
if nargin==2
    tmpx='';
    dwld=false;
    ins='';
    backflag=1;
    mk=false;
end

if nargin==3
    ins='';
    dwld=false;
    backflag=1;
    mk=false;
end

if nargin==4
    ins='';
    backflag=1;
    mk=false;
end

if nargin==5
    backflag=1;
    mk=false;
end

if nargin==6
    mk=false;
end

switch lower(ins)
    case ''
        skip='none';
    case {'i','img','imager'}
        skip='SPE';
    case {'s','spe','spectrometer'}
        skip='IMG';
    otherwise
        error('qui')
end


backupfile=[fil '.' myseqid '.' tmpx  '.' ins '.mat'];
backupfile=['/Users/Utente/Desktop/noise/matlab/Aurorae_INAF/jiramlist_saves/',backupfile]; %CAMBIARE
if exist(backupfile,'file') && (backflag==1)
    load(backupfile);
    
    for i=1:numel(OUT.file)
        
        OUT.string{i}=['''' OUT.file{i} ''' ' num2str(OUT.OFF{i}) ' ' num2str(OUT.OFFDE{i})  ' % ' num2str(OUT.NNN{i}) ' ' OUT.OBJ{i} ' '  OUT.mode_id{i}];
        if nargout==0
            disp(OUT.string{i})
        end
        
        
    end
    if nargout==1
        varargout{1}=OUT;
    end
    
    return
end


kk=0;

h=fopen(fil);
if h>0
    while ~feof(h)
        bf=fgetl(h) ;
        if numel(bf)>13
            switch bf(1:13)
                case {'SeqId        ','SeqName      ','SeqNote      ','SeqDuration  '}
                    eval ([bf(1:15) '''' bf(16:end) ''';'])
                case 'SeqStartTime '
                    SeqStartTime=bf(16:end);
                    Time=datenum(SeqStartTime,'yyyy-mm-ddTHH:MM:SS');
                case 'SeqEndTime   '
                    SeqEndTime=bf(16:end);
                    ETime=datenum(SeqEndTime,'yyyy-mm-ddTHH:MM:SS');
                case '             '
                    if (bf(18)==':' & bf(21)==':')
                        
                        ci=datevec(bf(16:23),'HH:MM:SS');
                        ci(1:3)=0;
                        Time=Time+datenum(ci);
                        switch bf(25:35)
                            
                            case 'JRM_SCI_PAR'
                                tmp=strrep(bf(37:end-1),'"','''');
                                tmp=strrep(tmp,'deg,',',');
                                tmp=strrep(tmp,'ms,',',');
                                eval(['[SUB_MODE,SP_ACQ_N,SP_ACQ_REPETITION,SP_BKG_REPETITION,SP_EN_DIS_COMP,SP_SCI_LINK,SP_EN_DIS_SUB,SP_BKG_RN,SP_EN_DIS_DOUC_SCI,SP_ACQ_DURATION,SP_NADIR_DELTA,SP_I_EXP_1,SP_S_EXP_1,SP_I_GAIN_1,SP_S_GAIN_1,SP_M_MODE_1,SP_NADIR_OFFSET_1,SP_I_EXP_2,SP_S_EXP_2,SP_I_GAIN_2,SP_S_GAIN_2,SP_M_MODE_2,SP_NADIR_OFFSET_2,SP_SUMMED_SCIENCE]=deal(' tmp ');'])
                            case 'JRM_SCIENCE'
                                kk=kk+1;
                                ST1{kk}=SeqStartTime;
                                ST2{kk}=SeqEndTime;
                                T1(kk)=Time;
                                T2(kk)=ETime;
                                NN(kk)=SP_ACQ_N;
                                OBJ{kk}=SeqNote;
                                OFF{kk}=SP_NADIR_OFFSET_2;
                                OFFDE{kk}=SP_NADIR_DELTA;
                                if kk>1
                                    DELTAT(kk)=T1(kk)*86400-T1(kk-1)*86400-30*(NN(kk-1)-1);
                                else
                                    DELTAT(1)=0;
                                end
                                disp([SeqId ' ' datestr(Time,'yyyy/mm/dd HH:MM:SS') ' ' datestr(ETime,'yyyy/mm/dd HH:MM:SS') ' ' num2str(SP_ACQ_N) ' ' num2str(DELTAT(kk)) ' ' SeqNote ])
                                
                                %
                                
                        end
                    end
                otherwise
                    
            end
        end
    end
    fclose(h);
else
    T1=[];
    T2=[];
    NN=[];
end

if backflag==2
    L.ST1=ST1;
    L.ST2=ST2;
    L.T1=T1;
    L.T2=T2;
    L.NN=NN;
    L.DELTAT=DELTAT;
    L.OFF=OFF;
    L.OFFDE=OFFDE;
    varargout{1}=L;
    return
end
disp('PARTE SERVER')
%

system('mkdir /home/bels/ftp'); %CAMBIARE (mount point)
system('curlftpfs junoadm:Jun0Adm.14@ftp.sic.rm.cnr.it /home/bels/ftp'); %comando per montare ftp
a=dir(['/home/bels/ftp/JIRAM_ARCHIVE/' myseqid '/PROCESSED_DATA/PDS_EDR' tmpx '/*_JUNO_*']); %cambiare mount point

disp(['TROVATI ' num2str(numel(a)) ' FILE SUL SERVER'])


if isempty(a)
    varargout{1}=[];
    
    % ===========================================
    % INSERT FTP STRING HERE 
    % ===========================================
    return
end
ii=0;



orb=str2double(myseqid(3:5));
ful=[];
try
    [sho,ful]=search('/doc/progetti/jiram/Science operations and planning/Planning/Sommario',['*ORBIT' num2str(orb) '*(merged).jir']);
    if isempty(ful)
        [sho,ful]=search('/doc/progetti/jiram/Science operations and planning/SASF',['*ORBIT' num2str(orb) '*(merged).jir']);
    end
end
if ~isempty(ful)
    load(ful{1},'-mat');
else
    B.t=[];
    B.i=[];
end


for i=1:numel(a)
    disp(a(i).name)
    if strfind(a(i).name,'IMG')
        typ='IMG';
    elseif strfind(a(i).name,'SPE')
        typ='SPE';
    else
        %         disp(a(i).name)
        continue
    end
    if strcmp(typ,skip)
        continue
    end
    ii=ii+1;
    
    file= ['/home/bels/ftp/JIRAM_ARCHIVE/' myseqid '/PROCESSED_DATA/PDS_EDR'  tmpx '/' a(i).name '/' typ '_EDR_INDEX/JIRAM_STATUS_' typ '.txt']  ; %CAMBIARE mount point
    while(1)
        try
            
            M=readstatus(file);
            break
        catch
            disp('riprovo')
            system('sudo umount /home/bels/ftp');
            system('mkdir /home/bels/ftp');
            system('curlftpfs junoadm:Jun0Adm.14@ftp.sic.rm.cnr.it /home/bels/ftp');
            
        end
    end
    clear('ETS');
    for ih=1:numel(M.SCI_SCET)
        ETS(ih)=str2num(M.SCI_SCET{ih});
    end
    
    
    tcand=B.t(B.i);
    ish=mysegments(tcand,60);
    isht=ish(1:end-1)+1;
    ishf=ish(2:end);
    [laps,icand]=min(abs(ETS(1)-tcand(isht)));
    if laps<60
        ncand=ishf(icand)-isht(icand)+1;
        nactu=numel(ETS);
        if nactu==ncand
            MYDELAY{ii}=ETS-tcand(isht(icand):ishf(icand));
            %             keyboard
        else
            MYDELAY{ii}=[];
        end
    else
        MYDELAY{ii}=[];
    end
    TT1=datenum(M.SCI_GeometryEpoch{1},'YYYY-mm-ddTHH:MM:SS');
    TT2=datenum(M.SCI_GeometryEpoch{end},'YYYY-mm-ddTHH:MM:SS');
    NNN=numel(M.et);
    
    if1=(round(T1*24*60)==round(TT1*24*60)) | (round(T1*24*60)==round(TT1*24*60)+1) | (round(T1*24*60)==round(TT1*24*60)-1);
    if2=(round(T2*24*60)==round(TT2*24*60)) | (round(T2*24*60)==round(TT2*24*60)-1) | (round(T2*24*60)==round(TT2*24*60)+1) | (round(T2*24*60)==round(TT2*24*60)+2);
    ifn=(NN==NNN) | (NN==(NNN+1));
    ifi=if1 & if2 & ifn;
    if any(ifi)
        MYOBJ{ii}=OBJ{ifi};
        MYOFF{ii}=OFF{ifi};
        MYOFFDE{ii}=OFFDE{ifi};
        MYSTART{ii}=ST1{ifi};
        
    else
        MYOBJ{ii}='Unknown';
        MYOFF{ii}=NaN;
        MYOFFDE{ii}=NaN;
        MYSTART{ii}='Unknown';
        if NNN>9 & any (NN)
            warning('Questo dovrebbe essere riconosciuto')
        end
    end
    
    OUT.string{ii}=['''' file ''' ' num2str(MYOFF{ii}) ' ' num2str(MYOFFDE{ii})  ' % ' num2str(NNN) ' ' MYOBJ{ii} ' '  M.mode_id{1}];
    if nargout==0
        disp(OUT.string{ii})
    end
    OUT.file{ii}=file;
    OUT.NNN{ii}=NNN;
    OUT.mode_id{ii}=M.mode_id{1};
    if dwld
        jiramdati(file);
    end
    if mk
        %         jiramnadirck(file,mk) <---     finire qui sopra
        
        
    end
end




OUT.OFF=MYOFF;
OUT.OFFDE=MYOFFDE;
OUT.OBJ=MYOBJ;
OUT.START=MYSTART;
OUT.DELAY=MYDELAY;
save(backupfile,'OUT')
if nargout==1
    varargout{1}=OUT;
end
system('umount /home/bels/ftp') 	%cambiare anche questo?





function i=mysegments(var,delta)

if isempty(var)
    i=[];
    return
end

dx=abs(diff(var(:)));
i=find(dx>delta);
i=[0
    i
    numel(dx)+1];
