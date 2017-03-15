tic;
Device_Weight = zeros(size(new_Dataset,1),1); % 预分配内存

Maximum_Distance = 5; % 数据中心的接收半径为500m
t_weight = 0; % 用于记录智能设备权值的中间变量

for i = 1 : size(new_Dataset,1)
    
    [x_temp,y_temp] = GridIndex_Calculate(new_Dataset{i,1}.Location);
    
    for j = 1 : size(centroids,1)
        temp = abs(x_temp-centroids(j,1)) + abs(y_temp-centroids(j,2)); % 计算与第j个数据中心的曼哈顿距离
        t_weight = t_weight + size(find(temp <= Maximum_Distance),1); % 统计所有小于接收半径的点个数
    end
    
    Device_Weight(i,1) = t_weight; % 赋值
    t_weight = 0; % 清零
        
end
toc;