clear all
clc
load('Tx-RIS(H), RIX-Rx(G), Tx-Rx(D),4-256-16（1次）');
%load('Tx-RIS(H), RIX-Rx(G), Tx-Rx(D),16-256-64（1次）');
EbN0= [5:1:25];
lE=length(EbN0);
err_ber=zeros(1,lE);
frame=100000;
M=4;%QPSK调制
Nt=4;
Nr=16;
N=256;%RIS单元数量
%data=randsrc(1,Nt,[0 1]);
P=1;%基带功率
%%   ----------IRS-USER的信道状态矩阵生成-------------
%hr1=[5-2i 3+1i 1+2i;  3-2i 2-1i 2+2i;  1+4i 2-1i 2+1i;  -5+1i 1+3i 2+3i];   %IRS-接收者的信道4*3  IRS为3，接收天线为4


%%   -----------Tx-Rx的信道状态矩阵生成--------------
%hd1=[4-9i 3+1i 1+2i 5+2i];  %AP-接收者的信道1*4  发射天线为1，接收天线为4



%%   -----------IRS相应矩阵（对角矩阵）的生成-----------
A=rand(1,N);
B=rand(1,N);
a=A+B*i;
Theta=(diag(a));  %将IRS离散相移组合的过程(IRS的响应状态矩阵，该矩阵这里为随机产生)


%%   -----------Tx到IRS信道状态矩阵的生成--------------
%G=rand(N,Nt);      %G是发射端到IRS的矩阵,发射端为1，IRS为3



%%   -----------Tx—IRS_Rx整体矩阵的计算-----------------
Ha=hr1*Theta*G;     %发射天线为Nt，接收天线为Nr，IRS元件数为N时，Ha为Nr*Nt的矩阵
%Ha=hr1*G;


%%   -----------(Tx到Rx)的整个信道状态生成矩阵--------
H=Ha+hd1;



%%   -----------------噪声矩阵的生成------------------




%%   -----------------发送序列x的生成以及相应的接收符号y-----------------



%%  -----------------接收符号y以及译码符号y1以及误码率BER计算----------------------
y=zeros(Nr,1);
for m=1:lE
    %sigma=sqrt(10^(EbN0(m)/10)); %每根接收天线的高斯白噪声标准差
   % n = sigma*(randn(Nr,1)+1i*randn(Nr,1)); %每根接收天线的高斯白噪声
    %sigma=sqrt(10^(EbN0(m)/10));%高斯噪声标准差
for i=1:frame
    %n = sigma*(randn(Nr,1)+1i*randn(Nr,1)); %每根接收天线的高斯白噪声
    x=randsrc(Nt,1,[0 1]);%发送字符x的生成
    x1=pskmod(x,M,pi/4); %QPSK调制符号
    z=(Ha+hd1)*x1*P;  %z为未加噪声之前序列，是Nt*1的序列。
   % y=awgn(z,Nr,sigma);%y为添加噪声之后的序列，即接收天线接收到的信号，y为Nt*1的序列。
   sigma=sqrt(1/(10.^(EbN0(m)/10)));
   n=sigma*(randn(Nr,1)+1i*randn(Nr,1))/2;
   %y=z+n;
    y=awgn(z,EbN0(m),'measured');% matlab的测量加噪，更逼近实际通信环境
    %----译码以及误码率的计算--------------------
    disp(y)
    y_h=pinv(Ha+hd1)*y;%求信道状态矩阵的M-P广义逆,进行相位消除；=====这个步骤的意义？？====
    
    y1=pskdemod(y_h,M,pi/4);%相位消除之后再对接收到的信号进行解调；
   
    errbits=length(find(y1~=x));
   err_ber(m)=errbits+err_ber(m);
end
%[temp,BER(m)]=biterr(x,y1,log2(M));
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
