% ======================================
% This script run jiramdati in order to create the .mat files corresponding to all the data provided by Alessandro Mura.
% ======================================
system('mount_ftp junoadm:Jun0Adm.14@ftp.sic.rm.cnr.it /Users/Utente/Desktop/noise/ftp');

%{
% === upload JM0003 ===
remotefold = '/home/bels/ftp/JIRAM_ARCHIVE/JM0003/PROCESSED_DATA/PDS_EDR/';
datalabel = ['082713'; '085655'; '091216'; '092707'; '094158'; '095720'; '102701'; '104152'; '105713'; '111204'; '112654'; '114144'];

% '101201'; -> this gives problem

for i = 1:size(datalabel,1)
	flname = [remotefold,'160827_',datalabel(i,:),'_JUNO_SPE_00/SPE_EDR_INDEX/JIRAM_STATUS_IMG.txt'];
	M = jiramdati(flname);

	disp('Completed upload:')
	disp(['160827_',datalabel(i,:),'_JUNO_SPE_00'])
end
%}
% =====================

OUT_list = dir('../jiramlist_saves/*IMG*');	%get the name of the structure L (saved as OUT)
%i1 = 1;
i2 = length(OUT_list);
i1 = i2;
for ifile = i1:i2					%first 2 entry are . and ..
	load(['../jiramlist_saves/',OUT_list(ifile).name])		%load structure L
	for idata = 1:length(OUT.file)								%run jiramdati.m for each L.file
		M = jiramdati(OUT.file{idata});
		disp('Completed upload:')
		disp([strrep(OUT_list(ifile).name,'..IMG.mat',''),', file n {',num2str(idata),'/',num2str(length(OUT.file)),'}'])
	end
end




