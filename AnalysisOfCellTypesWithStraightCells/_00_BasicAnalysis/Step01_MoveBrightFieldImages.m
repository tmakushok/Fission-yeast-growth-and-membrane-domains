%% The task of the program is to move files with bright field images to a
%% separate folder 'BrightFieldImages' (the data obtained from the microscope 
%% is in the shape of fluorescent and bright-field images all mixed in one list) 

Files = dir('_InputImages/*_ch01*');    % Create the list of bright field images
%Files = dir('*.nd');       % This line can be used to select some non-image files to be deleted
for i_File = 1:length(Files)    
    FileName = ['_InputImages/' Files(i_File).name];
    movefile(FileName, ['_InputImages/BrightFieldImages/' Files(i_File).name])
%     delete(FileName);     % This line can be used to delete specified non-image files
end