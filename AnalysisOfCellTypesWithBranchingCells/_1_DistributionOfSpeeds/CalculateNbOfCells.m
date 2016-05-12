CellNb = 0;
for i = 1:length(Dynamics) 
   if ~isempty(Dynamics{i})
       CellNb = CellNb + 1;
   end
end