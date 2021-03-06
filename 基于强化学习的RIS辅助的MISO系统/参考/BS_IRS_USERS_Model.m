function BER = BS_IRS_USERS_Model(phi,G,snr)
% 该函数为BS-RIS-USERS链路通信模型,此模型为固定信道信息H1（NxM）矩阵和K（user数量）个hk2向量
% 该模型为RIS辅助的MISO通信系统模型，BS天线数为M，RIS的unit数为N，用户数为K
% 输入参数：
%   phi：RIS相移矩阵的对角元素
%   G：波束赋形矩阵
%   sigma：白噪声wk的方差
% 输出参数：
%   BER：误码率
phi_temp = phi;%相移矩阵,为NxN的对角矩阵
G_temp = G;    %为MxK的波束赋形矩阵
M = 4;         %天线数量
N = 256;       %256
K =1;         %用户数量
frame= 10000;  %仿真通信的帧数
%yk_temp =zeros(K,1);  %为Kx1的向量
%P = 1;         %基带功率增益 or 距离衰落？
errbits_total = 0;


%% 生成信道矩阵H1,符合莱斯分布，取莱斯因子为6dB,视距有轻微散射
%H1 = RiceChGen(6,N,M);
H1 = RiceChGen(0,N,M);
%% 生成信道向量hk2，符合莱斯分布，取莱斯因子为6dB   
%hk2 = RiceChGen(6,N,K);
hk2 = RiceChGen(0,N,K);
%% composite channel fading（KxM）（1xM）
H_composite = ctranspose(hk2) * phi_temp * H1;

for i = 1:frame
    x_digital  = randsrc(K, 1, [0:1:M-1]);             % 随机生成K个0：M-1的码元
    x_modula = pskmod(x_digital, M);                   % 4psk调制
    yk_temp  = H_composite * G_temp * x_modula ;    % K个用户接收到的信号
    yk_temp = awgn(yk_temp,snr,'measured');             % 加上信道白噪声
    y_h =  pinv(H_composite * G_temp)* yk_temp;     % 恢复调制信号
    x_recover = pskdemod(y_h, M);                      % 恢复发送码元
    
    errbits=length(find(x_digital~=x_recover));
    errbits_total = errbits + errbits_total;
end

err_rate = errbits_total/(frame*length(x_digital));
BER = err_rate;