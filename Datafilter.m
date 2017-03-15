count = 1;
for i = 1 : size(Dataset,1)
    for j = 1 : size(Dataset{i,1}.Location,1)
        if((Dataset{i,1}.Location(j,1) < 117.4) && (Dataset{i,1}.Location(j,1) > 115.7) && (Dataset{i,1}.Location(j,2) <41.6) && (Dataset{i,1}.Location(j,2) > 39.4))
            new_Dataset{i,1}.Location(count,:) = Dataset{i,1}.Location(j,:);
            new_Dataset{i,1}.Time{count,1} = Dataset{i,1}.Time{j,1};
            count = count + 1;
        end
    end
    count = 1;
end