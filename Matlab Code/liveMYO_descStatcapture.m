clc;
clear;

t = tcpip('168.122.4.74', 3000,'NetworkRole','client');
set(t, 'InputBufferSize', 64);
fopen(t);
i = 1;
time=clock;
fs=200;
wsize=fs/2;
wind = 1;
o = 10;

while etime(clock,time)<100
    if t.BytesAvailable
        %data(i,:) = strsplit(fread(t),'\r\n');
        data(i,:) = fscanf(t, '%d,%d,%d,%d,%d,%d,%d,%d\r\n')';
        [m,n]=size(data);
        if ~mod(m,o) && m > 99
            
%             dataAvg(wind,:) = mean(data(m-wsize+1:m,:)^2);
%             dataAvgd=dataAvg+128;
%             dataAvgd=dataAvgd./256;
            dataStd(wind,:) = std(data(m-wsize+1:m,:));
            dataStdd=dataStd./128;
            
            fs=200;
            wind = wind + 1;
        end
        
        %pause(0.001);
        i = i + 1;
    end
end

fclose(t);

[Mu, R, P, p0, Px, E] = EMAlgorithm_kmeans_myo(dataStdd,4);