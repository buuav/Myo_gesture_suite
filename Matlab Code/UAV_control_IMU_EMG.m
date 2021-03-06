clear;
data_imu = 0;
data_emg = 0;
%data = num2str([up,down,left,right,mystate]);
%s = whos('data');
load('20160201T132726_NFUD_aam_feb1.mat','P','p0','Mu','R');
tcpipServer = tcpip('0.0.0.0',55000,'NetworkRole','Server');
set(tcpipServer,'OutputBufferSize',8000);
fopen(tcpipServer);

t1 = tcpip('128.197.50.80', 10000,'NetworkRole','client'); % IMU port
set(t1, 'InputBufferSize', 400);
fopen(t1);

t2 = tcpip('128.197.50.80', 3000,'NetworkRole','client'); % EMG port
set(t2, 'InputBufferSize', 400);
fopen(t2);
i = 1;
time=clock;
fs=200;
lrswitch=0;
count=1;
fs=200;
wsize=fs/2;
wind = 1;
o = 10;
%nor__OUT_FIST_In_spread
while etime(clock,time)<200
    if t1.BytesAvailable
        rawdata_IMU(i,:) = fscanf(t1, '%f,%f,%f,%f,%f,%f,%f,%f,%f,%f\r\n')';
        %[m,n]=size(rawdata_IMU);
        
        Rot = quatrn2rot(rawdata_IMU(i,7:10));
        euler(i,1:3) = rot2ZYXeuler(Rot)*(180/3.1459);
        accel(i,1:3) = rawdata_IMU(i,1:3);
        gyro(i,1:3) = rawdata_IMU(i,4:6);
        
        if gyro(i,1) < -200
            data_imu = 1; %takeoff
        elseif gyro(i,1) > 200
            data_imu = 2; %land
        elseif gyro(i,3) > 80 && lrswitch<=0
            data_imu = 3; %left
            %lrswitch = lrswitch +1;
        elseif gyro(i,3) < -80 && lrswitch>=0
            data_imu = 4; %right
            %lrswitch = lrswitch -1;
        elseif euler(i,2) < -40
            data_imu = 5; %up
        elseif euler(i,2) > 40
            data_imu = 6; %down
       else
           data_imu= 10; %hover
        end
        
        fwrite(tcpipServer,num2str(data_imu),'char');
        i = i + 1;
        data_IMU = 0;
    end
    %      if lrswitch==1
    %          data=3;
    %      elseif lrswitch==-1
    %          data=4;
    %      end
    
    if t2.BytesAvailable
        %data(i,:) = strsplit(fread(t),'\r\n');
        rawdata_EMG(count,:) = fscanf(t2, '%d,%d,%d,%d,%d,%d,%d,%d\r\n')';
        [m,n]=size(rawdata_EMG);
        %mod(m,wsize)
        if ~mod(m,o) && m > 99
            
            %             dataAvg(wind,:) = mean(data(m-wsize+1:m,:)^2);
            %             dataAvgd=dataAvg+128;
            %             dataAvgd=dataAvgd./256;
            dataStd(wind,:) = std(rawdata_EMG(m-wsize+1:m,:));
            Y=dataStd(wind,:)./128;
            norml=diag(Normal(Y',Mu, R, 4));
            %norml=norml/max(max(norml));
            if wind==1
                Alpha(wind,:) = norml*p0;
            else
                Alpha(wind,:) = (norml*P*Alpha(wind-1,:)')';
                Alpha(wind,:) = Alpha(wind,:)/mean(Alpha(wind,:));
            end
            
            [maxvalue ,data_EMG]= max(Alpha(wind,:));
            if data_EMG == 4
                value=7; %forward
            elseif data_EMG == 2
                value=8; %Backward
            elseif data_EMG == 1
                %value=9; %Front_Flip
            else
                value=10; %Hover
            end
            fwrite(tcpipServer,num2str(value),'char')
            value=0;
            wind = wind + 1;
        end
        count = count + 1;
        
    end
    
    % if ~mod(m,o) && m > 99
    %    tempdata=mean(euler(i-99:2));
    %     data = num2str(round(tempdata))
    %     fwrite(tcpipServer,data,'char');
    % end
    
    
    
end

fclose(t1);
fclose(t2);
fclose(tcpipServer);







