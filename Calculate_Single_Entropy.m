Grid_Entropy = zeros(2050,3453);

for i = 1 : size(result,1)
    for j = 1 : size(result,2)
        temp = result{i,j};
        T = sum(temp(2,:));
        for k = 1 : size(temp,2)
            if(temp(1,k)~= 0)
                Grid_Entropy(i,j) = Grid_Entropy(i,j) + (-(temp(2,k)/T)*log2(-(temp(2,k)/T)));
            end
        end
    end
end
        