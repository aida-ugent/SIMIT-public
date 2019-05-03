function [m,S,sall]=fit_mean_covariance(c0,c1,c2,n)

sall = struct('S',{},'Sminhalfinv',{},'mu',{},'Sinvmu',{},'inds',{});
sall(1).S = eye(n)*c1;
sall(1).mu = ones(n,1)*c0;
sall(1).Sminhalfinv = -1/2*eye(n)*1/c1;
sall(1).Sinvmu = 1/c1*sall(1).mu;
sall(1).inds = 1;

inds = 1;

for i=1:5    


    for k=1:n-1
        w = zeros(n,1);
        w(k) = 1;
        w(k+1) = -1;
        w = w/norm(w);
        s2 = c2;
        [sall,errs] = update_mean_covariance(sall,inds,w,s2,0);
        
       
%         [R,check] =  chol(sall(1).S);
%         check
        
        w = zeros(n,1);
        w(k) = 1;
        w = w/norm(w);
        s2 = c1;
        [sall,errs] = update_mean_covariance(sall,inds,w,s2,c0);
        
%         [R,check] =  chol(sall(1).S);
%         check
    end
    
    w = zeros(n,1);
    w(n) = 1;
    w = w/norm(w);
    s2 = c1;     
    [sall,errs] = update_mean_covariance(sall,inds,w,s2,c0);
%         
%      
%     [R,check] =  chol(sall(1).S);
%     check
%        
    
    %   adding constraints for second-order difference
%     for k = 1:n
%         w = zeros(n,1);
%         w(n) = 1;
%         w = w/norm(w);
%         s2 = c1;
%         [sall,errs] = update_mean_covariance(sall,inds,w,s2,c0);
%     end
%     
%     [R,check] =  chol(sall(1).S);
%     check
end   

%         


%sall(1).S(1)
%c1
%sall(1).S(1,2)
%c2
m = sall(1).mu;
S = sall(1).S;
