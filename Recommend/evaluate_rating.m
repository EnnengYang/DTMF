function metric = evaluate_rating(test, P, Q, k, maxS, minS)
% NDCG evaluate
[I,J,V] = find(test);

% pred_val = sum(P(I,:) .* Q(J,:), 2); % small datasets

% For large datasets, divide the calculation
pred_val=zeros(length(V),1);
for i=1:length(V)
    pred_val(i) = P(I(i),:)*Q(J(i),:)';
end

% if discrete: scale the scores in user-item rating matrix to [-scale,+scale]
if min(pred_val) < 0
    r = size(P,2); % bit
    V_ = scaleDiscreteScore(V,r,maxS,minS); 
    rmse = sqrt(mean((V_ - pred_val).^2));
    mae = mean(abs(V_ - pred_val));
else % continuous value
    rmse = sqrt(mean((V - pred_val).^2));
    mae = mean(abs(V - pred_val));
end

all_col = [I,J,V,pred_val];
act_col  = sortrows(all_col, [1,-3]);
pred_col = sortrows(all_col,[1,-4]);

user_count = full(sum(test>0,2));
cum_user_count = cumsum(user_count);% e.g. A = 1:5;B = cumsum(A) => B = 1 3 6 10 15
cum_user_count = [0;cum_user_count];
num_users = size(test,1);


ndcg_Topk = zeros(1,k); % k:TopK 
for kvalue = 1:k
    invalid = 0;
    ndcg_k = 0;
    for u=1:num_users
        if user_count(u) > 0
            u_start = cum_user_count(u)+1;
            u_end = cum_user_count(u+1);
            act = act_col(u_start:u_end,3);
            n = user_count(u);
            discount = log2((1:n)'+1);
            pred = pred_col(u_start:u_end,3);
            idcg = (2.^act - 1) ./ discount;
            dcg  = (2.^pred - 1) ./discount;

             dcgs = 0;
             idcgs = 0;
             for k_ = 1:kvalue
                 if k_>length(idcg)
                   break;
                 end
                  dcgs = dcgs + dcg(k_);
                  idcgs = idcgs + idcg(k_);
             end

             if idcgs > 0
                ndcg_k = ndcg_k + dcgs/idcgs; 
             else
                 if idcgs == 0
                     invalid = invalid + 1;
                 end
             end

        end
    end
    
    unum = sum(user_count>0); % number of have rating users
    ndcg_Topk(kvalue) = ndcg_k/(unum - invalid);
    
end

metric = struct('rating_ndcg',ndcg_Topk,'rating_rmse',rmse,...
                'rating_mae',mae,'rating_ndcg_Topk',ndcg_Topk(k));

end
