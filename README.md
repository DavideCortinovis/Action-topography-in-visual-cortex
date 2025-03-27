# Action-topography-in-visual-cortex
Code necessary to reproduce the analysis described in the paper "Investigating action topography in visual cortex and artificial neural networks".

**Authors**
Davide Cortinovis
Nhut Truong
Hans Op de Beeck
Stefania Bracci

**OVERVIEW**
The repository contains the scripts needed to perform the analysis.

**fMRI analysis**
Script1 generates the spheres following a procedure called "vector-of-ROIs". Briefly, a spline is fitted connecting a set of anchor points. The anchor points are determined based on coordinates of selective areas from previous studies. Along the splines, new coordinates are generated (depending on the parameters adopted), and spheres are created around this new coordinates and saved as .nii files.
The following scripts are standard scripts for univariate and multivariate following CosmoMVPA toolbox.
The respository contains a model_vector.mat file nedded for RSA: it contains three column vectors, each representing a different model. The models are shape, animacy, action, the first generated by calculating the aspect ratio of the image, the second and third are generated via behavioral ratings of an independent group of participants.

**DANN analysis**
We used the following GitHub repositories to extract the pretrained models analysed in the paper.

**TDANN**: https://github.com/neuroailab/TDANN contains code to replicate the TDANN analysis, including model checkpoints and positions.
**Moments-in-Time**: https://github.com/zhoubolei/moments_models contains pretrained models needed to replicate the analysis with ResNet (trained with ImageNet and Moments-in-Time).

**REFERENCES**

 - Margalit, E., Lee, H., Finzi, D., DiCarlo, J. J., Grill-Spector, K., & Yamins, D. L. (2024). A unifying framework for  functional organization in early and higher ventral visual cortex. _Neuron_, _112_(14), 2435-2451.
 - Monfort, M., Andonian, A., Zhou, B., Ramakrishnan, K., Bargal, S. A., Yan, T., ... & Oliva, A. (2019). Moments in time dataset: one million videos for event understanding. _IEEE transactions on pattern analysis and machine intelligence_, _42_(2), 502-508.
