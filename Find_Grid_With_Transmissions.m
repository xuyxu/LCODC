% 该函数用于找出在同一个区域中智能设备序号以及区域序号
function [Result] = Find_Grid_With_Transmissions(Current_Car_Grid_Index,centroids)

Result = {};
Maximum_Distance = 1;
count = 1;

C = unique(Current_Car_Grid_Index,'rows');
for i = 1 : size(C,1)
    % 当前网格不是数据中心所在的网格
    if(sum(ismember(centroids,C(i,1))) == 0)
        temp_result(:,1) = abs(Current_Car_Grid_Index(:,1) - C(i,1)) + abs(Current_Car_Grid_Index(:,2) - C(i,2));
        temp_car_list = find(temp_result <= Maximum_Distance);
        
        % 如果在该网格中存在超过一个智能设备
        if(size(temp_car_list,1) > 1)
            Result{count,1} = temp_car_list;
            count = count + 1;
        end     
    end
end
end