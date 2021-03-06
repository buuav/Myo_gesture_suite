clc;
clear;

t = tcpip('128.197.50.236', 3000,'NetworkRole','client');
set(t, 'InputBufferSize', 64);
fopen(t);
i = 1;
time=clock;
fs=200;
wsize=fs/2;
wind = 1;
[b,a] = butter(6,0.5);

id = 'signal:findpeaks:largeMinPeakHeight';
warning('off',id);

while etime(clock,time)<60
    if t.BytesAvailable
        %data(i,:) = strsplit(fread(t),'\r\n');
        data(i,:) = fscanf(t, '%d,%d,%d,%d,%d,%d,%d,%d\r\n')';
        [m,n]=size(data);
        if ~mod(m,wsize)
            elec3raw=data(m-wsize+1:m,3);
            elec5raw=data(m-wsize+1:m,5);
            elec1raw=data(m-wsize+1:m,1);
            filt_data5=filter(b,a,elec5raw);
            filt_data1=filter(b,a,elec1raw);
            [~,locs_Rwave3] = findpeaks(elec3raw,'MinPeakHeight',60,'MinPeakDistance',(fs/2)-2);
            [~,locs_Rwave5] = findpeaks( elec5raw,'MinPeakHeight',90,'MinPeakDistance',(fs/2)-2);
            [~,locs_Rwave1] = findpeaks( filt_data1,'MinPeakHeight',65,'MinPeakDistance',(fs/2)-2);
            
            if any(locs_Rwave3)
                fist(wind) = any(locs_Rwave3);
                fprintf('fist=%d \n',fist(wind))
            elseif any(locs_Rwave1)
                inward(wind) = any(locs_Rwave1);
                fprintf('inward=%d \n',inward(wind))
            elseif any(locs_Rwave3) && any(locs_Rwave5)
                spread(wind) = any(locs_Rwave5);
                fprintf('spread=%d \n',spread(wind))
            end
            
            xaxis=m-wsize+1:m;
            xaxis=xaxis/fs;
            
            %             plot(xaxis,elec3raw);
            %             hold on;
            %             plot(locs_Rwave/fs,elec3raw(locs_Rwave),'rv','MarkerFaceColor','r');
            fs=200;
            wind = wind + 1;
        end
        
        %pause(0.001);
        i = i + 1;
    end
end

fclose(t);