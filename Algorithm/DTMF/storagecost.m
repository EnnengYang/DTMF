% Calculate storage size

m = 50000; % user number
n = 50000; % item number

S = -1+2*rand(m,n);
% save('RealValue.mat','-v7.3')
save RealValue.mat S

B = ~(S<0);
save Discrete.mat B
