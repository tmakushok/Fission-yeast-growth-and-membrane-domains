%% The task of the program is to delete 
%% empty elements from a cell array
A = PatchDynamics_Phases;

for i = length(A):-1:1
    if isempty(A{i})
        A(i) = [];
    end
end








