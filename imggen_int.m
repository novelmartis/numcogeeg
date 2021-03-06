function imggen_int(n,isa,spacing,threshold,resolution,display_img,save_img)

% IMGGEN_INT Generate the stimulus given a ISA and Spacing, display it, and
% save it. load the .mat file generated by intensive_radii_relation.m before 
% running this function
%
% Of the stimulus:
% n is the numerosity
% isa is the Item Surface Area
% spacing is the Spacing
% threshold is the maximum absolute eroor tolerated in the generated
% Spacing
% resolution is the resolution of the screen
% set display_img to 1 if you want to see the image, else 0
% set save_img to 1 if you want to save the image, else 0

%load data/intensive_radii_func.mat % Load the 4D relation matrix

% n = 9; % Numerosity
% isa = 15000; % ISA
% spacing = 30000; % Spacing
% threshold = 10; % Maximum absolute error in generated Spacing
% resolution = [1920 1080];

stimuli_inst = stimgen_int(n,isa,spacing,threshold,resolution(2)/2,spacing_med,item_surf_ex,radii_ex);
% Generate the coordinates

imager = zeros(resolution(2),resolution(1),3);

coords = zeros(2,n);
coords(1,:) = stimuli_inst.coord(1,:).*cos(stimuli_inst.coord(2,:))+resolution(1)/2;
coords(2,:) = stimuli_inst.coord(1,:).*sin(stimuli_inst.coord(2,:))+resolution(2)/2;
coords = coords.';
coords(:,3) = ((stimuli_inst.isa)/pi)^0.5.*ones(n,1); % Draw the circles

RGB = insertShape(imager, 'FilledCircle', coords, 'Color', 'red');
if display_img == 1
    imshow(RGB) % Show stimulus
end
if save_img == 1
    imwrite(RGB,'myimage2.png') % Save stimulus
end

end
