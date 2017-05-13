% 1.This .m is used to construct dataset according to original txt files.
% 2.Make sure all txt files has be placed at the same folder.
% 3.You will obtain a dataset which contains 8911 structs, with each struct
%   corresponds to one taxi.
% 4.The structure of each struct is shown as follows:
%   TaxiID   -- taxi id
%   Time     -- all time records
%   Location -- [longitude, latitude]
% 5. It may take a while to finish constructing.

% Yixuan Xu, Central South University, 2016/9/24.

% replace with your personal path
path = 'D:\Dataset\';
% obtain all files' information
FileName = dir(strcat(path,'*.txt'));
for i=1:size(FileName,1)
    temp = importdata(strcat(path,FileName(i).name));
    % '10115.txt' is null :-)
    if(~isempty(temp))
        % taxi ID
        Taxi.TaxiID = temp.colheaders{1,1};
        % time
        for j=1:size(temp.data,1)
            Taxi.Time{j,1} = temp.textdata{j,2};
        end
        % longitude latitude
        Taxi.Location = temp.data;
        
        Dataset{i,1} = Taxi;
    else
        i = i-1;
    end
    % avoid data overlapping
    clear temp;
    clear Taxi;
end
