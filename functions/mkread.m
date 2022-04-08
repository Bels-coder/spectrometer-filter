function mkread(mk)

% mk is the path (string) of the metakernel file. 
% Example: mk = '/home/user/doc/mkfolder/recon.96.mk'; mkread(mk);

cspice_furnsh(mk)
%{
[d,f,e]=fileparts(mk);
% C=pwd;
% cd (d)

 
fid=fopen(mk,'rt');
mk=strrep(mk,'.mk','.abs');
mk=strrep(mk,'.tm','.abs');
fod=fopen(mk,'w');

tmp = textscan(fid,'%s','Delimiter','\n');
fclose(fid);

tmp=tmp{1}
% fclose all;
% cspice_kclear
% disp('resetting al kernels')
% PATH_VALUES='NAN';
for i=1:numel(tmp)
    if any(strfind(strrep(tmp{i},' ',''),'PATH_VALUES='));
%         disp([tmp{i} ';'])
        eval([tmp{i} ';'])
        
        if any(strfind(PATH_VALUES,'..'))
            % e' un path relativo
            abs=[d filesep PATH_VALUES];
        else
            abs=PATH_VALUES;
        end
%         cd(PATH_VALUES)
%         abs=pwd;
        tmp{i}=strrep(tmp{i},PATH_VALUES,abs);
    end
    
%     if any(strfind(tmp{i},'PATH_SYMBOLS'));
%         eval(tmp{i})
%     end
    
    fprintf(fod,' %s \n',tmp{i});
    
end
fclose (fod);
% cd(C)
kread(mk)
%}
