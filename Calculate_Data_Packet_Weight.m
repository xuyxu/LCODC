function [Weight] = Calculate_Data_Packet_Weight(Buffer, Current_Time_Slice)

k = 1000;
% 预分配内存
Weight = zeros(size(Buffer,1),1);

% 计算数据包权值的公式（针对刚产生的数据包，权值为无限大，即一定会放在内存中）
Weight(:,1) = (1 ./ Buffer(:,3)) + k * (1./ (Current_Time_Slice - Buffer(:,4)));

% Weight = rand(size(Buffer,1),1);

end

