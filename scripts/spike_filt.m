% this script appies the routine of Takeuchi et al., 1993 to JIRAM spectra

clear;
close all;

common = '/home/bels/Documents/matlab/Spectra_filter/';
mk = '/home/bels/Documents/matlab/Aurorae_INAF/metakernel/recon.96.mk';

L = jiramlist('JRM_CMD_221_221_V04.jrm','JM0221','',false,'SPE');
nLSCI = find(strcmp(L.mode_id,'SCI_I3_S1'));
M = jiramdati(L.file{nLSCI(4)});
M = addRT(M,mk);


tab = importdata([common,'data/JM0003_limbs_00546.txt']);
wl = tab(:,1);
sp = tab(:,2:2:size(tab,2));
sp = sp*2e6; %power2counts
%sp = M.data{9}';
sp(sp<0) = nan;
k = 1:numel(wl);%find(wl > 3.455-0.290 & wl < 3.455+0.290);	% window in the L imager
Nr =  0.5e-7*2e6;

Ti = sum(sp(k,:),'omitnan');

%for i = 1:size(sp,2)
%	Ni(:,i) = sqrt(sp(k,i)+Nr^2);
%	Ti(i) = sum(sp(k,i));
%end
for i = 1:size(sp,2)-1
	for j = 1:numel(k)
		if Ti(i) < 0 | Ti(i+1) < 0 | isnan(sp(k(j),i))
			out(j,i) = nan;
			%disp('Skip')
			continue
		end
		I1 = sp(k(j),i);
		I2 = sp(k(j),i+1)*Ti(i)/Ti(i+1);
		Si = min([I1 I2]);
		Ni = sqrt(Si+Nr^2);
		if abs(I1-I2) > 4.7*Ni
			out(j,i) = min([I1 I2]);
		else
			out(j,i) = I1;
		end
%			I1 = I2;
%		elseif I2-I1 > 5.6*Ni
%			I2 = I1*Ti(i+1)/Ti(i);
%		end
%		out(j,i) = (I1+I2)/2;
	end
end

subplot(2,2,1)
surf(out)
shading flat
view([90 90])
%caxis([0 5])
colorbar
set(gca,'color', [0 0.3 0.3]);
title('out')

subplot(2,2,2)
surf(sp(k,:))
shading flat
view([90 90])
%caxis([0 5])
colorbar
set(gca,'color', [0 0.3 0.3]);
title('input')

subplot(2,2,3)
surf(abs(out-sp(k,1:end-1)))
shading flat
view([90 90])
caxis([0 5])
colorbar
set(gca,'color', [0 0.3 0.3]);
title('diff')

subplot(2,2,4)
plot(mean(out(:,:),2,'omitnan'))
hold on; grid on;
plot(mean(sp(k,:),2,'omitnan'))
title('mean')
legend('output','input')
%{
subplot(2,1,1)
plot(wl(k),sp(k,1));
hold on; grid on;
plot(wl(k),sp(k,2));

subplot(2,1,2)
plot(wl(k),out)
grid on
%}
