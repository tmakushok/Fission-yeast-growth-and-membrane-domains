%% The task of the program is to perform image registration on a list of files
%% to take off movie shaking
% Inputs are: 
% 'ImageFolder': name of the folder containing images to be registered 
% 'ImFiles': list of names of image files (contained in 'ImageFolder')
function [Displ] = f_Reg_BF(ImageFolder, ImFiles)
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

Displ = zeros(size(ImFiles),2);
for i_Frame = 2:length(ImFiles)     % Loop on the image files to register
%     close all;
    % Opening current image to be registered according to the previous image
    FilePath = strcat(ImageFolder, ImFiles(i_Frame).name);        
    load(FilePath);     % The variable that is loaded is called 'Image'
%     imshow(Image, []); 

    % Using the registration function
    % output =  [error,diffphase,net_row_shift,net_col_shift]
    [Out ResFT] = f_dftregistration(fft2(RefIm), fft2(Image), 10);
    RegIm = real(ifft2(ResFT));
    Displ(i_Frame, :) = [Out(3), Out(4)];       % Will be used for fluo images

%     figure, imshow(RegIm, []);
%     figure, imshow(RegIm - RefIm, []);

    % Save the registered image
    SaveFileName = ImFiles(i_Frame).name;          
    save([ImageFolder 'REG_' SaveFileName], 'RegIm');     
    % Current image becomes reference image for the next execution of the loop
    RefIm = RegIm;      
end
