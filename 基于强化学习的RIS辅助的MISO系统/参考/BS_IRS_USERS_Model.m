function yk = BS_IRS_USERS_Model(phi,G)
% 该函数为BS-RIS-USERS链路通信模型,此模型为固定信道信息H1（NxM）矩阵和K（user数量）个hk2向量
% 该模型为RIS辅助的MISO通信系统模型，BS天线数为M，RIS的unit数为N，用户数为K
% 输入参数：
%   phi：RIS相移矩阵的对角元素
%   G：波束赋形矩阵
% 输出参数：
%   yk：接收信号
phi_temp = phi;%相移矩阵,为NxN的对角矩阵
G_temp = G;    %为MxK的波束赋形矩阵
M = 4;         %天线数量
N = 256;       %256
K =10;         %用户数量
frame= 10000;  %仿真通信的帧数
%yk_temp =zeros(K,1);  %为Kx1的向量
P = 1;         %基带功率增益 or 距离衰落？
sigma = 1;     %白噪声wk的标准差


%% 生成信道矩阵H1,符合莱斯分布，取莱斯因子为6dB
H1 = RiceChGen(6,N,M);
%% 生成信道向量hk2，符合莱斯分布，取莱斯因子为6dB   
%hk2 = RiceChGen(6,N,K);
hk2 = RiceChGen(6,N,1);
%% 信道白噪声
wk = wgn(K, 1, sigma);
%% composite channel fading（KxM）（1xM）
fade_composite = ctranspose(hk2) * phi_temp * H1;

for i = 1:frame
    x_digital  = randsrc(K, 1, [0:1:M-1]);    %随机生成0：M-1的码元
    x_modula = pskmod(x_digital, M);          % 4psk调制
    yk_temp  = fade_composite * G_temp * x_modula + wk; %K个用户接收到的信号
    
    y_h = pinv(fade_composite) * yk_temp;     % 恢复调制信号
    x_recover = pskdemod(y_h, M);             % 恢复发送码元

    