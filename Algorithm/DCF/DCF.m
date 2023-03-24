function [B,D,X,Y] = DCF(S, varargin)
% SIGIR16-Discrete Collaborative Filtering
%  maxS: max rating score
%  minS: min rating score
%  S: user-item score matrix, [m,n] = size(S)
%  ST: transpose of ST, for efficient sparse matrix indexing in Matlab, i.e.,
%  matlab can only efficiently access sparse matrix by column.
%  IDX: nonzero (observed) entry index of S
%  IDXT: transpose of IDX for efficient sparse matrix indexing in Matlab.
%  r: bit length
%  alpha: trade-off paramter. good default = 0.001.
%  beta: trade-off paramter. good default = 0.001.
%  option:
      %option.maxItr: max iterations. Default = 50.
      %option.maxItr2: max iteration for cylic binary loop. Default = 5.
      %option.tol: tolerance. Default = 1e-5.
      %option.debug: show obj? Default = false.

% Output:
%   B: user codes
%   D: item codes
%   X: surrogate user vector
%   Y: surrogate item vector

% Reference:
%   Hanwang Zhang, Fumin Shen, Wei Liu, Xiangnan He, Huanbo Luan, Tat-seng
%   Chua. "Discrete Collaborative Filtering", SIGIR 2016

% Version: 1.0
% Written by Hanwang Zhang (hanwangzhang AT gmail.com)

    [r,maxS,minS,alpha,beta,maxItr,Init,debug] = process_options(varargin, 'r', 8, 'maxS',5, 'minS',1, 'alpha', 0.0001, 'beta', 0.0001, 'max_iter', 50,...
                                                                      'init', false, 'debug', true);

    fprintf('DCF (K=%d, max_iter=%d, alpha=%f, beta=%f)\n', r, maxItr, alpha, beta);
    ST = S';
    IDX = (S~=0);
    IDXT = IDX';
    [m,n] = size(S);
    maxItr2 = 5;

    it = 1;
    converge = false;

    if Init
        [U,V,X0,Y0] = DCFinit(S, r, alpha, beta, []);
        B0 = sign(U); B0(B0 == 0) = 1;
        D0 = sign(V); D0(D0 == 0) = 1;
    else
        rng(1);
        U = rand(r,m);
        V = rand(r,n);
        B0 = sign(U); B0(B0 == 0) = 1;
        D0 = sign(V); D0(D0 == 0) = 1;
        X0 = UpdateSVD(B0);
        Y0 = UpdateSVD(D0); 
    end


    B = B0;
    D = D0;
    X = X0;
    Y = Y0;
    
    while ~converge
        B0 = B;
        D0 = D;
        for i = 1:m
            d = D(:,IDXT(:,i));  % select volumns(logic of IDXT == 1)   d-(r,volumns)
            b = B(:,i);
            DCDmex(b,d*d',d*ScaleScore(nonzeros(ST(:,i)),r,maxS,minS), alpha*X(:,i),maxItr2);
            B(:,i) = b;
        end
        for j = 1:n
            b = B(:,IDX(:,j));
            d = D(:,j);
            DCDmex(d,b*b',b*ScaleScore(nonzeros(S(:,j)),r,maxS,minS), beta*Y(:,j),maxItr2);
            D(:,j)=d;
        end
        X = UpdateSVD(B);
        Y = UpdateSVD(D);

        disp(['DCF at ',int2str(r),' bit Iteration:',int2str(it)]);
        if debug
            [loss,obj] = DCFobj(maxS,minS,S,IDX,B,D,X,Y,alpha,beta);
            disp(['loss = ',num2str(loss),',  obj = ',num2str(obj)]);
        end


        if it >= maxItr || (sum(sum(B~=B0)) == 0 && sum(sum(D~=D0)) == 0)
            converge = true;
        end

        it = it+1;

    end
    B=B';D=D';

end
% end: function [B,D,X,Y] = DCF(...)


% Dicrete Collaborative Filtering Object Function
function [loss,obj] = DCFobj(maxS,minS,S,IDX,B,D,X,Y,alpha,beta)
    [~,n] = size(S);
    r = size(B,1);
    loss = zeros(1,n);

    % n: item
    for j = 1:n
        dj = D(:,j);
        Bj = B(:,IDX(:,j));
        BBj = Bj*Bj';
        term1 = dj'*BBj*dj;
        Sj = ScaleScore(nonzeros(S(:,j)),r,maxS,minS);
        term2 = 2*dj'*Bj*Sj;
        term3 = sum(Sj.^2);
        loss(j) = term1-term2+term3;
    end

    loss = sum(loss);
    % loss = sqrt(loss/nnz(S));

    obj = loss-2*alpha*trace(B*X')-2*beta*trace(D*Y') ;
    % obj = loss + alpha*norm(X-B,'fro').^2 + beta*norm(Y-D, 'fro').^2;

end
% end: function [loss,obj] = DCFobj(...)


function s = ScaleScore(s,scale, maxS,minS)
    %ScaleScore: scale the scores in user-item rating matrix to [-scale,+scale]. See footnote 2.
    % s = s - mean(s);
    % return
    if maxS ~= minS
        s = (s-minS)/(maxS-minS);
        s = 2*scale*s-scale;
    else
        s = s .* scale ./ maxS;
    end
end