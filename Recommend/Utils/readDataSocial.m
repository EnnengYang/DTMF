function [ data, trust, datasetInfo] = readDataSocial( data_dir,start )
% DataRead: read rating.txt and trust.txt
% data_dir: gives the working directory of ratings.txt and trust.txt files (social recomendation need include trust.txt)
% start == 0 user and item index start with zero
% start == 1 user and item index start with one(default)

data_file = fullfile(data_dir, 'ratings.txt');
trust_file = fullfile(data_dir, 'trust.txt');
f_data = fopen(data_file);
f_trust = fopen(trust_file);
C_train = textscan(f_data, '%f\t%f\t%f');
C_trust = textscan(f_trust,'%f\t%f\t%f');
fclose(f_data);
fclose(f_trust);

if start==0
    % if user and item index start with zero
    numUsers = max(C_train{1}) + 1;
    numItems = max(C_train{2}) + 1;
    data = sparse(C_train{1} + 1, C_train{2} + 1, C_train{3}, numUsers, numItems);
    
    maxUserId=max([max(C_trust{1}),max(C_trust{2}),max(C_train{1})])+1;
    trust = sparse(C_trust{1} + 1, C_trust{2} + 1, C_trust{3}, maxUserId, maxUserId);
    trust = trust(1:numUsers, 1:numUsers); 
else
    numUsers = max(C_train{1});
    numItems = max(C_train{2});
    data = sparse(C_train{1}, C_train{2}, C_train{3}, numUsers, numItems);
    
    maxUserId=max([max(C_trust{1}),max(C_trust{2}),max(C_train{1})]);
    trust = sparse(C_trust{1}, C_trust{2}, C_trust{3}, maxUserId, maxUserId);
    trust = trust(1:numUsers, 1:numUsers);
end

% dataset information
train_number = nnz(data);
trust_number = nnz(trust);

datasetInfo=['DataSet(data_dir=',data_dir,'  rating_number=',num2str(train_number),'  trust_number=',num2str(trust_number) ,...
             '  numUsers=',num2str(numUsers),'  numItems=',num2str(numItems) ,')...'];
         
fprintf('datasetInfo:%s\n',datasetInfo);
end