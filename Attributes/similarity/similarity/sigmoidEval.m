function [f frac gradient]= sigmoidEval(params,fdAB,fdAC,type,features,userModelling,nUsers,userChoices)




sigpar=4;   

if (userModelling>0)
    workerOffset=length(params)-nUsers-1;
    userReliabilityWeights=params(workerOffset+1: length(params)-1);
    weights=params(1:length(params)-nUsers-1);
else
    weights=params(1:length(params)-1);
    workerOffset=length(params);
end

gradient=zeros(size(params));

nFeatures=size(features,2);

if strcmp(type, 'basic')
    
    wfdAB= fdAB;
    wfdAC= fdAC;
    
elseif strcmp(type, 'weight')
    
    weightRep=repmat(weights,1,size(fdAB,1))';
    wfdAB= weightRep.*fdAB;
    wfdAC= weightRep.*fdAC;
    
    
elseif strcmp(type, 'weightSubspace')
    
    subspaceWeights=reshape(weights,size(fdAB,2), length(weights)/size(fdAB,2));
    nSubspace=size(subspaceWeights,2);
    subspaceGrad=zeros(size(subspaceWeights));
    
    wfdAB= fdAB*subspaceWeights;
    wfdAC= fdAC*subspaceWeights;
    
    
end


wdAB=sqrt(sum(wfdAB.*wfdAB,2));
wdAC=sqrt(sum(wfdAC.*wfdAC,2));

dists=wdAC-wdAB;


if (userModelling>0)
    userWeights=userReliabilityWeights(userChoices(:,2));
else
    userWeights=1;
end

select=userChoices(:,1);
    
userChoice=userChoices(:,6);
distances=dists(select);

d=sigpar*userWeights.*distances;


%%calculate the gradient
eWDiffInc = exp(d) +1;
eWDiffIncRev = exp(-d) +1;

aT = userWeights./eWDiffInc		;
aTT = -(userWeights)./eWDiffIncRev;

wT = (sigpar*distances)./eWDiffInc;
wTT = -(sigpar*distances)./eWDiffIncRev;

aa = aT.*(userChoice) + aTT.*(1-userChoice);
ww =  wT.*(userChoice) + wTT.*(1-userChoice) ;


distRepAB=repmat(wdAB,1,nFeatures);
distRepAC=repmat(wdAC,1,nFeatures);

if strcmp(type, 'weight')


    bDiffsSqr=(fdAB.*fdAB)./distRepAB;
    cDiffsSqr=(fdAC.*fdAC)./distRepAC;
    bcDiff=cDiffsSqr-bDiffsSqr;

    allDiffs=bcDiff(select,:);

    for i=1:nFeatures
        gradient(i)=gradient(i)+-sigpar*params(i)*(sum(aa.*allDiffs(:,i)));
    end


elseif strcmp(type, 'weightSubspace')

    for j=1:nSubspace

        bDiffsSqr=(fdAB.*repmat(wfdAB(:,j),1,nFeatures))./distRepAB;
        cDiffsSqr=(fdAC.*repmat(wfdAC(:,j),1,nFeatures))./distRepAC;
        bcDiff=cDiffsSqr-bDiffsSqr;

        allDiffs=bcDiff(select,:);

        for i=1:nFeatures
            subspaceGrad(i,j)=subspaceGrad(i,j)+-sigpar*(sum(aa.*allDiffs(:,i)));
        end

    end

    subspaceGrad2=subspaceGrad(:);
    gradient(1:size(subspaceGrad2,1))=subspaceGrad2;
end

if (userModelling>0)
    for i=1:nUsers
        gradient(workerOffset+i)=-sum(ww(i==userChoices(:,2)));
    end
end

gradient=gradient/size(userChoices,1);


%% calculate the likelihood and fraction of correctly classified

offset=0.0001;
sig=1./(1+exp(-d));
sig(sig==0)=offset;
sig(sig==1)=1-offset;

numComps=length(sig);

frac=sum((sig>=0.5).*userChoice + (sig<0.5).*(1-userChoice))./numComps;

f=-sum(log(sig).*(userChoice) + log(1-sig).*(1-userChoice) )./numComps;


