error_char = '';
count = 1;
for i = 1 : size(new_Dataset,1)
    for j = 1 : size(new_Dataset{i,1}.Time,1)
        if(new_Dataset{i,1}.Time{j,1}(10) == error_char || new_Dataset{i,1}.Time{j,1}(10) == '&')
            error_list(count,1) = i;
            error_list(count,2) = j;
            count = count + 1;
        end
    end
end

% completed!