%% The task of the program is to correct for stage movements during movie
%% acquisition: moving movie frames one in respect to another (first one stays 'unmoved')

% clear;      % To erase variables that are in memory
% close all;
%--------------------------------------------------------------------------
%!!!--!!! File names
ImageFolder = '_InputImages/';
%--------------------------------------------------------------------------
figure;
ImFiles = dir([ImageFolder, 'REG_AVG_*.mat']);   % Obtaining the list of files
for i_Frame = 1:length(ImFiles)     % Loop on the image files to show
    FilePath = strcat(ImageFolder, ImFiles(i_Frame, 1).name);        
    InitImage = load(FilePath); 
    InitImage = InitImage.RegIm;            
    imshow(InitImage, []);
    F1(i_Frame) = getframe;    
end
movie(F1, 12);

figure;
ImFiles = dir([ImageFolder, 'BF_AVG_*.mat']);   % Obtaining the list of files
for i_Frame = 1:length(ImFiles)     % Loop on the image files to show
    FilePath = strcat(ImageFolder, ImFiles(i_Frame, 1).name);        
    InitImage = load(FilePath); 
    InitImage = InitImage.Image;            
    imshow(InitImage, []);
    F2(i_Frame) = getframe;    
end
movie(F2, 12);


