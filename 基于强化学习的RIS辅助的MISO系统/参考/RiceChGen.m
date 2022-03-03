function H = RiceChGen(Kdb,a,b)
% H = a*H_los + b*H_nlos
% a^2 + b^2 = 1
% K是莱斯因子, 是直视信号分量和瑞利信号的功率比值
% 当其分别趋于0和正无穷时，会有瑞利和LOS信道之间的转变
K=10^(Kdb/10);
H_los=ones(a,b);%LOS，直视信号分量
H_rayleigh=(randn(a,b)+1i*randn(a,b))/sqrt(2);%rayleigh，非直视信号分量的总和
H=sqrt(K/(1+K))*H_los + sqrt(1/(1+K))*H_rayleigh;
end  