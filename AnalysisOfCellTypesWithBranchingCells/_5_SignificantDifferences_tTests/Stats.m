close all;

Res1 = Width_Quick_WT;
Res2 = Width_Quick_WT;

%% Basic statistics
Mean1 = mean(Res1);
Median1 = median(Res1);
Std1 = std(Res1);

Mean2 = mean(Res2);
Median2 = median(Res2);
Std2 = std(Res2);
%% Lillilifors test
% test of the default null hypothesis that the sample in vector x comes
% from a distribution in the normal family, against the alternative that it
% does not come from a normal distribution. The test returns the logical value h = 1 if
% it rejects the null hypothesis at the 5% significance level, and h = 0 if
% it cannot.
% (for sample sizes less than 1000 and significance levels between 0.001 and 0.50)
Lil1 = lillietest(Res1);
Lil2 = lillietest(Res2);
% Value 1- not normal distribution
%% Quantile-quantile plot of two samples. 
% If the samples do come from the same distribution, the plot will be linear.
% They are scatter plots of quantiles computed from each sample, with a line drawn between the first and third quartiles.
qqplot(Res1, Res2);
%% The nonparametric Wilcoxon rank sum test, implemented by the function ranksum, can be used to quantify the test of equal
% medians. It tests if two independent samples come from identical continuous
% (not necessarily normal) distributions with equal medians, against the alternative
% that they do not have equal medians.
% (The test is equivalent to a Mann-Whitney U-test.)
[p_RankSum, h_RankSum] = ranksum(Res1, Res2, 'alpha', 0.01);  %, 'method', 'exact');   % 'alpha' defines significance level
% h = 0 indicates a failure to reject the null hypothesis
%% ttest2 
% performs a t-test
% of the null hypothesis that data in the vectors x and y are
% independent random samples from normal distributions with equal means and
% equal but unknown variances, against the alternative that the means are not
% equal. The result of the test is returned in h. h = 1 indicates
% a rejection of the null hypothesis at the 5% significance level. h = 0 indicates
% a failure to reject the null hypothesis at the 5% significance level. x and y need
% not be vectors of the same length.
% Ttest005 = ttest2(Res1, Res2);
% Result 1 means that the means are different at the 5% significance level
Ttest001 = ttest2(Res1, Res2, 0.01);
% Result 1 means that the means are different at the 1% significance level






%% Normal distribution plots
figure(), normplot(Res1);
figure(), normplot(Res2);
% %% Take off last points that are too much
% Res = [Res1, Res2(1:length(Res1))];
% figure(), normplot(Res);
%% Choosing the distribution
probplot(Res2);
probplot('exponential', Res2);
probplot('extreme value', Res2);
probplot('lognormal', Res2);
probplot('normal', Res2);
probplot('rayleigh', Res2);
probplot('weibull', Res2);
%% Jarque-Bera
% test of the null hypothesis that the sample in vector x comes
% from a normal distribution with unknown mean and variance, against the alternative
% that it does not come from a normal distribution. 
h_JB1 = jbtest(Res1);
h_JB2 = jbtest(Res2);
% The test returns the logical value h = 1 if
% it rejects the null hypothesis at the 5% significance level
%% two-sample Kolmogorov-Smirnov test to compare the distributions of values in the two
% data vectors X1 and X2 of length n1 and n2,
% respectively, representing random samples from some underlying distribution(s).
% The null hypothesis for this test is that X1 and X2 are
% drawn from the same continuous distribution. The alternative hypothesis is
% that they are drawn from different continuous distributions.
H = kstest2(Res1, Res2);
% The result H is 1 if you can reject the hypothesis that the distributions are the same
%% Box plots
% The heights of the notches in each box are computed so that the side-by-side
% boxes have nonoverlapping notches when their medians are different at a default
% 5% significance level. The computation is based on an assumption of normality
% in the data, but the comparison is reasonably robust for other distributions.
% The side-by-side plots provide a kind of visual hypothesis test, comparing
% medians rather than means.
% boxplot(Res,'notch','on')
% grid on
% set(gca,'XtickLabel',str2mat('WT, 37C','Tea1 del, 37C'));
% ylabel('CellWidths, pixels')
% xlabel('')
%% Test against the Poisson distribution by specifying observed and expected counts:
% bins = 0:5;
% obsCounts = [6 16 10 12 4 2];
% n = sum(obsCounts);
% lambdaHat = sum(bins.*obsCounts)/n;
% expCounts = n*poisspdf(bins,lambdaHat);
% 
% [h,p,st] = chi2gof(bins,'ctrs',bins,...
%                         'frequency',obsCounts, ...
%                         'expected',expCounts,...
%                         'nparams',1)
