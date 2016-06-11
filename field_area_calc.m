function [field_area,flag1,counter_end] = field_area_calc(n,radius,instances,sizer,dist_min)

% field_area_calc Compute the field areas of numerosity stimuli
% given an enveloping circle.
%
% [field_area,flag] = field_area_calc(n,radius,instances,sizer,dist_min)
% will return 'instances' number of field areas (convex hulls) of multiple stimuli
% generated given the constraints. If the constraints are contradictory, it
% will return flag1 = 1, else 0. counter_end is the number of instances
% processed before exiting with flag1 = 1.
%
% n is the number of stimuli on the image
% radius is the radius of the enveloping circle
% instances is the number of images to be generated for avergaing
% sizer is the radius of stimuli
% dist_min is the minimum distance between each stimuli

% radius = 17; % radius of enclosing circle
% instances = 5000; % number of stimuli to be generated
points = 16; % no. of points to be created on each circle (full convex hull)
% n = 9; % no. of stimuli
% sizer = 5; % item size radius
field_area = zeros(instances,1); % field areas
% dist_min = 0; % min distance between the two circles
thr = 300000;

flag1 = 0;
for i = 1:instances
    centres_r = zeros(n,1);
    centres_t = zeros(n,1);
    coords = zeros(2,points*n);
    count = 0;
    counters = 0;
    while count <= n
        if count == 0
            centres_r(1,1) = (radius-sizer)*rand(1);
            centres_t(1,1) = 2*pi*rand(1);
            count = count + 1;
        else
            flag = 0;
            while flag <= count
                centres_r(count+1,1) = (radius-sizer)*rand(1);
                centres_t(count+1,1) = 2*pi*rand(1);
                for j = 1:count
                    measure = ((centres_r(count+1,1)*cos(centres_t(count+1,1)) - centres_r(j,1)*cos(centres_t(j,1)))^2+(centres_r(count+1,1)*sin(centres_t(count+1,1)) - centres_r(j,1)*sin(centres_t(j,1)))^2)^0.5;
                    if measure > 2*sizer+dist_min
                        flag = flag + 1;
                    end
                end
                if flag == count
                    count = count + 1;
                else
                    counters = counters + 1;
                end
                if counters > instances*thr
                    flag1 = 1;
                    break
                end
            end
            if flag1 == 1
                break
            end
        end
        if flag1 == 1
            break
        end
    end
    if flag1 == 1
        counter_end = i-1;
        break
    end
    coords_x = sizer.*cos(0:2*pi/points:2*pi-2*pi/points);
    coords_y = sizer.*sin(0:2*pi/points:2*pi-2*pi/points);
    for k = 1:n
        coords(1,points*(k-1)+1:points*(k)) = coords_x + centres_r(k,1)*cos(centres_t(k,1));
        coords(2,points*(k-1)+1:points*(k)) = coords_y + centres_r(k,1)*sin(centres_t(k,1));
    end
    pointers = convhull(coords(1,:),coords(2,:));
    field_area(i,1) = polyarea(coords(1,pointers),coords(2,pointers));
    %i
end

%figure;
%hist(log(field_area),100)
end