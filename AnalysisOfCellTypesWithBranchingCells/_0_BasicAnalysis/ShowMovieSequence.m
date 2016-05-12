%% The task of the program is to correct for stage movements during movie
%% acquisition: moving movie frames one in respect to another (first one stays 'unmoved')

% clear;      % To erase variables that are in memory
% close all;
%--------------------------------------------------------------------------
%!!!--!!! File names
ImageFolder = '_InputImages/';
%--------------------------------------------------------------------------
figure;
ImFiles = dir([ImageFolder, 'REG_BF_AVG_*.mat']);   % Obtaining the list of files corresponding to what we want to analyse
for i_Frame = 1:length(ImFiles)     % Loop on the image files to analyse, without the first image that served for the selection of the object for correction           
    FilePath = strcat(ImageFolder, ImFiles(i_Frame, 1).name);        
    InitImage = load(FilePath); 
    InitImage = InitImage.RegIm;            
    imshow(InitImage, []);
    F1(i_Frame) = getframe;
%     pause(0.1);
end
movie(F1, 1200);

figure;
ImFiles = dir([ImageFolder, 'BF_AVG_*.mat']);   % Obtaining the list of files corresponding to what we want to analyse
for i_Frame = 1:length(ImFiles)     % Loop on the image files to analyse, without the first image that served for the selection of the object for correction           
    FilePath = strcat(ImageFolder, ImFiles(i_Frame, 1).name);        
    InitImage = load(FilePath); 
    InitImage = uint8(InitImage.Image);            
    imshow(InitImage, []);
    F2(i_Frame) = getframe;
    pause(0.1);
end
h = figure();
movie(h, F2, 12);
 

