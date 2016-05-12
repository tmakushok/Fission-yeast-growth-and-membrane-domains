%% The task of the program is to create average Z-projections 
%% of fluorescent images (to extract intensities from afterwards). 

%% Projections are done in the range
%% MiddlePlane - PlanesPlus : MiddlePlane + PlanesPlus
%% where 'PlanesPlus' is a constant that shows how many planes below and
%% above the middle plane are to be projected.

%% The value of 'MiddlePlane' comes from the function 'Step02_BF_Proj' 
%% that performs projections of bright-field images and to do that it finds
%% position of the middle plane for each stack.

%% Planes that were considered as going out of focus starting from some time in the movie
%% by the function 'Step02_BF_Proj' are not even considered in this program

clear;
%-------------------------
Dir = '_InputImages/';      % Folder with fluorescent images
PlanesPlus = 3;     % How many planes up and down from the middle plane are going to be projected
%-------------------------
load('_Output/AllMiddlePlanes_NbSlices.mat');      % To get middle positions for all times and number of Z-slices

%% !!! The difference between the middle planes for fluorescence stack and
%% the BF stack is 2 planes
MidPlanesAll = MidPlanesAll - 2;

Files = dir([Dir '*.tif']);
%% Finding the size of images (to initialise the matrix 'Image' later)
% Opening the first fluorescent image
FileName = [Dir Files(1).name];     
Image = double(imread(FileName)); 
Image = Image(:,:,2);      % To extract green layer from RGB image
% Measuring the size of the image opened
s_Im = size(Image);    
%% Do projections for every time point: middle plane plus several adjacent planes
for i_t = 0:length(MidPlanesAll) - 1         % Loop on time points of the movie                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            0:length(MidPlanesAll) - 1         % Loop on time points of the movie
    close all;
%% Do projection close to the middle plane
    MiddlePlane = MidPlanesAll(i_t + 1);
    Image = zeros(s_Im);    % Instead of the initialisation with zeros 
                            % it is possible to initialise this image with one of the z-plane images
    for i_2Proj = max(0, MiddlePlane - PlanesPlus) : min(SlicesTotal, MiddlePlane + PlanesPlus)    % Here the range of images used for projection is defined    
        % Opening current image
        FileName = [Dir Files(i_t * SlicesTotal + i_2Proj).name]     
        Image1 = double(imread(FileName)); 
        Image1 = Image1(:,:,2);      % To extract green layer from RGB image
        % Performing sum projection of the current plane with the
        % accumulated projection image
        Image = Image + Image1;
    end
    Image = Image / (PlanesPlus * 2 + 1);   % Creating average projection from sum projection 
%     figure, imshow(Image, []);
%% Save the image
    % Here zeros are not added in front of the file number (like '003' instead of '3')
    % because initial file names already contain necessary zeros.
    SaveFileName = Files(i_t * SlicesTotal + 1).name;
    [start] = regexp(SaveFileName, '_z');    
    SaveFileName = SaveFileName(1:start - 1);       % Only piece of initial file name is used to save the projection      
    save([Dir 'AVG_' SaveFileName '.mat'], 'Image'); 
end





