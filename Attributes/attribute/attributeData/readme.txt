Font Attribute Dataset

Peter O'Donovan
odonovan@dgp.toronto.edu

---------------------------------------

The dataset includes 200 rendered images of fonts, along with relative attribute data.
This data accompanies the following paper. If you use this data, please cite this paper.
Peter O'Donovan, Jānis Lībeks, Aseem Agarwala, Aaron Hertzmann. 
Exploratory Font Selection Using Crowdsourced Attributes 
ACM Transactions on Graphics
2014, 33, 4, (Proc. SIGGRAPH).

The following dataset is released under the Creative Commons license: 
Attribution-NonCommercial (CC BY-NC)
---------------------------------------

Similarity data is given in pairwise from, where users specified which of two fonts was 
had more or less of the given attribute


images/: rendered images for each font
userChoices.csv: individual user responses for the pair. The format is hit id,
	user id, font A name, font B name, and user choice (more/less)

Attributes and geometric features are also provided for each font. 

estimatedAttributes.csv: estimated attribute vector for each font
vecFeatures.csv: feature vector for each font