function [eval_summary,eval_detail,elapsed] = rating_recommend(rec, mat, varargin)

[cutoff_rating,maxS,minS, varargin] = process_options(varargin,...
                                                   'cutoff_rating',20,'maxS',5,'minS',1);
                                               

option = 'output';
for i=1:2:length(varargin)
    if strcmp(varargin{i}, 'test') || strcmp(varargin{i}, 'test_ratio')
        option = 'heldout';
        break;      
    end
end

if strcmp(option, 'heldout')
    [eval_summary,eval_detail,elapsed] = heldout_rec(rec, mat, @evaluate, varargin{:});
end
if strcmp(option, 'output')
    [eval_summary,eval_detail,elapsed] = heldout_rec(rec, mat, @evaluate, 'test', sparse(size(mat,1), size(mat,2)), varargin{:});
end

% use (train,test,P,Q);
function metric = evaluate(tr,te,p,q)
    metric1 = evaluate_rating(te,p,q,cutoff_rating,maxS,minS); % rating_ndcg;  rating_rmse;  rating_mae;  rating_ndcgri;
    metric = metric1;
end

end
