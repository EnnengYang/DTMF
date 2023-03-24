function [eval_summary, eval_detail, elapsed] = heldout_rec(rec, mat, scoring, varargin)
% Hold-Out Method
% Input:
%   rec: recommendation method
%   mat: user-item-rating matrix (recommendation for the given dataset)
%   scoring: @rating_recommend/evaluate
%   varargin:
% 
% Output:
%   eval_summary:
%   eval_detail:
%   elapsed: training time and testing time

[test, test_ratio, train_ratio, split_mode, times, seed, rec_opt] = process_options(varargin, 'test', [], ...
                             'test_ratio', 0.2, 'train_ratio', -1, 'split_mode', 'un', 'times', 5, 'seed', 1);

if train_ratio<0
    train_ratio = 1 - test_ratio;
end

assert(test_ratio >0  && test_ratio <1)
assert(train_ratio >0 && train_ratio <= 1 - test_ratio)
train_ratio = min(train_ratio, 1 - test_ratio);

elapsed = zeros(times,2); % train time & test time 
if ~isempty(test)
    % recommendation for the given dataset
    train = mat;
    tic; 
    [P, Q] = rec(train, rec_opt{:});
    elapsed(1,1) = toc;
    tic; 
    eval_detail = scoring(train, test, P,  Q);
    elapsed(1,2) = toc;
    if(nnz(test)>0) % Truth condition indicates regular evaluation returning struct  
        fns = fieldnames(eval_detail);
        for f=1:length(fns)
            fieldname = fns{f};
            field_mean = eval_detail.(fieldname);
            eval_summary.(fieldname) = [field_mean; zeros(1,length(field_mean))];
        end
    else
        eval_summary = eval_detail;
    end
else
    % split mat and perform recommendation
    rng();
    eval_detail = struct();
    metric_times = cell(times,1);
    tests = cell(times,1);
    for t=1:times
        [~, tests{t}] = split_matrix(mat, split_mode, 1-test_ratio);
    end
    parfor t=1:times
%     for t=1:times  % used for debug 
        test = tests{t}; train = sparse(mat - test);
        % fprintf('%d,%d\n',full(sum(train(:))),full(sum(test(:))));
        [train, ~] = split_matrix(train, split_mode, train_ratio/(1-test_ratio));
        tic; [P, Q] = rec(train, rec_opt{:}); t1 = toc; % method: e.g. DCF()
        tic;
        if strcmp(split_mode, 'i')
            ind = sum(test)>0;
            metric_times{t} = scoring(train(:,ind), test(:,ind), P,  Q(ind,:));
        else
            metric_times{t} = scoring(train, test, P,  Q);
        end
        t2 = toc;
        elapsed(t, :) = [t1,t2];
        
    end
    for t=1:times
        metric_time = metric_times{t};
        fns = fieldnames(metric_time);
        for f=1:length(fns)
            fieldname = fns{f};
            if isfield(eval_detail, fieldname)
                eval_detail.(fieldname) = [eval_detail.(fieldname); metric_time.(fieldname)]; %additional
            else
                eval_detail.(fieldname) = metric_time.(fieldname);
            end
        end
    end
    fns = fieldnames(eval_detail);
    for f=1:length(fns)
        fieldname = fns{f};
        field = eval_detail.(fieldname);
        eval_summary.(fieldname) = [mean(field,1); std(field,0,1)]; % times result mean and std
    end
    elapsed = mean(elapsed, 1);
end

end
