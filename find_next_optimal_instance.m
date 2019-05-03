function [new_ins, mm, SS,min_ic]= find_next_optimal_instance(x,m_,S_,l,candi_sid,inss)

n = length(x);
min_ic = inf;

for i = 1:length(candi_sid)
    
    tem_inss = [inss,0];
    
    tem_ins = candi_sid(i);
    tem_inss(end) = tem_ins;
    
    tem_num_inss = length(tem_inss);
        
    tem_m = m_;
    tem_S = S_;
    var = diag(tem_S);
        
    for k = 1:l        
        col_id = tem_inss(:)+(k-1)*ones(tem_num_inss,1);
        tem_m(col_id) = mean(x(col_id))*ones(tem_num_inss,1); 
        var(col_id) = (1/(tem_num_inss-1.)*sum((x(col_id)-tem_m(col_id)).^2)+0.001)*ones(tem_num_inss,1);   
    end
    
    tem_S(tem_ins:tem_ins+l-1, 1:end) = zeros(l,n);
    tem_S(1:end, tem_ins:tem_ins+l-1) = zeros(n,l);
    tem_S(1:n+1:end) = var;
       
    L = chol(tem_S);
    half_logdet = sum(log(diag(L)));
    ic = n/2.*log((2*pi))+half_logdet+0.5*(x-tem_m)'*inv(tem_S)*(x-tem_m);
    
    
    if ic < min_ic
        min_ic = ic;
        mm = tem_m;
        SS = tem_S;
        new_ins = tem_ins;
    end
        
end