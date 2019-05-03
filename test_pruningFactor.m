%
% This code is to investigate the effects of the pruning factor
% Dataset is the synthetic time series.
%

Data = load('data/synthesized_dataset.mat');
x = Data.x;
l = 275;

% -------------------------------------------------------------------------
% Compute intial background distribution
% -------------------------------------------------------------------------

c0 = mean(x);
n = length(x);

options = optimoptions('fmincon','Algorithm','interior-point',...
    'SpecifyObjectiveGradient',false, 'Display','none');

Y = fmincon(@(v) compute_lambda(v,x,c0,n),rand(1,2),[],[],[],[],[0,0],[1e10,1e10],[],options);

[m,S] = original_mean_covariance(Y,c0,n);
S=S+S';S=S/2;

for i=1:n-l+1
     pdf(i) = mvnpdf(x(i:i+l-1),m(i:i+l-1),S(i:i+l-1,i:i+l-1));
     ics(i) = -log(pdf(i));
end 

L = chol(S);
half_logdet = sum(log(diag(L)));
Loglike0 = -(n/2.*log((2*pi))+half_logdet+0.5*(x-m)'*inv(S)*(x-m));


init_c = 4;
c = init_c;

% % upper bound

up_W = zeros(n-l+1,n-l+1);

for i = 1:n-2*l+1
    for j = i+l:n-l+1
        Vec = x(i:i+l-1) - x(j:j+l-1);
        nz = nnz(Vec);
        up_W(i,j) = -1./(c-1)*(sum(log((nonzeros(Vec)).^2))+(l-nz)*log(0.000001));
    end
end

up_W = triu(up_W) + triu(up_W)';
up_W(1:n-l+2:end) = ics;

up_W_ = up_W;


scale_factors = [0.001,0.002,0.003,0.004,0.005,0.006,0.007,0.008,0.009,0.01,0.1];
reduce_size = round(scale_factors*n)

Upper_bounds = [];
ICS = [];

trials = length(scale_factors);


for k = 1:trials
    inss =instances_for_initial_template(up_W,c,l,'y',reduce_size(k));
    
    [m_, S_, var_]=final_mean_covariance(x, inss, m, S, l);

    term1 = 0;
    term2 = 0;
    term3 = 0;
    
    for i = 1:c
        for j = i:c
            
            if i~=j
                Vec = x(inss(i):inss(i)+l-1) - x(inss(j):inss(j)+l-1);
                nz = nnz(Vec);
                term1 = term1 + (-1./(c-1)*(sum(log((nonzeros(Vec)).^2))+(l-nz)*log(0.000001)));           
                
                
            else 
                term2 = term2 + ics(inss(j));
                term3 = term3 + log(mvnpdf(x(inss(j):inss(j)+l-1),m_(inss(j):inss(j)+l-1),S_(inss(j):inss(j)+l-1,inss(j):inss(j)+l-1)));

            end
        end
    end
    
    upper = - c*l/2.*log(2.*pi) + c*l/2.*(log(c) + log(c-1)) + term1 - c*l/2.*log(c*(c-1)/2.) - 1/2.*l*(c-1) + term2;
    orig = term3 + term2;
    
    Upper_bounds = [Upper_bounds, upper]
    ICS = [ICS, orig]
        
end

scatter(scale_factors,Upper_bounds,'b','filled');
hold on;
scatter(scale_factors,ICS,'r','filled');
hold on;

legend('upper bound','ics');


