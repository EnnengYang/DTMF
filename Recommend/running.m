function [metric, metric_detail, best_para, paras_tuned, metrics_tuned, times_tuned] = running(method_fun, dataset, varargin)

[test_ratio,times,cutoff_rating,maxS,minS,para_search_mode,paras] = process_options(varargin,...
                                                      'test_ratio',0.2,'times',5,'cutoff_rating',10,'maxS',5,'minS',1,'search_mode','grid');

metric_fun = @(metric) metric.rating_ndcg(1,1);

no_tune = all(cellfun(@length, paras(2:2:end))==1);

if ~no_tune
    [best_para, paras_tuned, metrics_tuned, times_tuned] = hyperp_search(...
         @(varargin) rating_recommend(method_fun, dataset, 'test_ratio', test_ratio, 'times', times,'cutoff_rating', cutoff_rating, varargin{:}), metric_fun, 'mode', para_search_mode, paras{:});
else
    best_para = paras; paras_tuned = []; metrics_tuned = []; times_tuned = [];
end

[metric, metric_detail, time] = rating_recommend(@(mat) method_fun(mat, best_para{:}), dataset, 'test_ratio', test_ratio, 'times', times,'cutoff_rating', cutoff_rating);

times_tuned = [times_tuned; time];

end