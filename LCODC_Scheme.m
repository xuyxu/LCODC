% load('Filtered_Dataset.mat')
% load('智能设备权重.mat')
% load('Statistical_Matrix.mat')
% load('Centroids.mat')

% 1.实验参数定义
Car_Number = size(new_Dataset,1); % 智能设备数量：8826
Car_Capacity = 200; % 每个智能设备能够存储的数据包个数上限
Overflow_Count = 0; % 用于记录在某一时间片内存溢出的智能设备数量
Car_In_Data_Center = 0; % 用于记录在数据中心接收范围内的智能设备数量
Number_of_Grids_With_Packet_Exchange = 0; %用于记录发生数据交换的区域个数

% 2.变量预分配
Car_Total_Point_Number = zeros(Car_Number,1); % 存储每个移动节点的轨迹点数目
Time_Slice = zeros(); % 当前时间片
Internal_Memory = zeros(Car_Capacity,4,Car_Number); % 模拟每个智能设备内存的矩阵
Current_Memory_Index = zeros(Car_Number,1); % 存储每个智能设备内存中已存储的数据包个数
Overall_Uploaded_Packet = []; % 用于存储所有提交的数据包信息
Summary_Matrix = [];

% 3.变量预计算
% Car_Total_Point_Number（整个T-Drive数据集中共有9957680个轨迹点信息）
for i = 1 : Car_Number
    Car_Total_Point_Number(i,1) = size(new_Dataset{i,1}.Location,1);
end

% 4.实验流程
% 实验以时间为参照标准不断向前推进

