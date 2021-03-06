
load('5state_NFISO_aamodh_25Jan.mat');

t = tcpip('128.197.50.79', 3000,'NetworkRole','client');
set(t, 'InputBufferSize', 64);
fopen(t);

tcpipServer = tcpip('0.0.0.0',55000,'NetworkRole','Server');
%set(tcpipServer,'OutputBufferSize',s.bytes);
fopen(tcpipServer);

count = 1;
time=clock;
fs=200;
wsize=fs/2;
wind = 1;
o = 10;

%nor__OUT_FIST_In_spread
while etime(clock,time)<200
    if t.BytesAvailable
        %data(i,:) = strsplit(fread(t),'\r\n');
        data(count,:) = fscanf(t, '%d,%d,%d,%d,%d,%d,%d,%d\r\n')';
        [m,n]=size(data);
        %mod(m,wsize)
        if ~mod(m,o) && m > 99
            
            %             dataAvg(wind,:) = mean(data(m-wsize+1:m,:)^2);
            %             dataAvgd=dataAvg+128;
            %             dataAvgd=dataAvgd./256;
            dataStd(wind,:) = std(data(m-wsize+1:m,:));
            Y=dataStd(wind,:)./128;
            norml=diag(Normal(Y',Mu, R, 5));
            %norml=norml/max(max(norml));
            if wind==1
                Alpha(wind,:) = norml*p0;
            else
                Alpha(wind,:) = (norml*P*Alpha(wind-1,:)')';
                Alpha(wind,:) = Alpha(wind,:)/mean(Alpha(wind,:));
            end
            
            [value ,mystate(wind)]= max(Alpha(wind,:));
            %if ~mod(count, 100)
            %tempdata=mean(mystate(count-99:count));
            data_out = num2str(mystate(wind))
            fwrite(tcpipServer,data_out,'char');
        %end
            wind = wind + 1;
        end
        count = count + 1;
    end
end

fclose(t);
fclose(tcpipServer);







