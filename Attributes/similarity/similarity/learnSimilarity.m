
%{

Datasets and Code for "Exploratory Font Selection Using Crowdsourced Attributes" ACM TOG, Proc. SIGGRAPH 2014
Peter O'Donovan and Aseem Agarwala and Aaron Hertzmann
 
Distributed under the BSD license.
 
http://creativecommons.org/licenses/by-nc-sa/2.5/ca/
 
Contact: Peter O'Donovan at <odonovan@dgp.toronto.edu>

%}



compCounts=csvread('compsCount.csv');
compCounts=compCounts(:,1:size(compCounts,2)-1);
compCounts(:,1:3)=compCounts(:,1:3)+1;
%compCounts=(fontA,fontB,fontC,countB, countC) 


userChoices=csvread('userChoices.csv');
userChoices=userChoices(:,1:size(userChoices,2)-1);
userChoices(:,2:5)=userChoices(:,2:5)+1;
userChoices(:,6)=1-userChoices(:,6);
%userChoices=(choiceId, userId, fontA,fontB,fontC,choice)   
%choiceId should match the rows of compCounts and fdAB/fdAC


features=csvread('vecFeatures.csv');
features=features(:,1:size(features,2)-1);
features=features-repmat(min(features),200,1);
features=features./repmat(max(features),200,1);
vecFeatures=features;

features=csvread('attrFeatures.csv');
features=features(:,1:size(features,2)-1);
features=features-repmat(min(features),200,1);
features=features./repmat(max(features),200,1);
attrFeatures=features;


features=attrFeatures;
%features=vecFeatures;
%features=[attrFeatures vecFeatures];


nFeatures=size(features,2)


%fdAB/fdAC are the feature differences between fontA/fontB, fontA/fontC for
%each comparisons
fdAB=zeros(size(compCounts,1),nFeatures);
fdAC=zeros(size(compCounts,1),nFeatures);
for i=1:size(fdAB,1)
    fdAB(i,:)=(features(compCounts(i,1),:)-features(compCounts(i,2),:));
    fdAC(i,:)=(features(compCounts(i,1),:)-features(compCounts(i,3),:));
end


numPts=size(fdAC,1)
select=[1:numPts];
select=select(randperm(numPts));


testTrainSplt=0.6*length(select);

trainSel=select(1:testTrainSplt);
testSel=select(testTrainSplt:length(select));


trainUserChoices=userChoices(ismember(userChoices(:,1),trainSel),:);
testUserChoices=userChoices(ismember(userChoices(:,1),testSel),:);

trainCounts=compCounts(trainSel,:);
testCounts=compCounts(testSel,:);



type='weightSubspace'

weights2=[];
if strcmp(type,'weightSubspace')
    weights=rand(nFeatures,7)-0.5;
elseif strcmp(type,'basic')
    weights=[]; 
elseif strcmp(type,'weight')
    weights=ones(nFeatures,1);
end


numUsers=max(userChoices(:,2));


currUserModelling=1

if currUserModelling==1
    userWeights=ones(numUsers,1);
    userModelling=1;
else
    userWeights=[];
    userModelling=0;
end



gradPar=1;

bias=0.1;
sig=4;
initPar=[ weights(:);weights2(:); userWeights(:) ;sig];

par=initPar;

regWeight=0;


[f prob grad]=sigmoidEval(par,fdAB,fdAC,type,features,userModelling,numUsers,trainUserChoices);

f=0;
fTest=0;


fList=[];
probList=[];


maxIter=500;
for i=1:maxIter

    lastgrad=grad;
    lastF=f;


    [f prob grad]=sigmoidEval(par,fdAB,fdAC,type,features,userModelling,numUsers,trainUserChoices);
    [fTest probTest]=sigmoidEval(par,fdAB,fdAC,type,features,userModelling,numUsers,testUserChoices);


    fList=[fList ;f fTest];
    probList=[probList ;prob probTest];


    par=par-grad*gradPar;
    if abs(f-lastF)<10e-07
        break
    end
end
fprintf('\n');


figure(3);clf;
plot(probList)
legend('Train', 'Test')


figure(4);clf;
plot(fList)
legend('Train', 'Test')


%% max error
minWrong=min(trainCounts(:,4),trainCounts(:,5));
totalCnt=sum(trainCounts(:,4)+trainCounts(:,5));
maxTrainErr=1-sum(minWrong)/totalCnt;


minWrong=min(testCounts(:,4),testCounts(:,5));
totalCnt=sum(testCounts(:,4)+testCounts(:,5));
maxTestErr=1-sum(minWrong)/totalCnt;


fprintf('Type: %s, User modelling %i,  f train/test: %.4f/%.4f, classification train/test: %.4f/%.4f, max train/test %.4f/%.4f\n', type, currUserModelling,f ,fTest, prob, probTest,maxTrainErr,maxTestErr);






