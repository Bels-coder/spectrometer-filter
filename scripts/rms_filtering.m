%% Script for filtering noisy spectra acquired by JIRAM %%
% The spectra have been previously corrected for the odd-even
% The script uses the functions:
% - frms.m
% - trms.m

clear;
close all;
clc;
set(0,'DefaultFigureVisible','off')

%% Reading the spectrum and constants 

c = physconst('lightspeed');                                               % light speed in [m/s]

orbit = '../JM0071/JM0071_NDR/';
data = dir(orbit);
data = data(3:end);                                                        % remove the first two elements

filename = string(zeros(length(data),1));
nome = string(zeros(length(data),1));

rms = zeros(length(data),1);
rms_h3 = zeros(length(data),1);
rms_h3_spe = zeros(length(data),1);

rms1 = zeros(length(data),1);
rms_h31 = zeros(length(data),1);
rms_h31_spe = zeros(length(data),1);

signal = zeros(length(data),336);
h3_signal = zeros(length(data),6);
h3_spe = zeros(length(data),336);

FT_signal = zeros(length(data),336);
FT_h3_signal = zeros(length(data),6);
FT_h3_spe = zeros(length(data),336);

m_signal = zeros(length(data),1);
m_h3_signal = zeros(length(data),1);
m_h3_spe = zeros(length(data),1);

FRMS = zeros(length(data),1); 
DRMS = zeros(length(data),1);
DSCALE = zeros(length(data),1);
RES = string(zeros(length(data),1));

for k= 1:1:size(data)%max(size(data))

    file = horzcat(orbit, data(k).name);                                   % creating a path to the file.
    [id,kom] = fopen(file);                                                % opening the file to get the ID and the information about the file.
    
    if id < 0                                                              % when id is < 0, some problem has occured while opening the file (kom gives the information).
        disp(kom)
    end

    % Remove header
    hdr = 21;
    for i = 1 :1: hdr
        line = fgetl(id);
%         fwrite(1,line);
%         fprintf('%s',line);
    end
    
    % Extracting the data
    filename(k,1) = data(k).name;                                              
    nome(k,1) = (data(k).name(1:end-4));
    spectrum.(horzcat(nome(k,1))) = fscanf(id,'%f %f %i',[3 inf]);         % 1st row -> wvl | 2nd -> intensity | 3rd -> mask (1/0)

    % Total spectrum
    wvl1 = spectrum.(horzcat(nome(k,1)))(1,:);                             % wavelength in [nm]
    signal(k,:) = spectrum.(horzcat(nome(k,1)))(2,:);                      % signal in [W/(m^2 um sr)] 
    m_signal(k) = mean(signal(k,:));                                       % mean of the signal in [W/(m^2 um sr)]

    %% H3+ bands and signal
    
    % H3+ bands only
    H3P = [3314.93 3377.86 3413.83 3449.79 3530.71 3665.57];               % H3+ bands in [nm]
    [sharedvals,idx] = intersect(wvl1,H3P,'stable');                       % find the index 
    h3_signal(k,:) = signal(k,idx);                                        % signal in the H3+ bands
    m_h3_signal(k) = mean(h3_signal(k,:));
    
    % H3+ bands + zero signal elsewhere
    h3_spe(k,:) = zeros(length(signal(k,:)),1);
    h3_spe(k,idx)=h3_signal(k,:);
    m_h3_spe(k) = mean(h3_spe(k,:));
    
    %% Serviceable conversions
    
    % Total spectrum
    wvl = wvl1*1E-9;                                                       % convert from [nm] to [m], where 1nm = 1E-9m
    wvn = 1E7./wvl1;                                                       % convert from [nm] to [cm-1], where 1nm = 1E-7
    freq = c./wvl;                                                         % convert from [m] to [Hz]
    dt = 2*pi/max(freq);                                                   % sampling period 
    t = [1:length(freq)]*dt;                                               % time vector
    df = 1/length(freq)*dt;                                                % frequency bin or FFT bin     
    
    
    %% Fourier Transforms 
    % Computed to double check the outputs in frequency domain and time domain 
    
    % Total spectrum
    FT_signal(k,:) = ifftshift(ifft(signal(k,:)));
    
    % H3+ bands only
    FT_h3_signal(k,:) = ifftshift(ifft(h3_signal(k,:)));
    
    % H3+ bands + zero signal elsewhere
    FT_h3_spe(k,:) = ifftshift(ifft(h3_spe(k,:)));

    %% RMS = Root Mean Square of the spectrum 
    
    % Total spectrum
    rms(k) = frms(signal(k,:));                                            
    rms1(k) = trms(FT_signal(k,:));                                   
    
    % H3+ bands only
    rms_h3(k) = frms(h3_signal(k,:));
    rms_h31(k) = trms(FT_h3_signal(k,:));
    
    % H3+ bands + zero signal elsewhere
    rms_h3_spe(k) = frms(h3_spe(k,:));  
    rms_h31_spe(k) = trms(FT_h3_spe(k,:));
    
    %% Filtering the spectra based on the RMS results
    
    % Thresholds
    FRMS(k) = (rms_h3_spe(k)/rms(k));
    DRMS(k) = rms(k)-rms_h3_spe(k);
    DSCALE(k) = DRMS(k)*FRMS(k);

    if FRMS(k) < 1E-2 || DSCALE(k) > 1.5E+5 || m_h3_spe(k) < 0              
        RES(k) = 'Reject';                                                                                               
    else                                                                   
        RES(k) = 'Save';
    end
    
    results.(horzcat(nome(k))) = ... 
        struct('FRMS', FRMS(k), 'DRMS', DRMS(k), ... 
        'RATIO', DSCALE(k), 'RESULT', RES(k));

