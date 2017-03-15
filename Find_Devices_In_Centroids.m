% 该函数用于找出在数据中心接收范围内的智能设备序号

function [Dump_Car_List] = Find_Devices_In_Centroids(Current_Car_Grid_Index, centroids)

Maximum_Distance = 5;

Dump_Car_List = [];
for i = 1 : size(centroids,1)
    Distance_Matrix = abs(Current_Car_Grid_Index(:,1) - centroids(i,1)) + abs(Current_Car_Grid_Index(:,2) - centroids(i,2)); % 计算每个智能设备到第i个数据中心的曼哈顿距离
    temp_list = find(Distance_Matrix <= Maximum_Distance); % 找出距离小于数据中心接收距离的智能设备编号
    Dump_Car_List = [Dump_Car_List;temp_list]; % 与之前的结果合并
end
Dump_Car_List = unique(Dump_Car_List); % 为防止异常错误，去重

end

