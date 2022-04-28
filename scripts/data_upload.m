% This script upload the spectrometer slits of a given sequence.
  
% List of commanding files
cmd_list = ['JRM_CMD_003_003_V09.jrm'; 'JRM_CMD_041_041_V09.jrm'; 'JRM_CMD_051_051_V02.jrm'; 'JRM_CMD_061_061_V08.jrm'; 'JRM_CMD_071_071_V04.jrm'; 'JRM_CMD_081_081_V06.jrm'; 'JRM_CMD_091_091_V05.jrm'; 'JRM_CMD_101_101_V02.jrm'; 'JRM_CMD_111_111_V02.jrm'; 'JRM_CMD_121_121_V02.jrm'; 'JRM_CMD_131_131_V02.jrm'; 'JRM_CMD_141_141_V02.jrm'; 'JRM_CMD_151_151_V03.jrm'; 'JRM_CMD_161_161_V02.jrm'; 'JRM_CMD_171_171_V03.jrm'; 'JRM_CMD_181_181_V04.jrm'; 'JRM_CMD_191_191_V04.jrm'; 'JRM_CMD_201_201_V05.jrm'; 'JRM_CMD_211_211_V09.jrm'; 'JRM_CMD_221_221_V04.jrm'; 'JRM_CMD_231_231_V02.jrm'; 'JRM_CMD_241_241_V06.jrm'; 'JRM_CMD_242_242_V02.jrm'; 'JRM_CMD_251_251_V02.jrm'; 'JRM_CMD_261_261_V03.jrm'; 'JRM_CMD_271_271_V05.jrm'; 'JRM_CMD_281_281_V04.jrm'; 'JRM_CMD_291_291_V02.jrm'; 'JRM_CMD_301_301_V03.jrm'; 'JRM_CMD_311_311_V03.jrm'; 'JRM_CMD_321_321_V02.jrm'; 'JRM_CMD_322_322_V01.jrm'; 'JRM_CMD_331_331_V02.jrm'; 'JRM_CMD_340_340_V04.jrm'; 'JRM_CMD_350_350_V02.jrm'; 'JRM_CMD_360_360_V01.jrm'; 'JRM_CMD_370_370_V03.jrm'; 'JRM_CMD_380_380_V04.jrm'; 'JRM_CMD_390_390_V05.jrm'; 'JRM_CMD_400_400_V02.jrm'];

% list of orbit strings
orb_list = ['JM0003'; 'JM0041'; 'JM0051'; 'JM0061'; 'JM0071'; 'JM0081'; 'JM0091'; 'JM0101'; 'JM0111'; 'JM0121'; 'JM0131'; 'JM0141'; 'JM0151'; 'JM0161'; 'JM0171'; 'JM0181'; 'JM0191'; 'JM0201'; 'JM0211'; 'JM0221'; 'JM0231'; 'JM0241'; 'JM0242'; 'JM0251'; 'JM0261'; 'JM0271'; 'JM0281'; 'JM0291'; 'JM0301'; 'JM0311'; 'JM0321'; 'JM0322'; 'JM0331'; 'JM0340'; 'JM0350'; 'JM0360'; 'JM0370'; 'JM0380'; 'JM0390'; 'JM0400'];

% User chooses the orbit. The next while scrolls the commanding list above until a correspondence with the user input is found.
orbnum = input('Enter orbit number (three digits):\n');
list_ind = [];
imax = 0;
while isempty(list_ind)	
	imax = imax+1;
	list_ind = strfind(cmd_list(imax,:),num2str(orbnum));
end

L = jiramlist(cmd_list(imax,:),orb_list(imax,:),'',false,'SPE');

JIRAMmode = input('Enter operational mode (1 = I1, full imager; 2 = I2, M-imager; 3 = I3, L imager):\n');
switch JIRAMmode
  case 1
    mode_id = 'SCI_I1_S1';
    nLSCI = find(strcmp(L.mode_id,'SCI_I1_S1')); %full imager
  case 2
    mode_id = 'SCI_I2_S1';
    nLSCI = find(strcmp(L.mode_id,'SCI_I2_S1')); %M-imager
  case 3
    mode_id = 'SCI_I3_S1';
    nLSCI = find(strcmp(L.mode_id,'SCI_I3_S1')); %L-imager
  otherwise
end

disp('Indices of L-structure:')
for i = 1:numel(nLSCI)
	disp([num2str(i),' - ',num2str(nLSCI(i))])
end

iL = input('Enter index of the sequence:\n');

M = jiramdati(strrep(L.file{iL},'_TEMP',''));
selectdata(M,mode_id);
%M = addRT(M,mk);
