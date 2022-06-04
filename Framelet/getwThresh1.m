function muLevel=getwThresh1(mu,wLevel,Level,D)
nfilter=1;
nD = size(D,1);
Dec = zeros(len*nD*L,num);
if wLevel<=0
    for ki=1:Level
        for ii=1:nD-1
                muLevel{ki}{ii,jj}=mu*nfilter*norm(D{ii})*norm(D{jj});
        end
        nfilter=nfilter*norm(D{1});
    end
else
    for ki=1:Level
        for ii=1:nD-1
            for jj=1:nD-1
                muLevel{ki}{ii,jj}=mu*nfilter;
            end
        end
        nfilter=nfilter*wLevel;
    end
end