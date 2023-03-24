function [opt_para, para_all, result, times] = hyperp_search(alg_func, metric_func, varargin)

    [mode, opt] = process_options(varargin, 'mode', 'grid');

    if strcmpi(mode, 'grid')
        [opt_para, para_all, result, times] = parallel_grid_search(alg_func, metric_func, opt{:});
    else
        error('unsupported mode')
    end

end


function [opt_para, para_all, result, times] = parallel_grid_search(alg_func, metric_func, varargin)

    names = varargin(1:2:length(varargin));
    ranges = varargin(2:2:length(varargin));
    total_ele = prod(cellfun(@(c) length(c), ranges));
    [Ind{1:length(ranges)}] = ndgrid(ranges{:});
    Indmat = cell2mat(cellfun(@(mat) mat(:), Ind, 'UniformOutput', false));
    nn = cell(total_ele,1); [nn{:}]=deal(names);
    paras = cellfun(@(x,y) [y;num2cell(x)], num2cell(Indmat,2), nn, 'UniformOutput', false);
    para_all = cell(total_ele, length(names)*2);

    for i=1:total_ele
        para_all(i,:) = paras{i}(:);
    end

    metrics = cell(total_ele, 1);
    times = zeros(total_ele, 2);
    parfor it =1:total_ele
%     for it =1:total_ele  % used for debug 
        [metrics{it}, ~, times(it,:)] = alg_func(para_all{it,:}); % rating_recommend(rec, mat, varargin)
    end
    [~, idx] = max(cellfun(@(x) metric_func(x), metrics));
    opt_para = para_all(idx,:);

    metrics_array = [metrics{:}];
    result = struct();
    fns = fieldnames(metrics{1});
    for f=1:length(fns)
        mm = cell2mat({metrics_array.(fns{f})}');
        result.(fns{f}) = mm(1:2:end,:);
    end

end

