Input1 = Speeds_WT;
Input2 = Speeds_Tea1;

Res1 = Input1;
Res2 = Input2;

% Res1 = Input1 / max(Input1);
% Res2 = Input2 / max(Input2);

%% Two-sample Kolmogorov-Smirnov test to compare the distributions 
% of values in the two data vectors X1 and X2 of length n1 and n2,
% respectively, representing random samples from some underlying
% distribution(s).
% The null hypothesis for this test is that X1 and X2 are
% drawn from the same continuous distribution. The alternative hypothesis is
% that they are drawn from different continuous distributions.
[h,p,ks2stat] = kstest2(Res1, Res2, 0.01)
% The result H is 1 if you can reject the hypothesis that the distributions
% are the same

figure
F1 = cdfplot(Res1);
hold on
F2 = cdfplot(Res2)
set(F1,'LineWidth',2,'Color','r')
set(F2,'LineWidth',2)



