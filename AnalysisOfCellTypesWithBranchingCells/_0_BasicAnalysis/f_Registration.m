%% The task of the program is to perform image registration to take off
%% image movements from time point to time point
function [] = f_Registration(ImageFolder, ImFiles)
%% Opening the first image to serve as reference
FilePath = strcat(ImageFolder, ImFiles(1, 1).name);        
RefIm = load(FilePath); 
RefIm = RefIm.Image;            
% imshow(RefIm, []); 
% Save the first image as registered   
SaveFileName = ImFiles(1).name;     
RegIm = RefIm;      % To save images all with the same name
save([ImageFolder 'REG_' SaveFileName], 'RegIm');   

for i_Frame = 2:length(ImFiles)     % Loop on the image files to analyse
    close all;
    FilePath = strcat(ImageFolder, ImFiles(i_Frame).name);        
    Image = load(FilePath); 
    Image = Image.Image;            
%     imshow(Image, []); 

    [RegOut ResFT] = f_dftregistration(fft2(RefIm), fft2(Image), 10);
    RegIm = real(ifft2(ResFT));
%     figure, imshow(RegIm, []);
%     figure, imshow(RegIm - RefIm, []);
%     pause(0.1);
    % Save the registered image
    SaveFileName = ImFiles(i_Frame).name;          
    save([ImageFolder 'REG_' SaveFileName], 'RegIm');     
    
    RefIm = RegIm;      % Current image becomes reference image for the next round
end
