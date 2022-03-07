clc;
clear;
Num=20;
N = 256;
M = 4;
K = 1;
BER = zeros(Num,1);
snr = [1:Num];

%% 生成矩阵G，为MxK的波束赋形矩阵，M=4，K=10
G = rand(M,K);
%G_norm_Fro = norm(G,'fro');%F范数
%G_norm_Fro=sqrt(Pt);
%% 生成RIS相移矩阵phi，为NxN的对角矩阵，假设每个元素的绝对值为1
state_phase = pi*[-154.37/180, -67.83/180, 26.81/180, 115.08/180];
state_index = randsrc(N,1,[1:4]);
state       = exp(1i*state_phase(state_index));
phi=(diag(state));
%%%%%%%%%%%%%=======================%%%%%%%%%%%%%%
for i =1:Num
    BER(i) = BS_IRS_USERS_Model(phi,G,snr(i));
    fprintf('信噪比%.2f dB，仿真次数%.f,误码率%.4f\n ',snr(i),i*100000, BER(i));
end
figure;
semilogy(snr,BER,'b*-','LineWidth',1.5,'MarkerSize',6)
xlabel('SNR(dB)')
ylabel('误码率（BER）')
title('BER of MIMO communication with IRS')
grid on;