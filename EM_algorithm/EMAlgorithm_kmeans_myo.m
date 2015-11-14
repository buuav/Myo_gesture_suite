
function [Mu, R, P, p0, Px, E] = EMAlgorithm_kmeans_myo(Y,n)
[a,N]=size(Y);
Y=Y+128;
Y=Y./256;
%n = 5;%number of states
p0 = .5*ones([n 1]);
P=0.1*ones([n n]);
dm=1-(0.1*(n));
P=P+(dm*diag(ones([1 n])));
%P = [.7 .1 .1 .1 .1 .1 .1 ; .1 .7 .1 .1;.1 .1 .7 .1;.1 .1 .1 .7];

%N = 8;%number of observation
[idx C]=kmeans(Y,n);%k-means initialization
for i=1:n
R{i} = .1*eye(N);
Mu{i}= C(i,:)';
end
% Mu{1} = [.5; 0; 0; 0];
% Mu{2} = [.6; 0; 0; 0];
% p0 = [.5; .5; .5; .5];
% P = [.7 .1 .1 .1; .1 .7 .1 .1; .1 .1 .7 .1; .1 .1 .1 .7];
% n = 4;
% N = 2;
% 
% Mu{1} = [.4; 0];
% R{1} = .1*eye(2);
% 
% Mu{2} = [.5; 0];
% R{2} = .1*eye(2);
% 
% Mu{3} = [.6; 0];
% R{3} = .1*eye(2);
% 
% Mu{4} = [.7; 0];
% R{4} = .1*eye(2);

alpha = [reshape(P,n^2,1); p0];
for j = 1:length(p0)
    alpha = [alpha; reshape(R{j},N^2,1); Mu{j}];
end

for i = 1:50
    alphaimo = alpha;
    [Pxx, Px] = Estep(p0, P, Mu, R, Y);
    [Mu, R, P, p0] = Mstep(Px, Pxx, Y);
    alpha = [reshape(P,n^2,1); p0];
    for j = 1:length(p0)
        alpha = [alpha; reshape(R{j},N^2,1); Mu{j}];
    end
    E(i) = norm(alpha-alphaimo);
    i
    mean{i}=Mu{1};
    if i>2
    change=norm(mean{i}-mean{i-1})
    if change<0.0005
        break
    end
    end
end
