function [B,D] = DTMF(S, varargin)
    % Version: 1.0
    % Written by Enneng Yang

    % S:rating matrix
    % varargin: option param
    [r,maxS,minS,alpha,beta,gamma,lambda,maxItr,Init,debug,dataset] = process_options(varargin,'r',8,'maxS',5,'minS',1,'alpha',0.001,'beta',0.001,...
                                                                     'gamma',0.001,'lambda',1,'max_iter',50,'init',false,'debug',true,'dataset','');

    fprintf('DTMF (r=%d, max_iter=%d, alpha=%f, beta=%f, gamma=%f, lambda=%f)\n', r, maxItr, alpha, beta, gamma, lambda);

    % Epinions-665k | Douban
    [ ~, Trust, ~] =  readDataSocial(['./Dataset/',dataset,'/'], 1);  %(Trust) matrix, m*m dimensional
    
    [userId,itemId,r_ui] = find(S);
    
    
    ST = S';
    TrustT = Trust';
    IDX = (S~=0);
    IDXT = IDX';
    IDXtrust = (Trust~=0);
    IDXtrustT = IDXtrust';

    [m,n] = size(S);
    maxItr2 = 5;

    loss_all = zeros(maxItr,1);
    obj_all = zeros(maxItr,1);

    if Init
        [U,V,F,X0,Y0,Z0] = DTMFinit(S,Trust, r, alpha, beta, gamma, lambda,maxItr,maxS,minS,debug);
        B0 = sign(U); B0(B0 == 0) = 1;
        D0 = sign(V); D0(D0 == 0) = 1;
        W0 = sign(F); W0(W0 == 0) = 1;
    else
        rng(1);
        U = rand(r,m);
        V = rand(r,n);
        F = rand(r,m);
        B0 = sign(U); B0(B0 == 0) = 1;
        D0 = sign(V); D0(D0 == 0) = 1;
        W0 = sign(F); W0(W0 == 0) = 1;
        X0 = UpdateSVD(B0);
        Y0 = UpdateSVD(D0); 
        Z0 = UpdateSVD(W0); 
    end

    B = B0;
    D = D0;
    W = W0;
    X = X0;
    Y = Y0;
    Z = Z0;

    disp('Starting DTMF...');
    it = 1;
    converge = false;
    loss0=Inf;
    tol = 1e-5;
    while ~converge
        B0 = B;
        D0 = D;
        W0 = W;
        
        for i = 1:m
            d = D(:,IDXT(:,i)); 
            b = B(:,i);
            w = W(:,IDXtrustT(:,i)); 
            DCDmex_social(b,d*d',d*ScaleScore(nonzeros(ST(:,i)),r,maxS,minS),alpha*X(:,i),maxItr2,...
                            w*w'*lambda,lambda*w*ScaleScore(nonzeros(TrustT(:,i)),r,1,0));
            B(:,i)=b;
        end
        for j = 1:n
            b = B(:,IDX(:,j));
            d = D(:,j);
            DCDmex(d,b*b',b*ScaleScore(nonzeros(S(:,j)),r,maxS,minS), beta*Y(:,j),maxItr2);
            D(:,j)=d;
        end
        for k = 1:m
            b = B(:,IDXtrust(:,k));
            w = W(:,k);
            DCDmex(w,b*b'*lambda,lambda*b*ScaleScore(nonzeros(Trust(:,k)),r,1,0), gamma*Z(:,k),maxItr2);
            W(:,k)=w;
        end

        X = UpdateSVD(B);
        Y = UpdateSVD(D);
        Z = UpdateSVD(W);

        disp(['DTMF at ',int2str(r),' bit Iteration:',int2str(it)]);
        if debug
            [loss,obj] = DTMFobj(maxS,minS,S,Trust,IDX,IDXtrust,B,D,W,X,Y,Z,alpha,beta,gamma,lambda);
            disp(['loss = ',num2str(loss),', obj = ',num2str(obj)]);
            loss_all(it+1) = loss; obj_all(it+1) = obj;
            if abs(loss-loss0)<tol
                converge = true;
            end
            loss0 = loss;
        end

        if it >= maxItr || (sum(sum(B~=B0)) == 0 && sum(sum(D~=D0)) == 0 && sum(sum(W~=W0)) == 0 ) 
            converge = true;
        end

        it = it+1;
    end
    % end: while ~converge

    disp('Ending DTMF...');

    B=B';D=D';
end


% DTMF Object Function
function [loss,obj] = DTMFobj(maxS,minS,S,Trust,IDX,IDXtrust,B,D,W,X,Y,Z,alpha,beta,gamma,lambda)
    [m,n] = size(S); % m:user n:item
    r = size(B,1);
    loss = zeros(1,n);

    % rating
    for j1 = 1:n
        dj = D(:,j1);
        Bj = B(:,IDX(:,j1));
        BBj = Bj*Bj';
        term1 = dj'*BBj*dj;
        Sj = ScaleScore(nonzeros(S(:,j1)),r,maxS,minS);
        term2 = 2*dj'*Bj*Sj;
        term3 = sum(Sj.^2);
        loss(j1) = term1-term2+term3;
    end
    loss = sum(loss);

    % social
    loss_S = zeros(1,m);
    for j2 = 1:m
        wj = W(:,j2);
        Bj = B(:,IDXtrust(:,j2));
        BBj = Bj*Bj';
        term1 = wj'*BBj*wj;
        Tj = ScaleScore(nonzeros(Trust(:,j2)),r,1,0);
        term2 = 2*wj'*Bj*Tj;
        term3 = sum(Tj.^2);
        loss_S(j2) = term1-term2+term3;
    end

    obj_social = lambda*sum(loss_S);
    obj = loss + obj_social - 2*alpha*trace(B*X') - 2*beta*trace(D*Y') - 2*gamma*trace(W*Z');

end


function s = ScaleScore(s,scale, maxS,minS)
    % ScaleScore: scale the scores in user-user similar / user-item rating matrix to [-scale,+scale].
    % s = s - mean(s);
    % return
    if maxS ~= minS
        s = (s-minS)/(maxS-minS);
        s = 2*scale*s-scale;
    else
        s = s .* scale ./ maxS;
    end
end
