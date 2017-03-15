function d = Distance_Calculate(point1, point2)
% Result Unit: kilometer

longitude1 = point1(:,1);
latitude1 = point1(:,2);
longitude2 = point2(:,1);
latitude2 = point2(:,2);

d = sqrt((abs(longitude1-longitude2)*85.276) .^ 2 + (abs(latitude1-latitude2) *  111) .^ 2);