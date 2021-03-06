function stimuli_inst = stimgen_int(n,isa,spacing,threshold,res,spacing_med,item_surf_ex,radii_ex)

% STIMGEN_INT Generate the polar coordinates for random circular numerosity
% stimulus given the intrinsic variable constraints. load the .mat file
% generated by intensive_radii_relation.m before running this function
%
% stimuli = stimgen_int(n,T,isa,spacing,threshold)
% will return a 2d array with the polar coordinates of the corresponding stimuli.
%
% n is the number of items to be displayed in the stimulus
% isa is the Item Surface Area 
% spacing is the Spacing
% threshold is the error tolerated in the Spacing of the stimuli
% res sets the maximum radius of the enveloping circle to ensure that the stimulus doesn't spill outside the screen.
% spacing_med,item_surf_ex,radii_ex will come from the loaded .mat file

interpolate_no = 1000; % Resolution of the Radii vs ISA vs Sparsity function.
space = 5; % Minimum distance between two stimuli
points = 16; % no. of points to be created on each circle (full convex hull)
%threshold = 10;

%load data/intensive_radii_func.mat % load the Radii vs ISA vs Sparsity function data

spacing_matrix = squeeze(spacing_med(n,:,:)); % Extract the radii of the circle corresponding to the ISA and Spacing.
[~,ind_it] = min((item_surf_ex-isa).^2);
[~,ind_ra] = min((spacing_matrix(ind_it,:)-spacing).^2);
stim_radii = radii_ex(ind_ra);

diff_s = 1000; % initialisation for thresholding
it_count = 0;
while (diff_s^2)^0.5 > threshold
    if it_count > 500000
        error('Stimuli generation taking too long')
    end
    coords = zeros(2,n);
    s_trial = (isa/pi)^0.5;
    %r_trial = stim_radii + 1*floor(it_count/1000)^0.5*(mod(floor(it_count/1000),3)-1); % To change envelope radius if the search is stuck
    %         r_trial = 1080;
    r_trial = stim_radii;
    if r_trial > res
        r_trial = res;
    end
    sp_trial = spacing;
    count = 0;
    missed = 0;
    flagged = 0;
    while count < n
        coords(1,count+1) = (r_trial-s_trial)*rand(1);
        coords(2,count+1) = 2*pi*rand(1);
        if count == 0
            count = count + 1;
        else
            flag = 0;
            for j = 1:count
                dist_j = ((coords(1,j)*cos(coords(1,j))-coords(1,count+1)*cos(coords(1,count+1)))^2 + (coords(1,j)*sin(coords(1,j))-coords(1,count+1)*sin(coords(1,count+1)))^2)^0.5;
                if dist_j > 2*s_trial+space
                    flag = flag + 1;
                end
            end
            if flag == count
                count = count + 1;
            else
                missed = missed + 1;
            end
        end
        if missed > 1000
            flagged = 1;
            break
        end
    end
    stimuli_inst.coord = coords;
    coords1 = zeros(2,points*n);
    coords_x = s_trial.*cos(0:2*pi/points:2*pi-2*pi/points);
    coords_y = s_trial.*sin(0:2*pi/points:2*pi-2*pi/points);
    for k = 1:n
        coords1(1,points*(k-1)+1:points*(k)) = coords_x + coords(1,k)*cos(coords(2,k));
        coords1(2,points*(k-1)+1:points*(k)) = coords_y + coords(1,k)*sin(coords(2,k));
    end
    pointers = convhull(coords1(1,:),coords1(2,:));
    sparsity_i = polyarea(coords1(1,pointers),coords1(2,pointers))/n;
    spacing_i = sparsity_i - isa;
    diff_s = spacing_i - sp_trial;
    if flagged == 1
        diff_s = 1000;
    end
    coords2(1,:) = coords(1,:).*cos(coords(2,:));
    coords2(2,:) = coords(1,:).*sin(coords(2,:));
    dist_h = pdist(coords2.','euclidean'); % Sanity check to make sure that there is not overlap
    if min(dist_h) <= 2*s_trial+space
        diff_s = 1000;
    end
    stimuli_inst.spacing_o = spacing_i;
    stimuli_inst.spacing_e = spacing;
    stimuli_inst.spacing_rel_error_percent = (spacing_i-spacing)/spacing*100;
    stimuli_inst.isa = isa;
    stimuli_inst.radii = stim_radii;
    it_count = it_count + 1;
end
it_count

%save ('stimuli.mat','stimuli_inst')

end
