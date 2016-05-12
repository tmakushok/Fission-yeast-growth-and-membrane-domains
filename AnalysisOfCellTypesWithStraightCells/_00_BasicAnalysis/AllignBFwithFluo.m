close all

% File = ImFiles(i_File).name;
BrFieldIm = load('_InputImages/REG_BF_AVG_Series004_gfptna1_t014.mat');
BrFieldIm = BrFieldIm.RegIm;
% imshow(BrFieldIm, []);
% Open fluo projection image
% FileFl = regexprep(File, 'REG_BF_AVG_', 'REG_AVG_');
FluoImage = load('_InputImages/REG_AVG_Series004_gfptna1_t014.mat');
FluoImage = FluoImage.RegIm;
% figure, imshow(FluoImage, []);

% Reconstruction of the image from three separate colours images
RegIm(:,:,1) = BrFieldIm;
RegIm(:,:,2) = FluoImage;
RegIm(:,:,3) = FluoImage;
RegIm(find(RegIm < 0)) = 0;
RegIm(:,:,1) = RegIm(:,:,1) / max(max(RegIm(:,:,1)));
RegIm(:,:,2) = RegIm(:,:,2) / max(max(RegIm(:,:,2)));
RegIm(:,:,3) = RegIm(:,:,3) / max(max(RegIm(:,:,3)));

figure, imshow(RegIm, []);

%% Cut the fluo image to have BF overlapping with the fluo
% Add columns
Horis = 2;
FluoImage = [zeros(size(FluoImage, 1), Horis), FluoImage(:, 1:size(FluoImage, 2) - Horis)];
% Delete columns
% Horis = 2;
% FluoImage = [FluoImage(:, Horis + 1:size(FluoImage, 2)), zeros(size(FluoImage, 1), Horis)];
% % Delete rows
% Vert = 4;
% FluoImage = [FluoImage(Vert + 1:size(FluoImage, 1), :); zeros(Vert, size(FluoImage, 2))];
% Insert rows
% Vert = 1;
% FluoImage = [zeros(Vert, size(FluoImage, 2)); FluoImage(1:size(FluoImage, 2) - Vert, :)];

% Reconstruction of the image from three separate colours images
RegIm(:,:,1) = BrFieldIm;
RegIm(:,:,2) = FluoImage;
RegIm(:,:,3) = FluoImage;
RegIm(find(RegIm < 0)) = 0;
RegIm(:,:,1) = RegIm(:,:,1) / max(max(RegIm(:,:,1)));
RegIm(:,:,2) = RegIm(:,:,2) / max(max(RegIm(:,:,2)));
RegIm(:,:,3) = RegIm(:,:,3) / max(max(RegIm(:,:,3)));

figure, imshow(RegIm, []);    
    
    
    
    
    
    
    
    
    