
% -------------------------------------------------------------------------
% create the synthesized dataset by sampling 
%        --- how we generate 'synthesized_dataset.mat'
% -------------------------------------------------------------------------
x = randn(15000,1);
X = csvread('data/Trace/Trace_TRAIN');

x1 = X(80, 2:end);
x2 = X(55, 2:end);

l = length(x1);

sigma1 = eye(l)*0.01;
sigma2 = eye(l)*0.01;

for i = 100:600:6700
  
    x(i:i+l-1) = mvnrnd(x1,sigma1,1);
    x(i+7200:i+7200+l-1) = mvnrnd(x2,sigma2,1);
end

% for i = 1:5
%     plot(S1(i,:))
%     hold on;
% end
% 
% for j = 1:5
%     plot(S2(j,:))
%     hold on;
% end
% 
plot(x);