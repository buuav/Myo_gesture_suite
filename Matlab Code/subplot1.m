load('eeg_data.mat')
load('3x8x5_NFIPNSnSpO.mat')

figure
suptitle('Original Data')
[a,b]=size(raw_data);
psize=3;
xaxis=1/200:1/200:a/200;
nlines=round(a/600);
for i=1:b
    subplot(4,2,i);
    plot(xaxis,raw_data(:,i));
    %title('hi %i',i);
    for j=1:nlines
    line([3*j 3*j], [-200 200]);
    end
end

figure
imagesc(xaxis,1:7,Alpha');
colorbar;
for j=1:nlines
    line([3*j 3*j], [0.5 7.5],'color','red');
    end

figure
suptitle('filtered Data')
[a,b]=size(data);
[c,d]=butter(9,0.5);
filt_data=filter(c,d,data);
psize=3;
xaxis=1/200:1/200:a/200;
nlines=round(a/600);
for i=1:b
    subplot(4,2,i);
    plot(xaxis,filt_data(:,i));
    %title('hi %i',i);
    for j=1:nlines
    line([3*j 3*j], [-200 200]);
    end
end

figure
suptitle('spectrogram Data')
for i=1:b
    subplot(4,2,i);
    %[S,F,T,P{i}]=spectrogram(data(:,b),200,100,256,200);
    spectrogram(data(:,i),200,100,256,200,'yaxis');
     xlabel('Time');
      ylabel('Frequency (Hz)');
    %title('hi %i',i);
    for j=1:nlines
    line([3*j 3*j], [-200 200]);
    end
end

spectrogram(data(:,8),200,100,256,200,'yaxis')
view(-77,72)
shading interp
colorbar off

spectrogram(data(:,8),kaiser(128,18),120,128,200,'yaxis','MinThreshold', -70)

tf1 = specgram(data(:,8),200,256,200,199)
imagesc(abs(tf1))

mesh(abs(P{1}))

spectrogram(data(:,1),256,[],[],200,'yaxis');