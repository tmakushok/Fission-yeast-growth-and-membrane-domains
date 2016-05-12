%% The task of the program is to create average Z-projections 
%% from SP5 microscope z-stack movie images
clear;
%-------------------------
Dir = '_InputImages/';
% SlicesTotal = 19;
% PlanesPlus = 4;     % How many planes up and down from the middle plane are going to be projected
%-------------------------
load('_Output/AllMiddlePlanes_NbSlices.mat');      % To get middle positions for all times and number of Z-slices
Files = dir([Dir '*.tif']);
% Size of each image
FileName = [Dir Files(1).name];     
ImageRGB = double(imread(FileName)); 
Image = ImageRGB(:,:,2);      % To extract green layer from RGB image
s_Im = size(Image);    

for i_t = 0:length(Files) / SlicesTotal - 1         % Loop on time points of the movie
    close all;
%% Do projection
%     MiddlePlane = MidPlanesAll(i_t + 1);
%     Image = zeros(s_Im);
%     for i_2Proj = MiddlePlane - PlanesPlus : MiddlePlane + PlanesPlus
%         Image = Image + Image1;
    FileName = [Dir Files(i_t * SlicesTotal + 1).name];     
    InitImage = double(imread(FileName)); 
%     Image1 = InitImageRGB;      % To extract green layer from RGB
%     MaxProj = InitImage;      % Initialisation with the first z-slice
    SumProj = InitImage(:,:,2); 
    for i = 2:SlicesTotal
        FileName = [Dir Files(i_t * SlicesTotal + i).name];     
        InitImage = double(imread(FileName)); 
        InitImage = InitImage(:,:,2);
%         MaxProj = max(MaxProj, InitImage);
        SumProj = SumProj + InitImage;
    end  
    Image = SumProj / SlicesTotal;
%     imshow(MaxProj, []);
%     imshow(AverProj, []);
%     end
%     Image = Image / (PlanesPlus * 2 + 1);    
%     figure, imshow(Image, []);
%% Save the image
    SaveFileName = Files(i_t * SlicesTotal + 1).name;
    [start] = regexp(SaveFileName, '_z');    
    SaveFileName = SaveFileName(1:start - 1);         
    save([Dir 'AVG_' SaveFileName '.mat'], 'Image'); 
end





