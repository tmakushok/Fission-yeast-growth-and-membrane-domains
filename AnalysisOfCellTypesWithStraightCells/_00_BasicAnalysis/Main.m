%% Technical preparation steps
% Step01_MoveBrightFieldImages;
% Step02_BF_Proj;
Step03_Fluo_Proj;
Step04_Registration_FromBF_ToFluo;
%% Find cells outlines and geometrical params
Step05_Cells_Tips_Outlines_BF;  
%% Find which cell is which from plane to plane
Step06_TrackCellsInTime;   
%% Get intensity profiles along outlines (in a 3*3 square) for each cell and each time point
Step07_OutlineProfiles;     
%% Create kymograph matrices from previously obtained intensity profiles:
% one for one cell end, plot kymographs, save matrices
% !!!!!!!! DO: another for the other end (ceparately for quickly growing end and for the slower one?)
Step08_Kymographs;       
Step20_Kymographs_AtCellBorder_For3Tips;
Step21_CheckCellsVideos;

