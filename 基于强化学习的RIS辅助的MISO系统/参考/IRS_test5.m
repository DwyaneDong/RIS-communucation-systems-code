clear all
clc
load('Tx-RIS(H), RIX-Rx(G), Tx-Rx(D),4-256-16（1次）');
EbN0= [5:1:25];
lE=length(EbN0);
err_ber=zeros(1,lE);
frame=5000;
M=4;%QPSK调制
Nt=4;
Nr=16;
N=256;%RIS单元数量
P=1;%基带功率
%%   -----------IRS相应矩阵（对角矩阵）的生成-----------
A=rand(1,N);
B=rand(1,N);
a=A+B*i;
Theta=(diag(a));  %将IRS离散相移组合的过程(IRS的响应状态矩阵，该矩阵这里为随机产生)
%%   -----------Tx—IRS_Rx整体矩阵的计算-----------------
Ha=hr1*Theta*G;     %发射天线为Nt，接收天线为Nr，IRS元件数为N时，Ha为Nr*Nt的矩阵
%%   -----------(Tx到Rx)的整个信道状态生成矩阵--------
H=Ha+hd1;
y=zeros(Nr,1);
for m=1:lE
   
for i=1:frame
   
    x  = randsrc(Nt,1,[0 1]);%发送字符x的生成
    x1 = pskmod(x,M,pi/4); %QPSK调制符号
    z  = H * x1 * P;  %z为未加噪声之前序列，是Nt*1的序列。
    y  = awgn(z,EbN0(m),'measured');% matlab的测量加噪，更逼近实际通信环境
    
    %----译码以及误码率的计算--------------------
    disp(y)
    y_h=pinv(Ha+hd1)*y;%求信道状态矩阵的M-P广义逆,进行相位消除；实际解调过程中不知道信道状态矩阵该怎么办？
    y1=pskdemod(y_h,M,pi/4);%相位消除之后再对接收到的信号进行解调； 
    errbits=length(find(y1~=x));
    err_ber(m)=errbits+err_ber(m);
end

BER(m)= err_ber(m)./(length(x)*frame);%  误码率计算
fprintf('信噪比%.2f，仿真次数%.f\n,误码率%.f\n, ',EbN0(m),frame, BER(m));
end

%----------------------作图---------------------------
figure;
semilogy(EbN0,BER,'b*-','LineWidth',1.5,'MarkerSize',6)
xlabel('EbN0(dB)')
ylabel('误比特率（BER）')
title('BER of MIMO communication with IRS')
grid on;
legend('IRS-MIMO(4-16-4)');
%%   -----------------判决译码函数------------------------

%%  ------------------高斯噪声函数-------------------------
% function y =awgn(x,len,sigma)
% %功能是向发送的混合比特添加awgn噪声，模拟发送序列通过信道
% % 输入x为bpsk后的混合比特，len为其长度，sigma为高斯噪声标准差，输出即为接收比特
% noises = sigma*randn(len, 1);   %randn(m,n)或randn([m n]）,返回一个m*n的随机项矩阵
% y=x+noises;
% end
