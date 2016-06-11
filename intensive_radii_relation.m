function intensive_radii_relation(item_no,item_radii,radii,instances)

% INTENSIVE_RADII_RELATION Constructing the relationship between ISA, Spacing, and the Radius of the enveloping circle (highest frequency relationship; using median, not mean).
%
% intensive_radii_relation(item_no,item_radii,radii,instances)
% will generate and save the relation between the most frequent Spacing of a stimulus bounded by a circle
% of the given 'radii', which has 'item_no' items with the given
% 'item_radii'.

%item_no = 2:1:3; % n
%item_radii = 30:10:60; % Radius of items
item_surf = pi.*(item_radii).^2; % ISA
%radii = 100:20:200; % Radius of the enveloping circle
%instances = 500; % The no. of times stimuli are to be generated in generating the distribution of Spacing wrt n, ISA, and R.
min_space = 5; % Minimum space between the stimuli
interpolate_no = 1000;

spacing_med = zeros(length(item_no),length(item_radii),length(radii));
spacing_std = zeros(length(item_no),length(item_radii),length(radii));

for i = 1:length(item_no) % Calculation involving a function which computes multiple Field Areas given n, R, instances, item radius and minimum distance.
    for j = 1:length(item_radii)
        for k = 1:length(radii)
            [field_area,flag,counter_end] = field_area_calc(item_no(1,i),radii(1,k),instances,item_radii(1,j),min_space);
            if flag == 1
                if counter_end > 0
                    spacing_med(i,j,k) = median(field_area(1:counter_end))/item_no(i) - item_surf(j);
                    spacing_std(i,j,k) = std(field_area(1:counter_end)./item_no(i) - item_surf(j));
                else
                    spacing_med(i,j,k) = NaN;
                    spacing_std(i,j,k) = NaN;
                end
            else
                spacing_med(i,j,k) = median(field_area)/item_no(i) - item_surf(j); % to associate the highest frequency of spacing with i,j,k
                spacing_std(i,j,k) = std(field_area./item_no(i) - item_surf(j));
            end
        end
        if mod(j,10) == 0 % Outputting the progress
            i,j
        end
    end
end

radii_ex = linspace(min(radii),max(radii),interpolate_no);
item_surf_ex = linspace(min(item_surf),max(item_surf),interpolate_no);
spacing_med1 = zeros(length(item_no),length(item_surf_ex),length(radii_ex));
spacing_std1 = zeros(length(item_no),length(item_surf_ex),length(radii_ex));

for i = 1:length(item_no) % Interpolate the data to 'interpolate_no' number of points.
    spacing_matrix = squeeze(spacing_med(i,:,:));
    spacing_std_matrix = squeeze(spacing_std(i,:,:));
    [X,Y] = meshgrid(radii,item_surf);
    [Xex,Yex] = meshgrid(radii_ex,item_surf_ex);
    spacing_matrix_ex = interp2(X,Y,spacing_matrix,Xex,Yex);
    spacing_matrix_std_ex = interp2(X,Y,spacing_std_matrix,Xex,Yex);
    spacing_med1(i,:,:) = spacing_matrix_ex;
    spacing_std1(i,:,:) = spacing_matrix_std_ex;
end

spacing_med = spacing_med1;
spacing_std = spacing_std1;
item_surf = item_surf_ex;
radii = radii_ex;

% figure;
% mesh(radii,item_surf,squeeze(sparsity_avg(3,:,:)))

save('../data/intensive_radii_func.mat','item_no','item_surf_ex','radii_ex','spacing_med','spacing_std') % Save the data required for stimulus generation
end
