%   This function is used to calculate time difference between two different
% points. Notice that, generally, time_2 should be greater than time_1

function [day,hour,minute,second] = TimeDifference_Calculate( time_1, time_2 )

day = str2double(time_2(10)) - str2double(time_1(10));
hour = str2double(strcat(time_2(12),time_2(13))) - str2double(strcat(time_1(12),time_1(13)));
minute = str2double(strcat(time_2(15),time_2(16))) - str2double(strcat(time_1(15),time_1(16)));
second = str2double(strcat(time_2(18),time_2(19))) - str2double(strcat(time_1(18),time_1(19)));

end

