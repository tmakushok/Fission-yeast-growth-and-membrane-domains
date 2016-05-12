%% The task of the program is to create BF image that can be used to detect
%% cell borders (this involves finding cell central Z-slice 
%% and making projection of some slices close to cell middle

%% To find Z-middle of the cell histograms of image intensity are analysed:
%% middle slice corresponds to the most bottom (narrow) histogram
%% in the region close to middle strong peak

%% The same function performs control if the field of view does not go out
%% of Z-range (on the global level, not single-cell level: 
%% if middle plane is not too close to the borders of Z-range). If goes out
%% of Z-range, the subsequent analysis of the movie is stopped at that plane.

close all
clear;
%--------------------------------------------------------------------------
Directory = '_InputImages/BrightFieldImages/';
DirImOut = '_InputImages/';       % To output projection images
DirOut = '_Output/';
Nbins = 100;    % Nb of bins for histograms    
ZPlus = 1;      % Number of Z-slices up and down from the middle slice for the projection
%--------------------------------------------------------------------------
% %% Determining the number of z-slices in the movie: 'SlicesTotal'
SliceNbOld = -1;
SlicesTotal = 0;
Files = dir([Directory '*.tif']);
for i_File = 1:length(Files) 
    FileName = [Directory, Files(i_File).name];   
    % Extracting number of the slice
    [start1 a_end1] = regexp(FileName, '_z');
    [start2 a_end2] = regexp(FileName, '_ch'); 
    if isempty(start2)
        continue
    end
    SliceNbStr = FileName(a_end1 + 1:start2 - 1);
    SliceNb = str2double(SliceNbStr);
    
    if SliceNb < SliceNbOld
        break
    end
    SliceNbOld = SliceNb;
    SlicesTotal = SlicesTotal + 1;
end

% load('_Output/AllMiddlePlanes_NbSlices.mat');      % To get middle positions for all times and number of Z-slices

TimePts = length(Files) / SlicesTotal;
MidPlanesAll = zeros(TimePts, 1);

for i_t = 0:TimePts - 1         % Loop on time points of the movie
    close all;
%% Collecting whole_image intensity histograms for images of a stack
%     for i_Slice = (floor((SlicesTotal) / 2) - ZPlus) + 2 : (floor((SlicesTotal) / 2) + ZPlus) + 2   % '+2' comes from files '.' and '..' 
    NhistAll = zeros(SlicesTotal, Nbins);
    for i_Slice = 1:SlicesTotal
        i_File = i_t * SlicesTotal + i_Slice;
        FileName = [Directory Files(i_File).name] 
        InitImageRGB = double(imread(FileName)); 
        InitImage = InitImageRGB(:,:,1);      % To extract one layer from RGB image
%         figure, imshow(InitImage, []);
        
        ImInLine = reshape(InitImage, 1, size(InitImage, 1) * size(InitImage, 2));
        [Nhist, Xhist] = hist(ImInLine, Nbins);
%         figure, bar(Xhist, Nhist);
        
        NhistAll(i_Slice,:) = Nhist;    % Each line corresponds to one image of the stack
        XhistAll(i_Slice,:) = Xhist;           
    end
%% Analysing collected histograms to find the most bottom one (at outer regions)
%% that corresponds to the BF image taken axactly at the middle of the cell
    MiddlePlane = f_FindMiddlePlane(XhistAll, NhistAll);
    if abs(MiddlePlane - MidPlOld) > 1
        MiddlePlane
    end
    MidPlOld = MiddlePlane;
%% Control if the field of view does not go out of Z-range 
%     if (MiddlePlane - 2 < 1) || (MiddlePlane + 3 > SlicesTotal)
%         break
%     end
    MidPlanesAll(i_t + 1) = MiddlePlane;
%     MiddlePlane = MidPlanesAll(i_t + 1);       % Save position of the middle plane for fluo projections
    % Show the middle plane image
%     i_File = i_t * SlicesTotal + MiddlePlane;
%     FileName = [Directory Files(i_File).name]
%     InitImageRGB = double(imread(FileName)); 
%     InitImage = InitImageRGB(:,:,1);      % To extract one layer from RGB image
%     figure, imshow(InitImage, []);
%     % Ask the user to confirm by pressing Enter
%     input('Please press Enter :-)');
%% Do projection close to the middle plane
    FileName = [Directory Files(i_t * SlicesTotal + max(MiddlePlane - 5, 1)).name];     
    InitImageRGB = double(imread(FileName)); 
    Image1 = InitImageRGB(:,:,1);      % To extract one layer from RGB image
    
    FileName = [Directory Files(i_t * SlicesTotal + max(MiddlePlane - 4, 1)).name]; 
    InitImageRGB = double(imread(FileName)); 
    Image2 = InitImageRGB(:,:,1);      % To extract one layer from RGB image
    
    FileName = [Directory Files(i_t * SlicesTotal + max(MiddlePlane - 3, 1)).name]; 
    InitImageRGB = double(imread(FileName)); 
    Image3 = InitImageRGB(:,:,1);      % To extract one layer from RGB image
    
    FileName = [Directory Files(i_t * SlicesTotal + max(MiddlePlane - 6, 1)).name]; 
    InitImageRGB = double(imread(FileName)); 
    Image4 = InitImageRGB(:,:,1);      % To extract one layer from RGB image    
    
    FileName = [Directory Files(i_t * SlicesTotal + max(MiddlePlane - 7, 1)).name]; 
    InitImageRGB = double(imread(FileName)); 
    Image5 = InitImageRGB(:,:,1);
    
    Image = (Image1 + Image2 + Image3 + Image4 + Image5) / 5;
%     figure, imshow(Image, []);
    
%     Image = (Image1 + Image2 + Image3) / 3;
%     figure, imshow(Image, []);
%% Save the image
    SaveFileName = Files(i_File).name;
    [start] = regexp(SaveFileName, '_z');    
    SaveFileName = SaveFileName(1:start - 1);         
    save([DirImOut 'BF_AVG_' SaveFileName '.mat'], 'Image'); 

    save([DirOut 'AllMiddlePlanes_NbSlices'], 'MidPlanesAll', 'SlicesTotal'); 
end
% If the movie got out of Z-range, then zeros have to be taken off 'MidPlanesAll'
% MidPlanesAll(find(MidPlanesAll == 0)) = [];
save([DirOut 'AllMiddlePlanes_NbSlices'], 'MidPlanesAll', 'SlicesTotal'); 










