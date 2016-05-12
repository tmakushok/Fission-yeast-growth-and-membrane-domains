clear

n = 47;
x = round(0.957 * n);

%% Computing the confidence intervals

[phat, pci] = binofit(x, n, 0.01)


% %% 1) Determining if the sample proportion has an approximate normal distribution
% if n*p*(1-p) >= 5   % then use the normal distribution
%     Z = normpdf(1-2.5, 0, 1);
%     PlusMinus = Z*sqrt(p*(1-p)/n);    
% else    % Use the binomial distribuStion
%     
% end
% 

% [P,PLO,PUP] = normcdf(X,mu,sigma,pcov,alpha) produces confidence bounds
% for P when the input parameters mu and sigma are estimates

%[muhat,sigmahat,muci,sigmaci] = normfit(data) returns 95% confidence intervals 
% for the parameter estimates on the mean and standard deviation in the arrays muci and sigmaci, respectively. 