end

FINAL = table(filename, FRMS, DRMS, DSCALE, RES);

return;

%% Plots of the spectrum and of the results %%%

single_spe = input('To plot a single spectrum type 1, otherwise 0 -> ');
if single_spe == 1
    n = input ('Spectrum number: ');
else
    n = 1:size(data);
end

disp(FINAL(n,:));
filename = data(n).name;
name = strrep(filename,'_','\_');

% Spectrum in the wavelength domain
f(1) = figure;
plot(wvl1,signal(n,:)); %,'LineWidth',1);
title('wavelength domain');
xlabel('wavelength (nm)');
ylabel('radiance (W/m^2 um sr)'); 
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold on
for i = 1:numel(H3P)
    h(i) = xline(H3P(i), ':', 'Color', [17 17 17]/255);                 
end
hold off

% Spectrum in the wavenumber domain
f(2) = figure;
plot(wvn,signal(n,:));
title('wavenumber domain');
xlabel('wavenumber (cm^-^1)');
ylabel('radiance (W/m^2 um sr)');
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold off

% Spectrum in the frequency domain
f(3) = figure;
plot(freq,signal(n,:))
title('frequency domain');
xlabel('frequency (Hz)');
ylabel('radiance (W/m^2 um sr)');
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold off

% Spectrum in time domain with the left and right halves of a vector swapped
f(4) = figure;
plot(t,ifft(signal(n,:)));
title('time domain swapped halves');
xlabel('time (s)');
ylabel('radiance (W/m^2 um sr)');
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold off

% Spectrum in time domain
f(5) = figure;
plot(t,FT_signal(n,:));
title('time domain');
xlabel('time (s)');
ylabel('radiance (W/m^2 um sr)');
yline(rms(n), '--','tot');
hold on
yline(rms_h3(n),':','h3+ bands', 'Color','g');                                      
hold on
yline(rms_h3_spe(n),'-.','h3+ tot', 'Color','r');
hold off

f(6) = figure;
tiledlayout(2,1)
set(gcf,'Position',[400 400 800 800])

% Top plot
nexttile
plot(wvl1, signal(n,:));
xlim([2000 5000])
title(name);
xlabel('wavelength (nm)');
ylabel('radiance (W/m^2 um sr)');    
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold on
for i = 1:numel(H3P)
    h(i) = xline(H3P(i), ':', 'Color', [17 17 17]/255);                 
end
hold off

% Bottom plot
nexttile
plot(wvl1, signal(n,:));
xlim([3200 3770])
title('zoom');
xlabel('wavelength (nm)');
ylabel('radiance (W/m^2 um sr)');    
if single_spe == 1
    yline(rms(n), '--','tot');
    hold on
    yline(rms_h3(n),'--','h3+ bands', 'Color','r');
    hold on
    yline(rms_h3_spe(n),'--','h3+ tot', 'Color','g');
end
hold on
for i = 1:numel(H3P)
    h(i) = xline(H3P(i), ':', 'Color', [17 17 17]/255);                 
end
hold off

%% Plotted figures

figure(1)
% figure(2)
% figure(6)


