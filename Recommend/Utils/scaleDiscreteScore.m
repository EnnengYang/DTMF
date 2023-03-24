function s = scaleDiscreteScore(s,scale, maxS,minS)
    %ScaleScore: scale the scores in user-item rating matrix to [-scale,+scale]. 
    % s = s - mean(s);
    if maxS ~= minS
        s = (s-minS)/(maxS-minS);
        s = 2*scale*s-scale;
    else
        s = s .* scale ./ maxS;
    end
end