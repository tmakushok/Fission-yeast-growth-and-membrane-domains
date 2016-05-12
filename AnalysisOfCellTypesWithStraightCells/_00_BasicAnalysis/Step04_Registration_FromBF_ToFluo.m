%% The task of the program is to perform image registration to take off
%% image movements from time point to time point
%% The task of the program is to perform image registration to take off
%% image movements from time point to time point
%% on fluorescence images
% clear
%--------------------------------------------------------------------------
%!!!--!!! File names
ImageFolder = '_InputImages/';
%--------------------------------------------------------------------------
% List of BF files to analyse
ImFiles = dir([ImageFolder, 'BF_AVG_*.mat']);  
% Registration BF images and obtaining the matrix of displacements to do the
% registration of the fluo images later
Displ = f_Reg_BF(ImageFolder, ImFiles);

% List of files to analyse
ImFiles = dir([ImageFolder, 'AVG_*.mat']);   
f_Reg_Fluo(ImageFolder, ImFiles, Displ);

