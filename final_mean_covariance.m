function [m_, S_, var]=final_mean_covariance(Data, inss, m, S, l)

m_ = m;
S_ = S;

c = length(inss);
n = length(Data);

var = diag(S_);
 

for k = 1:l        
    col_id = inss(:)+(k-1)*ones(c,1);
    m_(col_id) = mean(Data(col_id))*ones(c,1); 
    var(col_id) = (1/(c-1)*sum((Data(col_id)-m_(col_id)).^2)+0.00001)*ones(c,1);   
end

for j = 1:c
    S_(inss(j):inss(j)+l-1, 1:end) = zeros(l,n);
    S_(1:end, inss(j):inss(j)+l-1) = zeros(n,l);
end
   
S_(1:n+1:end) = var;