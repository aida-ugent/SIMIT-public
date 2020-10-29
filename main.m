dataset = input(['Which time series? \n ' ...
    'The synthesized Trace dataset (Type s), ECG time series (Type e), Belgium power load data (Type b)'], 's');

if dataset == 's'
    Data = load('/simit/data//synthesized_dataset.mat');
    x = Data.x;
    l = 275;

elseif dataset == 'e'
    fid = fopen('/simit/data//arrhythmia/205.dat');
    f=fread(fid,'ubit12');
    Orig_sig = f(1:2:length(f));
    x = Orig_sig(104400:111600);
    l = 100;

elseif dataset == 'b'
    X = load('/smit/data//BE_load.mat');
    x = X.BE_load_entsoe_power_statistics;
    l = 24;

else
    disp('invalid input')
end

python2path = '/usr/bin/python';




% -------------------------------------------------------------------------
% Compute initial background distribution
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

% -------------------------------------------------------------------------

% -------------------------------------------------------------------------
% Compute a matrix for which we want to find the submatrix with max sum 
% -------------------------------------------------------------------------

init_c = 4;

up_W = zeros(n-l+1,n-l+1);

for i = 1:n-2*l+1
    for j = i+l:n-l+1
        Vec = x(i:i+l-1) - x(j:j+l-1);
        nz = nnz(Vec);
        up_W(i,j) = -1./(init_c-1)*(sum(log((nonzeros(Vec)).^2))+(l-nz)*log(0.000001));
    end
end

up_W = triu(up_W) + triu(up_W)';
up_W(1:n-l+2:end) = ics;
% 

up_W_ = up_W;

% -------------------------------------------------------------------------


% -------------------------------------------------------------------------
% Greedy Search 
% -------------------------------------------------------------------------

num_round = 1;
reduced_size = round(n/100);

candi_sid_up = 1:n-l+1;
all_overlap = [];

c = init_c;

while ~isempty(candi_sid_up)

    % Searching an inital set of instances for a template
    init_inss = instances_for_initial_template(up_W_,init_c,l,'y',reduced_size,python2path);
    
    init_inss = candi_sid_up(init_inss)';
    
    % Incorporating the initial set to update the background distribution
    [m_up, S_up, var_up]=final_mean_covariance(x, init_inss, m, S, l);
    
    [inss,new_m, new_S,new_ics, all_overlap,min_ic,f]= greedily_grow_template(x,m_up,S_up,...
        up_W,init_inss,ics,n,init_c,l,reduced_size,all_overlap,num_round);
    fig_name = sprintf('results_round_%d', num_round);
    savefig(f,[fig_name '.fig']);
    close(f);
    c = length(inss);
    
    if c<= init_c + 1
        break
    end
    
    m = new_m;
    S = new_S;
    
    old_ic_whole = min_ic;
      
    ics = new_ics;
    up_W(1:n-l+2:end) = new_ics;
    
    candi_sid_up = 1:n-l+1;
    candi_sid_up(all_overlap) = []; 

    up_W_ = up_W(candi_sid_up, candi_sid_up);

    reduced_size = round(length(candi_sid_up)*0.01);
    
    num_round = num_round + 1;
    
end


% -------------------------------------------------------------------------

