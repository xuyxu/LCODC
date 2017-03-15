function Result_Analysis(Overall_Uploaded_Packet)
Time_Delay = Overall_Uploaded_Packet(:,6) - Overall_Uploaded_Packet(:,4);
Average_Time_Delay = sum(Time_Delay) / size(Time_Delay,1);
Average_Time_Delay = Average_Time_Delay / 60;

Car_List = unique(Overall_Uploaded_Packet(:,5));

Grid = unique(Overall_Uploaded_Packet(:,1:2),'rows');

fprintf('1.共收集到了%d个数据包\n',size(Overall_Uploaded_Packet,1));
fprintf('2,数据包的平均延迟为%f小时\n',Average_Time_Delay);
fprintf('3.共有来自%d个不同智能设备所采集的数据包\n',size(Car_List,1));
fprintf('4.共有来自%d个不同网格的数据包\n',size(Grid,1));


end

