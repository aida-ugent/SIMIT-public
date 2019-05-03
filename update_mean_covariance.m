function [sall,errs] = update_mean_covariance(sall,inds,w,s2,m)

n = length(inds);

% First compute new equivalence classes.
% sall will contain the remainders of the previous equivalence classes.
% supdate contains the newly created ones, with the parts of the previous
% equivalence classes that overlapped with inds.

supdate = struct('S',{},'Sminhalfinv',{},'mu',{},'Sinvmu',{},'inds',{});
todelete = false(length(sall),1);
for i=1:length(sall)
    sinds = sall(i).inds;
    % Shrink the set of indices to which sall(i) applies:
    dif = setdiff(sinds,inds);
    sall(i).inds = dif;
    if isempty(dif)
        todelete(i)=true;
    end
    
    % Store the others in a separate structure:
    int = intersect(sinds,inds);
    if ~isempty(int)
        supdate(end+1,1) = sall(i);
        supdate(end).inds = int;
    end
end
sall(todelete) = [];

% Analytically compute the update to the mean vector

num = 0;
den = 0;
for i=1:length(supdate)
    ni = length(supdate(i).inds);
    mui = supdate(i).mu;
    Si = supdate(i).S;
    
    num = num + ni*(w'*mui-m);
    den = den + ni*(w'*Si*w);
end
alpha = num/den;

for i=1:length(supdate)
    supdate(i).Sinvmu = supdate(i).Sinvmu - alpha*w;
    supdate(i).mu = supdate(i).mu - alpha*supdate(i).S*w;
end


% Use MATLAB's root finder to compute the update to the covariance
% parameters of the new equivalence classes.

% Compute the range within which the function is monotonically decreasing
% and contains a zero.
low = -inf;
aa=0;
for i=1:length(supdate)
    ni = length(supdate(i).inds);
    mui = supdate(i).mu;
    Si = supdate(i).S;
    wSw = w'*Si*w;
    aa = aa+ni*(m-mui'*w)^2/(w'*Si*w)^2;
    low = max(low,(ni*wSw*0.9-n*s2)/(wSw*n*s2));
end
bb = n*s2;
up = 1/(2*bb)*(n+sqrt(n^2+4*aa*bb));
interval = [low up];

% Find the zero within this interval over which the function is
% monotonically decreasing and convex
try
    alpha = fzero(@(x) lambda_cost(x,supdate,w,s2,m), interval);
catch % Due to numerical issues, the zero is probably not included in the interval
    low_val = lambda_cost(low,supdate,w,s2,m);
    up_val = lambda_cost(up,supdate,w,s2,m);
    if up_val>0 % Numerically, up_val should probably be 0
        alpha = up;
    elseif low_val<0 % Numerically, low_val should probably be 0
        alpha = low;
    end
end
alpha = min(1e6,alpha);

% Update the parameters of the equivalence classes accordingly

for i=1:length(supdate)
    % Updates to the natural parameters:
    supdate(i).Sminhalfinv = supdate(i).Sminhalfinv - alpha/2.*(w*w');
    supdate(i).Sinvmu = supdate(i).Sinvmu+alpha*m*w;
    % Updates to the standard parameters:
    v = supdate(i).S*w;
    supdate(i).S = supdate(i).S - alpha*(v*v')/(1.+alpha*w'*v);
    supdate(i).mu = supdate(i).S*supdate(i).Sinvmu;
end

% Concatenate the old (reduced in size) and new equivalence classes.

sall = [sall ; supdate];

% Compute errors.

errs = [0 0];
for i=1:length(supdate)
    ni = length(supdate(i).inds);
    mui = supdate(i).mu;
    Si = supdate(i).S;
    errs(1) = errs(1) + ni*(w'*mui-m);
    errs(2) = errs(2) + ni*(w'*Si*w + (m-mui'*w)^2 - s2);
end
