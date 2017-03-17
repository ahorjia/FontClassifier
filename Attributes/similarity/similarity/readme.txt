Font Similarity Dataset

Peter O'Donovan
odonovan@dgp.toronto.edu


The following dataset is released under the Creative Commons license: 
Attribution-NonCommercial (CC BY-NC)

The dataset includes 200 rendered images of fonts, along with similarity data between them.
Similarity data is given in triplet from, where users specified which of two fonts was closer
to a reference font. 


images/: rendered images for each font
fontNames.txt: names of each font
compsCount.csv: aggregated comparisons count for the triplets. The format is reference font id, 
			font A id, font B id, # of votes for font A, # of votes for font B
userChoices.csv: individual user responses for the triplet. The format is triplet id,
	user id, reference font id, font A id, font B id, and user choice (0/1)

learnSimilarity.m: matlab code for learning the similarity metric


Attributes and geometric features are also provided for each font. The font ids in the previous files correspond to the line numbers of the following feature files. 

attrNames.txt: names for each of the 37 attributes
attrFeatures.csv: attribute vector for each font
vecFeatures.csv: feature vector for each font