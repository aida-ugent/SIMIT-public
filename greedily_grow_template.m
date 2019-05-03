function [inss,new_m, new_S, ics_up, overlap_ind,min_ic]=greedily_grow_template(x,...
    m_up,S_up,up_W,inss_up,ics,n,c,l,reduced_size,overlap_ind,num_round)


figure(num_round);

%--------------------------------------------------------------------------

subplot(3,1,1),plot(x);
hold on;
subplot(3,1,1),title('A time series');
subplot(3,1,1),xlabel('Time')


subplot(3,1,2),plot(ics,'r')
legendinfo1{1} = ['0'];
hold on;

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------

for i=1:n-l+1
    pdf_up(i) = mvnpdf(x(i:i+l-1),m_up(i:i+l-1),S_up(i:i+l-1,i:i+l-1));
    ics_up(i) = -log(pdf_up(i));
end
%  
subplot(3,1,2),plot(ics_up);
legendinfo1{2} = ['1'];
hold on; 

%--------------------------------------------------------------------------


%--------------------------------------------------------------------------

L = chol(S_up);
half_logdet = sum(log(diag(L)));
ic1_up = n/2.*log((2*pi))+half_logdet+0.5*(x-m_up)'*inv(S_up)*(x-m_up);
    

ics_list_up = [ic1_up];

inss_up = inss_up';

candi_sid_up = 1:n-l+1;

for k = 1:length(inss_up)
    overlap_ind = union(overlap_ind, max(1,inss_up(k)-l+1):min(inss_up(k)+l-1,n-l+1));
end

candi_sid_up(overlap_ind) = []; 

potentials = -Inf(1,n-l+1);
potentials(candi_sid_up) = 0;

for i = candi_sid_up
    potentials(i) = ics(i);
    for k = 1:length(inss_up)
        potentials(i) = potentials(i) + up_W(i,inss_up(k))*(c-1)/c;
    end    
end

[A,I] = sort(potentials,'descend');

candi_sid_up = I(1:min(reduced_size,length(candi_sid_up))); 
num = 1;

flag = 0;

for j = 1:90
    
    [new_ins_up, mm_up, SS_up, min_ic] =  find_next_optimal_instance(x, m_up, S_up, l, candi_sid_up,inss_up);
    
    candi_size = length(candi_sid_up);
    
    if (candi_size > 3 & ismember(new_ins_up, candi_sid_up(1:min(3,candi_size)))) || flag > 1
        
       
        flag = 0;
        
        ics_list_up = [ics_list_up,min_ic];
     
        if ics_list_up(end)-ics_list_up(end-1) > 0.
            min_ic = ics_list_up(end-1);
            break;
        end
         
        num = num+1;
        
        m_up = mm_up;
        S_up = SS_up;
        
        
        for i=1:n-l+1
            pdf_up(i) = mvnpdf(x(i:i+l-1),m_up(i:i+l-1),S_up(i:i+l-1,i:i+l-1));
            ics_up(i) = -log(pdf_up(i));
        end
%  
        subplot(3,1,2),plot(ics_up);
        legendinfo1{num+1} = [num2str(num)];
        hold on; 
    
        inss_up =sort([inss_up,new_ins_up]); % add it to the array 'inss' which stores the starting indices for all these kind of instances 
   
        remove_id = find(candi_sid_up >= new_ins_up-l+1 & candi_sid_up <= new_ins_up+l-1);
       
        
        candi_sid_up(remove_id(:)) = [];
        overlap_ind = union(overlap_ind, max(1,new_ins_up-l+1):min(new_ins_up+l-1,n-l+1));
    
        c = c+1;
     
    else
        flag = flag+1;
        
        candi_sid_up = 1:n-l+1;
        candi_sid_up(overlap_ind) = []; 
        

        potentials(overlap_ind) = -inf;
        for i = candi_sid_up
            potentials(i) = ics_up(i);
            for k = 1:length(inss_up)
                potentials(i) = potentials(i) + up_W(i,inss_up(k))*(c-1)/c;
            end
        end    
   
        [A,I] = sort(potentials,'descend');

        candi_sid_up = I(1:min(reduced_size,length(candi_sid_up)));
                      
    end 
    
    if isempty(candi_sid_up) == 1
        break;
    end
        
end    

%--------------------------------------------------------------------------
inss = inss_up;

new_m = m_up;
new_S = S_up;
    
var_up = diag(S_up);
ave_var = mean(var_up);

for i = 1:c
    subplot(3,1,1),plot(inss(i):inss(i)+l-1,x(inss(i):inss(i)+l-1),'r');
    hold on;
end

subplot(3,1,1),xlim([0,n]);
subplot(3,1,2),xlim([0,n]);

subplot(3,1,2),title('SI');
subplot(3,1,2),xlabel('Subsequence starting position')
subplot(3,1,2),ylabel('SI')
subplot(3,1,2),legend(legendinfo1);


subplot(3,1,3),errorbar(linspace(1,l,l),m_up(inss(end):inss(end)+l-1),sqrt(var_up(inss(end):inss(end)+l-1)),'-*');
title(['Template',num2str(inss)]);
