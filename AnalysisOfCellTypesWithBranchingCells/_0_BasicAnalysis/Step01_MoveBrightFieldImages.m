%% The task of the program is to move files with bright field images

Files = dir('_InputImages/*_ch01*');
%Files = dir('*.nd');
for i_File = 1:length(Files)    
    FileName = ['_InputImages/' Files(i_File).name];
    movefile(FileName, ['_InputImages/BrightFieldImages/' Files(i_File).name])
%     delete(FileName);
end