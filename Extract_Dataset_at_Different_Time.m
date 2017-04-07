count1 = 1;
count2 = 1;

for i = 1 : size(new_Dataset,1)
    for j = 1 : size(new_Dataset{i,1}.Location)
        temp_char = char(new_Dataset{i,1}.Time{j,1});
        temp_time = str2double(temp_char(1,12:13));
        
        if(temp_time >= 22 || temp_time <= 6)
            Night_Data{i,1}.Location(count1,:) = new_Dataset{i,1}.Location(j,:);
            count1 = count1 + 1;
        elseif(temp_time >= 8 && temp_time <= 20)
            Day_Data{i,1}.Location(count2,:) = new_Dataset{i,1}.Location(j,:);
            count2 = count2 + 1;
        end
    end
    count1 = 1;
    count2 = 1;
end
        