% Creating a mask to get only the positions where there are non-zero values
Mask = BeginningOfP3 .* BeginningOfP2;
Mask = Mask ./ Mask;
Mask(isnan(Mask)) = 0;
% Apply
BeginningOfP2 = BeginningOfP2 .* Mask;
BeginningOfP3 = BeginningOfP3 .* Mask;
% Take off zeros
BeginningOfP2 = BeginningOfP2(find(BeginningOfP2));
BeginningOfP3 = BeginningOfP3(find(BeginningOfP3));
% Length of P2 in time points
Length = BeginningOfP3 - BeginningOfP2;
% Length of P2 in minutes
Length = Length * 3;
% Putting negative values to zeros, anyway beginning of P2 was determined
% manually
Length(Length < 0) = 0;

hist(Length, 20);
mean(Length)
std(Length)
