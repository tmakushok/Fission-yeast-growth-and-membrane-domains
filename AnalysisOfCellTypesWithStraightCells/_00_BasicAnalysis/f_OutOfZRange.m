function Mask1 = f_OutOfZRange(CorrImage1, CorrImage2)
%% --- Threshold on the area of detected objects, in pixels
AreaThres = 32;
StdCoeff = 3;
%  ---
%% For correction image 1
figure, imshow(CorrImage1, []);
% Making a vector out of the matrix (otherwise historam of each column separately)
[m, n] = size(CorrImage1);
% CorrImage1 = medfilt2(CorrImage1, [5 5]);
CorrImage1Resh = reshape(CorrImage1, 1, m * n);     
% figure, hist(CorrImage1Resh, 500);
% Threshold on the intensity: 2*std
CorrImage1Thres = CorrImage1 > StdCoeff *std(CorrImage1Resh);
% figure, imshow(CorrImage1Thres, []);
% Median filtering to get rid of sparse points on the image
Mask1 = medfilt2(CorrImage1Thres, [5 5]);
figure, imshow(Mask1, []);

%% For correction image 2
figure, imshow(CorrImage2, []);
% Making a vector out of the matrix (otherwise historam of each column separately)
[m, n] = size(CorrImage2);
% CorrImage2 = medfilt2(CorrImage2, [5 5]);
CorrImage2Resh = reshape(CorrImage2, 1, m * n);     
% figure, hist(CorrImage2Resh, 500);
% Threshold on the intensity: 2*std
CorrImage2Thres = CorrImage2 > StdCoeff *std(CorrImage2Resh);
% figure, imshow(CorrImage2Thres, []);
% Median filtering to get rid of sparse points on the image
Mask2 = medfilt2(CorrImage2Thres, [5 5]);
figure, imshow(Mask2, []);

%% Combination of the two
Mask1(find(Mask2)) = 1;
% figure, imshow(Mask1, []);
%% Taking off detected objects that are too small
Labels = bwlabel(Mask1);
Stats = regionprops(Labels, 'Area'); 
[Condition] = find([Stats.Area] > AreaThres);
Mask1 = ismember(Labels, Condition);
figure; imshow(Mask1, []); 




