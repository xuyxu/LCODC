function [Weight] = Calculate_Data_Packet_Weight(Buffer, Current_Time_Slice)

k = 1000;
% Pre-allocate memory
Weight = zeros(size(Buffer,1),1);

% Calculate weights of data packets
% Weights of Newly generated data packets are Inf, i.e. they will not be discarded when they are generated
Weight(:,1) = (1 ./ Buffer(:,3)) + k * (1./ (Current_Time_Slice - Buffer(:,4)));

% Weight = rand(size(Buffer,1),1);

end

