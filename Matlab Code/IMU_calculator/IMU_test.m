load('IMU_data/20160206T025901.mat');
[a b]=size(dataimu);
fs=50;
t=[1/fs:1/fs:a/fs]'
input=horzcat(t,dataimu(:,1:6));
initial=[euler(1,:);gyro(1,:);0 0 0];
output=find_position(input,initial);
