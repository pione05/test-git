Tracking-By-Detection Demo
--------------------------
This code implements popular tracking-by-detection framework with HOG + linear SVM. Some functions are adopted and modified from [1].

If you use this code, please consider to cite
* Yang Hua, Karteek Alahari, and Cordelia Schmid. Online Object Tracking with
Proposal Selection. In ICCV 2015.
* J. S. Supancic III and D. Ramanan. Self-paced learning for long-term tracking. In CVPR, 2013


Usage
-----
* Compile all mex files with compile_tbd.m.
* Run demo with tbd_demo.m


3rd Party library
-----------------
* features_32d.cc: HOG feature extractor. It adopts from [2].
* platt.m: Probabilistic outputs for support vector machines [3]. The matlab implementation is downloaed from
http://www.work.caltech.edu/~htlin/program/libsvm/
* uninit.c: Create an uninitialized variable (like ZEROS but faster). The code is downloaded from
http://fr.mathworks.com/matlabcentral/fileexchange/31362-uninit-create-an-uninitialized-variable--like-zeros-but-faster-/content/uninit.m


References
----------
[1] J. S. Supancic III and D. Ramanan. Self-paced learning for long-term tracking. In CVPR, 2013

[2] P. F. Felzenszwalb, R. B. Girshick, D. McAllester, and D. Ramanan. Object
detection with discriminatively trained part-based models. IEEE Trans-
actions on Pattern Analysis and Machine Intelligence, 32(9):1627–1645,
2010.

[3] J. C. Platt. Probabilistic outputs for support vector machines and compar-
isons to regularized likelihood methods. Advances in Large Margin
Classifiers, 10(3):61–74, 1999.
