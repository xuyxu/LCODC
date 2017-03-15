Uploaded_Packet = [];

for i = 1 : size(new_Dataset,1)
    for j = 1 : size(new_Dataset{i,1}.Location,1)
        [x,y] = GridIndex_Calculate(new_Dataset{i,1}.Location(j,:));
        for k = 1 : size(centroids,1)
            if((x == centroids(k,1)) && (y == centroids(k,2)))
                if(j < 200)
                    temp_time_slice = (1:1:j)';
                    temp_Uploaded_Packet = [new_Dataset{i,1}.Location(1:j,:),temp_time_slice,ones(j,1) * i];
                    Uploaded_Packet = [Uploaded_Packet;temp_Uploaded_Packet];
                    break;
                else
                    temp_time_slice = (1:1:200)';
                    temp_Uploaded_Packet = [new_Dataset{i,1}.Location((j-199):j,:),temp_time_slice,ones(200,1) * i];
                    Uploaded_Packet = [Uploaded_Packet;temp_Uploaded_Packet];
                    break;
                end
            end
        end
    end
    fprintf('%ith mobile vehicle completed\n',i);
end