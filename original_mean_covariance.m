
function [m,S] = original_mean_covariance(V,c0,n)

m = ones(n,1).*c0;

Q = zeros(n,n);

lambda1 = V(1);
lambda2 = V(2);
    
Q(1:n+1:end) = (lambda1 + 2*lambda2) * ones(n,1);
        
Q(1,1) = lambda1 + lambda2;
Q(n,n) = lambda1 + lambda2;
        
Q(n+1:n+1:end) = -lambda2 * ones(n-1,1);
Q(2:n+1:end) = -lambda2 * ones(n-1,1);

S = inv(Q);