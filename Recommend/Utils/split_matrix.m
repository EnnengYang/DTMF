function [train, test] = split_matrix(mat, mode, ratio)
% Ratio corresponds to the ratio of training set. There are five types of matrix split methods, by specified by 'mode'.
% split matrix 
%  * e.g. mode='un' and ratio=0.8
%  * 'un' (default) user-oriented split, splitting each user data into 'folds' folds
%  * 'in' item-oriented split
%  * 'en' entry-oriented split
%  * 'u'  splits users into 'folds' folds, which is used for cold-start user evaluation
%  * 'i'  splits items into 'folds' folds, which is used for cold-start item evaluation

if strcmp(mode, 'un') 
    [train, test] = normal_split(mat, ratio);
elseif strcmp(mode, 'in') 
    [train, test] = normal_split(mat.', ratio);
    train = train.';
    test = test.';
elseif strcmp(mode, 'en') 
    [train, test] = entry_split(mat, ratio);
elseif strcmp(mode, 'u') 
    [train, test] = item_split(mat.', ratio);
    train = train.';
    test = test.';
elseif strcmp(mode, 'i') 
    [train, test] = item_split(mat, ratio);
else
    error('Unsupported split mode...');
end

end

% user-oriented split or item-oriented split
function [train, test] = normal_split(mat, ratio)
[M, N] = size(mat);
matt = mat.';
train_cell = cell(M, 1); % M¡Á1 cell array
test_cell = cell(M, 1);
for u=1:M
    rows = matt(:,u);
    [J,I,V] = find(rows); % row-column-value
    samples = randsample(length(J), round(ratio * length(J)));
    bit = false(length(J),1);
    bit(samples) = true;
    train_cell{u} = [u * I(bit), J(bit), V(bit)];
    test_cell{u} = [u * I(~bit), J(~bit), V(~bit)];
end
train_index = cell2mat(train_cell);
test_index = cell2mat(test_cell);
train = sparse(train_index(:,1), train_index(:,2), train_index(:,3), M, N);
test  = sparse(test_index(:,1), test_index(:,2), test_index(:,3), M, N);
% train
end

% entry-oriented split
function [train, test] = entry_split(mat, ratio)
[M, N] = size(mat);
[I,J,V] = find(mat);
indi = datasample(1:length(V),round(length(V)*ratio), 'replace', false);
ind = false(1,length(V));
ind(indi) = true;
train = sparse(I(ind), J(ind), V(ind), M, N);
test  = sparse(I(~ind), J(~ind), V(~ind), M, N);
end

% splits users/item into 'folds' folds
function [train_item, test_item] = item_split(mat, ratio)
[~, N] = size(mat);
indi = datasample(1:N, round(N * ratio), 'replace', false);
ind = false(1,N);
ind(indi) = true;
train_item = mat;
train_item(:,~ind) = 0;
test_item = mat;
test_item(:,ind) = 0;
end



