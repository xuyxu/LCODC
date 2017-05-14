tic;
Device_Weight = zeros(size(new_Dataset,1),1); % Pre-allocate memory

Maximum_Distance = 1; % reception radius of data centers
t_weight = 0;

for i = 1 : size(new_Dataset,1)
    
    [x_temp,y_temp] = GridIndex_Calculate(new_Dataset{i,1}.Location);
    
    for j = 1 : size(centroids,1)
        temp = abs(x_temp-centroids(j,1)) + abs(y_temp-centroids(j,2)); % calculate its Manhattan distance to the ith data center
        t_weight = t_weight + size(find(temp <= Maximum_Distance),1);
    end
    
    Device_Weight(i,1) = t_weight;
    t_weight = 0;
        
end
toc;