for Time_Slice = 1 : max(Car_Total_Point_Number)
    
    tic;
    
    %---------------------%                                          (完成)
    %-智能设备位置确定模块-% 
    %---------------------%
    % <<说明>>
    %     该模块首先找出在当前时间片仍然有轨迹记录的智能设备列表(Current_Car_List)；
    % 接着根据经纬度位置计算出它们所在的网格号，存放在变量Current_Car_Grid_Index中。
    
    % 找出在当前时间片仍然有记录的移动节点列表
    Current_Car_List = find(Car_Total_Point_Number >= Time_Slice);
    
    % 获取有记录的移动节点的经纬度，存放在变量Current_Car_Location中
    Current_Car_Location = zeros(size(Current_Car_List,1),2); % 预分配内存
    for i = 1 : size(Current_Car_List,1)
        Current_Car_Location(i,:) = new_Dataset{Current_Car_List(i,1),1}.Location(Time_Slice,:);
    end
    
    % 计算每个移动节点的网格x,y号，存放在变量Current_Car_Grid_Index中
    Current_Car_Grid_Index = zeros(size(Current_Car_List,1),2); % 预分配内存
    [Current_Car_Grid_Index(:,1),Current_Car_Grid_Index(:,2)] = GridIndex_Calculate(Current_Car_Location);
    
    %----------------------%                                         (完成)
    %-智能设备采集数据包模块-%
    %----------------------%
    % <<说明>>
    %     该模块模拟数据包的产生和收集过程。生成的数据包存放在一个全局变量Internal_Memory中。每个数据包的信息
    % 包括产生区域的网格号，该网格的车流量，和数据包的采集时间。
    
    % 模拟移动节点在该网格中采集数据包（第一、二列：x,y轴序号，第三列：数据包对应区域的权值，第四列：数据包采集时间）
    Collected_Packet = zeros(size(Current_Car_List,1),4); % 预分配内存
    
    Collected_Packet(:,1) = Current_Car_Grid_Index(:,1);
    Collected_Packet(:,2) = Current_Car_Grid_Index(:,2);
    % 获得权值                                                      [待优化]
    for i = 1 : size(Current_Car_List,1)
        % matlab矩阵读取从1开始
        if(Current_Car_Grid_Index(i,1) == 0)
            Current_Car_Grid_Index(i,1) = 1;
        end
        if(Current_Car_Grid_Index(i,2) == 0)
            Current_Car_Grid_Index(i,2) = 1;
        end
        
       Collected_Packet(i,3) =  Statistical_Matrix(Current_Car_Grid_Index(i,1),Current_Car_Grid_Index(i,2));
    end
    Collected_Packet(:,4) = ones(size(Current_Car_List,1),1) * Time_Slice; % 记录数据包产生时间
    
    %---------------------%                                          (完成)
    %-智能设备内存更新模块-%
    %---------------------%
    % <<说明>>
    %     该模块用于更新每个智能设备内存中的内容。具体的，如果内存未满，则将新产生的数据包
    % 添加到内存的末尾；如果内存已满，则计算内存中所有数据包和新产生数据包的权重并从大到
    % 小排序，取权值最大的前容量个。
    
    % 判断每个智能设备内存是否已满并更新内存存储内容
    for i = 1 : size(Current_Car_List,1)
        
        % 内存未溢出（通过变量Current_Memory_Index实现）
        if(Current_Memory_Index(Current_Car_List(i,1),1) < Car_Capacity)
            Current_Memory_Index(Current_Car_List(i,1),1) = Current_Memory_Index(Current_Car_List(i,1),1) + 1; % 数据包个数+1
            Internal_Memory(Current_Memory_Index(Current_Car_List(i,1),1),:,Current_Car_List(i,1)) = Collected_Packet(i,:); % 将当前智能设备采集的数据包放入内存中
        
        % 内存溢出
        else
            Overflow_Count = Overflow_Count + 1;
            Buffer = [squeeze(Internal_Memory(:,:,Current_Car_List(i,1)));Collected_Packet(i,:)]; % 将当前采集的数据包和之前所有的数据包放入缓冲区
            Data_Weight = Calculate_Data_Packet_Weight(Buffer, Time_Slice); % 计算数据包权值
            [~,L] = sort(Data_Weight,'descend'); % 按权值从大到小排序
            Internal_Memory(:,:,Current_Car_List(i,1)) = Buffer(L(1:Car_Capacity),:); % 取权值最大的Car_Capacity个数据包放入该智能设备的内存中，并丢弃其他数据包
        end
    end
    
    %------------------------%                                       (完成)
    %-向数据中心提交数据包模块-%
    %------------------------%
    % <<说明>>
    %     该模块用于模拟智能设备向数据中心提交数据包的过程。首先该模块找出所有处于数据中心接收范围的
    % 智能设备序号；接着取出这些智能设备内存中的内容整合到临时变量temp_Uploaded_Packet中。在此过程
    % 的同时，为每个数据包加上智能设备序号信息。最后，将临时变量temp_Uploaded_Packet压缩提交至数据
    % 中心后台对应的变量Overall_Uploaded_Packet。完成上述操作后，对所有提交数据包到数据中心的智能
    % 设备进行内存清空。
    
    % 对处于数据中心接收范围内的智能设备进行上传数据到数据中心操作，并清空内存中存储的数据
    [temp_Dump_Car_List] = Find_Devices_In_Centroids(Current_Car_Grid_Index,centroids);
    Car_In_Data_Center = Car_In_Data_Center + size(temp_Dump_Car_List,1);
    Dump_Car_List = Current_Car_List(temp_Dump_Car_List(:,1)); % Dump_Car_List存储着需要与数据中心发生数据传输的智能设备编号
    temp_Uploaded_Packet = []; % 预分配内存
    
    % 整合所有要传输的数据包，存放在变量Uploaded_Packet中
    for i = 1 : size(Dump_Car_List,1)
        temp_Uploaded_Packet = [temp_Uploaded_Packet;[squeeze(Internal_Memory(:,:,Dump_Car_List(i,1))),ones(size(Internal_Memory(:,:,Dump_Car_List(i,1)),1),1)*Dump_Car_List(i,1)]];
    end
    % 去除所有空内存以减少存储开销
    temp_index = find(sum(temp_Uploaded_Packet(:,1),2) > 0);
    Uploaded_Packet = temp_Uploaded_Packet(temp_index,:);
    % 加上当前时间对应的时间片信息
    Uploaded_Packet(:,6) = ones(size(Uploaded_Packet,1),1)*Time_Slice;
    % 提交数据包
    Overall_Uploaded_Packet = [Overall_Uploaded_Packet;Uploaded_Packet];
    % 清空智能设备的内存
    for i = 1 : size(Dump_Car_List,1)
        Internal_Memory(:,:,Dump_Car_List(i,1)) = 0;
    end
    
    %---------------------%                                          (完成)
    %-智能设备数据交换模块-%
    %---------------------%
    %  <<说明>>
    %    该模块首先找出同处在一个网格中的智能设备集合。然后针对该集合中的每个智能设备比较其
    % 与该集合内剩余的其他智能设备的权重信息并按照LCODC策略决定是否要广播自身内存中的数据包。
    % 对于其他智能设备来说如果自身数据包个数加上接收到的数据包个数的总和仍然小于等于内存容量。
    % 则简单地将接收到的数据包放在内存中。如果总和大于了内存容量，则需要计算每个数据包的权重。
    % 取权重最大的前容量个放在自身的内存中。
    
    % 找出所有处在同一个区域中的智能设备编号，分区域存放在元胞数组中
    [Transmission_Car_List] = Find_Grid_With_Transmissions(Current_Car_Grid_Index,centroids);
    Number_of_Grids_With_Packet_Exchange = size(Transmission_Car_List,1);
    for i = 1 : size(Transmission_Car_List,1)
        fake_Current_Car_In_Same_Grid = Transmission_Car_List{i,1};
        Current_Car_In_Same_Grid = Current_Car_List(fake_Current_Car_In_Same_Grid,1); % 变量Current_Car_In_Same_Grid存储着处于同一区域的智能设备编号
        Current_Device_Weight = Device_Weight(Current_Car_In_Same_Grid,1); % 获取智能设备的权重信息（可能出现权重为0的智能设备）
        
        for j = 1 : size(Current_Car_In_Same_Grid,1)
            temp_Current_Car_In_Same_Grid = Current_Car_In_Same_Grid;
            temp_Current_Device_Weight = Current_Device_Weight;
            Current_Car_Weight = temp_Current_Device_Weight(j,1);
            
            temp_Current_Device_Weight(j,:) = []; % 去除当前智能设备的权重以获取同区域内其他智能设备的权重
            temp_Current_Car_In_Same_Grid(j,:) = []; % 去除当前智能设备编号以获取同区域内其他智能设备的编号
            
            % 如果当前智能设备权重小于剩余智能设备权重的最大值，以1的概率广播数据包
            if(Current_Car_Weight < max(temp_Current_Device_Weight))
                temp_Transmitted_Packet = squeeze(Internal_Memory(:,:,Current_Car_In_Same_Grid(j,1)));
                temp_Transmitted_Packet = temp_Transmitted_Packet(find(temp_Transmitted_Packet(:,1) > 0),:);
                
                % 对于同区域内的其他智能设备需要接收数据包
                for k = 1 : size(temp_Current_Car_In_Same_Grid,1)
                    Packet_Buffer = squeeze(Internal_Memory(:,:,temp_Current_Car_In_Same_Grid(k,1)));
                    Packet_Buffer = Packet_Buffer(find(Packet_Buffer(:,1) > 0),:);
                    Packet_Buffer = [Packet_Buffer;temp_Transmitted_Packet]; % 将该智能设备原有数据包和接收到的数据包合并
                    % 如果所有数据包加起来仍然能存放在内存中，则简单地进行存放操作
                    if(size(Packet_Buffer,1) <= Car_Capacity)
                        Internal_Memory(1:size(Packet_Buffer,1),:,temp_Current_Car_In_Same_Grid(k,1)) = Packet_Buffer;
                    % 如果所有数据包加起来会使内存溢出，则需要计算数据包的权重
                    else
                        Packet_Weight = Calculate_Data_Packet_Weight(Packet_Buffer,Time_Slice); % 计算已有数据包和新接收数据包的权重
                        [~,L] = sort(Packet_Weight,'descend'); % 按权值从大到小排序
                        Internal_Memory(:,:,temp_Current_Car_In_Same_Grid(k,1)) = Packet_Buffer(L(1:Car_Capacity),:); % 更新当前智能设备内存
                    end
                end
                
            % 如果当前智能设备权重大于剩余智能设备权重的最大值，以式(4)所示概率广播数据包
            else
                possibility = max(temp_Current_Device_Weight) / Current_Car_Weight; % 计算广播数据包的概率
                dice = rand();
                % 根据概率计算结果需要广播数据包，步骤同上
                if(dice <= possibility)
                    temp_Transmitted_Packet = squeeze(Internal_Memory(:,:,Current_Car_In_Same_Grid(j,1)));
                    temp_Transmitted_Packet = temp_Transmitted_Packet(find(temp_Transmitted_Packet(:,1) > 0),:);
                
                    % 对于同区域内的其他智能设备需要接收数据包
                    for k = 1 : size(temp_Current_Car_In_Same_Grid,1)
                        Packet_Buffer = squeeze(Internal_Memory(:,:,temp_Current_Car_In_Same_Grid(k,1)));
                        Packet_Buffer = Packet_Buffer(find(Packet_Buffer(:,1) > 0),:);
                        Packet_Buffer = [Packet_Buffer;temp_Transmitted_Packet]; % 将该智能设备原有数据包和接收到的数据包合并
                        % 如果所有数据包加起来仍然能存放在内存中，则简单地进行存放操作
                        if(size(Packet_Buffer,1) <= Car_Capacity)
                            Internal_Memory(1:size(Packet_Buffer,1),:,temp_Current_Car_In_Same_Grid(k,1)) = Packet_Buffer;
                        % 如果所有数据包加起来会使内存溢出，则需要计算数据包的权重
                        else
                            Packet_Weight = Calculate_Data_Packet_Weight(Packet_Buffer,Time_Slice); % 计算已有数据包和新接收数据包的权重
                            [~,L] = sort(Packet_Weight,'descend'); % 按权值从大到小排序
                            Internal_Memory(:,:,temp_Current_Car_In_Same_Grid(k,1)) = Packet_Buffer(L(1:Car_Capacity),:); % 更新当前智能设备内存
                        end
                    end
                end
                % 否则不广播数据包
            end
        end
    end
    
    %---------------------%                                          (完成)
    %-实时模拟信息输出模块-%
    %---------------------%
    
    % 输出某个时间片的模拟信息
    fprintf('第%d个时间片：\n',Time_Slice);
    fprintf('1.共有%d个智能设备发生内存溢出.\n',Overflow_Count);
    fprintf('2.共有%d个智能设备向数据中心提交数据包.\n',Car_In_Data_Center);
    fprintf('3.共有%d个区域发生智能设备间的数据交换.\n',Number_of_Grids_With_Packet_Exchange);
    fprintf('4.当前数据中心共接收到%d个数据包.\n',size(Overall_Uploaded_Packet,1));
    % 保存模拟信息
    Summary_Matrix(Time_Slice,1) = Overflow_Count;
    Summary_Matrix(Time_Slice,2) = Car_In_Data_Center;
    Summary_Matrix(Time_Slice,3) = Number_of_Grids_With_Packet_Exchange;
    Summary_Matrix(Time_Slice,4) = size(Overall_Uploaded_Packet,1);
    toc;
    fprintf('\n');
    
    % 用于统计的变量清零
    Overflow_Count = 0; 
    Car_In_Data_Center = 0;
    Number_of_Grids_With_Packet_Exchange = 0;
end

