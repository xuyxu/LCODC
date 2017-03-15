%   This script is used to implement the first sub-scheme of LCODC:
% Deciding locations of data centers.

%%
% Step One: Obtain statistical matrix.
% 2001, 3463 are the number of grid along the X-axis, Y-axis seperately.
Statistical_Matrix = zeros(2050,3453);

% this variable is needed by severn-fold cross-validation method
day_set = [2,3,4,5,6,7];
% count = 1; % test only
error_char = '';
% maximum speed limitation is 80km/h
speed_limit = 80;

for i = 1 : size(new_Dataset,1)
    for j = 1 : size(new_Dataset{i,1}.Location,1)

        % check if current point fulfills the distance requirement
        if(j ~= 1)
            [day, hour, minute, second] = TimeDifference_Calculate(new_Dataset{i,1}.Time{j-1,1}, new_Dataset{i,1}.Time{j,1});
            real_distance = Distance_Calculate(new_Dataset{i,1}.Location(j-1,:), new_Dataset{i,1}.Location(j,:));
            total_hour = day * 24 + hour + (minute/60) + (second/3600);
            if(real_distance > (speed_limit * total_hour))
                continue;
            end
        end
        
        % check if current point fulfills the time requirement
        if(find(day_set,str2double(new_Dataset{i,1}.Time{j,1}(10))))
            [x,y] = GridIndex_Calculate(new_Dataset{i,1}.Location(j,:)); % obtain the index of grid
            
            % if the point is out of range, discard it
            if(x > 2050 || x < 1 || y > 3453 || y < 1) 
                continue;
            else
            % else, corresponding grid increase by one
                Statistical_Matrix(x,y) = Statistical_Matrix(x,y) + 1;
                % test only
                % t_x(count,1) = x;
                % t_y(count,1) = y;
                % count = count + 1;
            end
        end
    end
end

% completed successfully!
%%
%   Step Two: Decide locations of data centers according to statistical
% Matrix.
% load 'Filtered_Statistical_Matrix';
% 
% count = 1;
% 
% convert statistical matrix to feature vectors
% for i = 1 : size(Statistical_Matrix,1)
%     for j = 1 : size(Statistical_Matrix,2)
%         To accelerate clustering process, only grids with mobile nodes
%         passing by is used.
%         if(Statistical_Matrix(i,j) ~= 0)
%             x(count,1) = i;
%             x(count,2) = j;
%             y(count,1) = Statistical_Matrix(i,j);
%             count = count + 1;
%         end
%     end
% end

% k = 30; % the number of data centers
% [~,centroids] = kmeans(x',k);
% centroids = centroids';