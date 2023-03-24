
dataset = 'Epinions-665k';  % Epinions-665k | Douban
[ data, ~, ~] =  readDataSocial(['./Dataset/',dataset,'/'], 1); 

r = 8; 
test_ratio = 0.5;

algs(1).alg = @(data,varargin) DCF(data,'max_iter',20,'r',r,'init',false,'debug',true,varargin{:});
algs(1).paras = {'test_ratio',test_ratio,'cutoff_rating',10,'maxS',5,'minS',1,...
                 'alpha',10.^(-3:3),'beta',10.^(-3:3)};

algs(2).alg = @(data,varargin) DTMF(data,'max_iter',20,'r',r,'init',false,'debug',true,'dataset',dataset,varargin{:});
algs(2).paras = {'test_ratio',test_ratio,'cutoff_rating',10,'maxS',5,'minS',1,...
                 'alpha',10.^(-3:3),'beta',10.^(-3:3),'gamma',10.^(-3),'lambda',10.^(-3:3)}; %lambda: 10.^(-3:3)
             
if ~exist('result', 'var')
    result = cell(length(algs),1);
end

for i=1:length(algs)
    [outputs{1:6}] = running(algs(i).alg, data, algs(i).paras{:});
    result{i} = outputs;
    disp('NDCG:'); result{1,1}{1,1}.rating_ndcg(1,:)
end

