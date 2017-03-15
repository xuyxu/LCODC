% 预分配内存
for i = 1 : 2050
    for j = 1 : 3453
        result{i,j} = zeros(2,1);
    end
end
fprintf('pre-allocate memory finished!\n');

% 为每个网格构建记录列表
for i = 1 : size(new_Dataset,1)
    for j = 1 : size(new_Dataset{i,1}.Location,1)
      [x, y] = GridIndex_Calculate(new_Dataset{i,1}.Location(j,:));
      
      if(x == 0)
          x = 1;
      end
      
      if(y == 0)
          y = 1;
      end
      
      temp = find(result{x,y}(1,:),i);
      if(isempty(temp))
          result{x,y}(1,end+1) = i;
          result{x,y}(2,end+1) = 1;
      else
          result{x,y}(2,temp) = result{x,y}(2,temp) + 1;
      end
    end
end
      