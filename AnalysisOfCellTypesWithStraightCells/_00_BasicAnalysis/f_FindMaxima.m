function [MaxPos] = f_FindMaxima(Y)
% Do difference matrix
Diff = Y(2:length(Y)) - Y(1:length(Y)-1);
Signs = sign(Diff);
% Subtract: each element in the signs matrix - the previous value 
% The transition of sign from + to - will be at -2
SDiff = Signs(2:length(Signs)) - Signs(1:length(Signs)-1);
MaxPos = find(SDiff == -2) + 1;
% If at the two sides the curve goes up, add the last point 
% as maximum
if Signs(length(Signs)) >= 0
    MaxPos = [MaxPos; length(Y)];
end



