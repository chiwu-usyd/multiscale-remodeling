# multiscale-remodeling
A machine learning based multiscale model to predict bone formation in synthetic scaffolds

This code uses neural networks to predict bone formation in synthetic scaffolds. We are sorry that the code is a little bit messy as we are not good at coding. The code can be used to predict bone remodeling restuls in synthetic scaffolds in a multi-level way. Therefore, it enables to inversly identify the bone remodeling related parameters from clinical data. 

In order to run the machine learning based multiscale bone remodeling program. This is what you need
1. Abaqus v2016
2. Matlab R2020b

In order to create the virtual X-ray data in Abaqus, this is what you need
1. An abaqus plugin tool which can downloaded from https://github.com/mhogg/pyvxray.git

In order to analyse the virtual X-ray data and clincal X-ray data, You can run the open source code in ipython notebook which can be downloaded in this repository.

The custom matlab code for multiscale bone remodeling can be found in the folder "multiscale-remodeling". Unfortunately, the trained neural networks are too big to be hosted here. So we have put them here  https://drive.google.com/drive/folders/1Dteb8bhjuBMeho3HAvBt5TXYDxNG-iuA?usp=sharing
