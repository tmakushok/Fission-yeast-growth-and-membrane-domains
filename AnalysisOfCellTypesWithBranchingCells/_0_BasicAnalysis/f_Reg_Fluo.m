%% The task of the program is to perform image registration  
%% of fluo images files (to take off movie shaking)
%% according to the registration shift values obtained from 
%% registration of BF images
% Inputs are: 
% 'ImageFolder': name of the folder containing images to be registered 
% 'ImFiles': list of names of image files (contained in 'ImageFolder')
% 'Displ': the matrix containing shifts from the registration of BF images
%          First column is for row shifts, second is for column shifts
function [] = f_Reg_BF(ImageFolder, ImFiles, Displ)
%% Opening the first image to serve as reference for registering the second image
FilePath = strcat(ImageFolder, ImFiles(1, 1).name);        
RefIm = load(FilePath); 
RefIm = RefIm.Image;            
% imshow(RefIm, []); 

% Save the first image as first registered image (even though it was not registered)
% The image is saved with the same name that it had before, just 'REG_' is
% added at the beginning of the file name
SaveFileName = ImFiles(1).name;     
RegIm = RefIm;      % Renaming the variable, just to save images all with the same name
save([ImageFolder 'REG_' SaveFileName], 'RegIm');   

for i_Frame = 2:length(ImFiles)     % Loop on the image files to register
    close all;
    % Opening current image to be registered according to the previous image
    FilePath = strcat(ImageFolder, ImFiles(i_Frame).name);        
    load(FilePath);     % The variable that is loaded is called 'Image'
    
    RegIm = Image;      % Initial initialisation of the RegIm
    
%     figure, imshow(Image, []); 
%     figure, imshow(RefIm1, []);
%% Vertical shifting    
    CorrRow = round(Displ(i_Frame, 1));     % Round the correction to a pixel
    Vert = abs(CorrRow);
    if CorrRow >= 1
        % Insert rows
        RegIm = [zeros(Vert, size(RegIm, 2)); RegIm(1:size(RegIm, 2) - Vert, :)];    
    end
    if CorrRow <= -1
        % Delete rows
        RegIm = [RegIm(Vert + 1:size(RegIm, 1), :); zeros(Vert, size(RegIm, 2))];        
    end
%% Horisontal shifting     
    CorrCol = round(Displ(i_Frame, 2));     % Round the correction to a pixel
    Horis = abs(CorrCol);
    if CorrCol >= 1
        % Add columns
        RegIm = [zeros(size(RegIm, 1), Horis), RegIm(:, 1:size(RegIm, 2) - Horis)];
    end
    if CorrCol <= -1       
        % Delete columns
        RegIm = [RegIm(:, Horis + 1:size(RegIm, 2)), zeros(size(RegIm, 1), Horis)];
    end
    figure, imshow(RegIm, []);
    figure, imshow(RefIm, []);
%% Save the registered image
    SaveFileName = ImFiles(i_Frame).name;          
    save([ImageFolder 'REG_' SaveFileName], 'RegIm');     
end
