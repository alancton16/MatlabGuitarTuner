% Alan's Guitar Tuner Code
% Dec 18, 2020
clc;clear;
bigloop = 1; 

while bigloop == 1
    
littleloop = 1;    
note_Freqs = [82.5, 110, 146.8, 196, 246.9, 329.6]; % E, A, D, G, B, e. Open string freqs for A440 tuning

% prompts user to input which string is being tuned
prompt= '\nPress the number corresponding to string being tuned, Press 0 to end program\n E, A, D, G, B, e\n 1, 2, 3, 4, 5, 6\n'; 

%this block prevents the program from running with an invalid string value
x = ceil(input(prompt)); 
if x == 0 
    break; 
end
if x >6 || x < 0
    for i = 1:999
        fprintf('Please input a valid number');
        x = input(prompt); 
        if x <= 6 && x >= 1
            break;
        else
        end
    end   
end

our_freq = note_Freqs(x) % desired frequency for chosen string 
while littleloop == 1
    
% uses computer mic to record for 5 seconds
dummy = input('Press enter to start recording\n');
fprintf('Recording... ');
recObj = audiorecorder;
Fs = 44100 ; % CD Quality sampling rate
nBits = 16 ; % Bits per sample
nChannels = 1 ; 
ID = -1; % default audio input device 
recObj = audiorecorder(Fs,nBits,nChannels,ID);
recordblocking(recObj,5); % records audio for 5 seconds
y = getaudiodata(recObj);
fprintf('Filtering...\n');
L = 220500; % length of audio file


f= Fs *(0:(L/2))/L; %frequency steps for plot
special = [263, 401, 585, 827, 1081, 1501]; % array of lower passband frequencies for FFT filtering
f_special = special(x); % lower passband freq to be used
q = fft(y); %fft of audio data
P2= abs(q/L); % double sided spectrum
P1= P2(1:L/2+1);
P1(2:end-1)= 2*P1(2:end-1); % single sided

P1_trunc= P1(1:2001);  % truncates FFT
for i = (1:2001)    % filters out background noise below threshold
    if P1_trunc(i) < 0.002
        P1_trunc(i) = 0; 
    end
end

% Frequency domain implementation of a bandpass filter of bandwidth 60
% centered around desired string frequency

for i = (1:f_special-1) % filters our FFT data before lower passband freq, f_special
    P1_trunc(i)=0; 
end
for i = (f_special+300: length(P1_trunc)) % filters out FFT data after upper passband freq, f_special + 60 Hz
    P1_trunc(i)=0; 
end

[peaks, locs] = findpeaks(P1_trunc, f(1:2001), 'SortStr','descend'); % sorts fft peaks in descending order of magnitude
f_char = min(locs);  % returns frequency of lowest freq peak

dif_arry = zeros(1,length(locs)); % subtracts desired string freq from each measured peaks
for i = 1:length(locs)
    dif_arry(i) = our_freq - locs(i); 
end
diffresult = abs(dif_arry) < 1; % Logic array that sees if any peak was within 1 Hz of desired freq 
   

if ismember(1,diffresult)  % if a peak is withing tolerance tell user string is in tune
    fprintf('String is in tune\n\n');
    littleloop = 0; 
elseif isempty(locs) % if there are no peaks print oof
    fprintf('Oof\n');
    littleloop = 0; 
elseif f_char < our_freq % if characteristic freq is less than desired freq tell user to tighten string
    fprintf('Tighten String and try again\n\n');
else
    fprintf('Loosen String and try again\n\n'); % if characteristic freq is greater than desired freq tell user to loosen string
end


plot(f(1:2001),P1(1:2001)) % plots single sided fft

title('FFT of recorded audio')
xlabel('Frequency (Hz)')
ylabel('Amplitude')
grid on; 
end
end 