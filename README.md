# Proposal Selection Tracker (PST)

This code implements a method for single-camera, single-target, short-term, causal, model-free tracking, described in our [ICCV 2015 paper](https://hal.inria.fr/hal-01207196/document).

Copyright (c) 2017 Yang Hua, Henrique Morimitsu, Karteek Alahari, Cordelia Schmid, Inria Grenoble Rhône-Alpes, France.

Contact: Yang Hua (yanghuacv[at]gmail.com), Henrique Morimitsu (henriquem87[at]gmail.com)


## Requirements
* [Matlab](http://www.mathworks.com)
* [Matlab Image Processing Toolbox](http://www.mathworks.com/products/image/)
* [Thomas Brox's optical flow [1]](http://lmb.informatik.uni-freiburg.de/resources/binaries/pami2010Matlab.zip)
* [Deqing Sun's optical flow [2]](http://cs.brown.edu/people/dqsun/code/cvpr10_flow_code.zip)
* [Piotr Dollar's Toolbox [3]](https://github.com/pdollar/toolbox)
* [Piotr Dollar's SedToolbox [4]](https://github.com/pdollar/edges)
* [Philippe Weinzaepfel's Motion Boundaries [5]](http://pascal.inrialpes.fr/data2/motionboundaries/MotionBoundariesCode_v1.0.tar.gz)
* Eigen3: Usually available from your Linux distro repository, e.g., in Ubuntu 16.04 you can install with: `sudo apt install libeigen3-dev`
* openssl: Usually available from your Linux distro repository, e.g., in Ubuntu 16.04 you can install with: `sudo apt install libssl-dev`

The code was tested on a machine with Linux Xubuntu 16.04 and Matlab R2014b/R2016a.


## Usage
### Quick start
* Run `src/pst_demo.m` in Matlab
* In case you get MEX files errors, you will need to compile the MEX binaries for your machine:
    * Compile the tracker MEX binaries by running the file `src/compile_mex.m` in Matlab
    * Compile the third-party MEX binaries by following the instructions provided in the respective directories in `src/3rdparty`

### Detailed explanation
Before starting, you may need to install some third-party libraries. We have included all the necessary libraries in this package except **Eigen3** and **openssl**. Should you prefer, you can download and configure each library yourself. Instructions for doing this are available in the file `INSTALL_3RDPARTYLIBS.md`.

You can change certain parameters and configurations in the file `src/tracker/Config.m`. This is not mandatory, and the tracker can be tested without changing the configuration, i.e., by downloading and extracting sequences from the datasets (e.g., VOT, OTB) to the `sequences folder`. We provide a few sample results computed for the OTB video "Crossing" in the `results` folder.

The binary MEX files are compiled in Xubuntu 16.04. If you need to recompile them, run the script `src/compile_mex.m` for tracker MEX files, and also follow the instructions provided in `src/3rdparty`.

If you run into issues when executing `src/pst_demo.m`, you may need to add libstdc++.so.6 in your system environment (i.e., `LD_PRELOAD`). For Xubuntu 16.04, you can set `LD_PRELOAD="/usr/lib/x86_64-linux-gnu/libstdc++.so.6"`.


## Optical flow
The tracker uses optical flow [1] for computing geometry proposals and motion edgeness score. To reduce the computational cost, we provide the option of using pre-computed flows from binary files, in addition to computing them on the fly. Pre-computed optical flows, if available, must be placed in the folder defined by "opticalFlowPath" in the config file.

We can provide pre-computed flows for videos in the OTB, VOT2014 and VOT2015. This is available upon request by email.


## Testing with other sequences
Place the additional video sequences in the folder defined by "datasetPath" in the config file. The easiest way to do this is by adapting your sequences to either the VOT or the OTB standards and then setting the "datasetFormatFlag" in the file `src/tracker/Config.m` to either 'vot' or 'otb' (with quotes) accordingly.


## License
We use the BSD 3-clause license. Check the file license.txt for more details.


## History
* Ver1.1: Release version with better interface and easy-to-use config file
* Ver1.0: Original version for ICCV2015 paper


## References
[1] Thomas Brox, and Jitendra Malik. Large Displacement Optical Flow: Descriptor
    Matching in Variational Motion Estimation. IEEE Transactions on Pattern
    Analysis and Machine Intelligence, 33(3):500-513, 2011.

[2] Deqing Sun, Stefan Roth, and Michael J. Black. Secrets of Optical Flow
    Estimation and Their Principles. In CVPR, 2010.

[3] Piotr Dollar. Piotr's Computer Vision Matlab Toolbox (PMT). [https://github.com/pdollar/toolbox](https://github.com/pdollar/toolbox).

[4] C. Lawrence Zitnick, and Piotr Dollar. Edge Boxes: Locating Object Proposals from Edges. In ECCV, 2014.

[5] Philippe Weinzaepfel, Jerome Revaud, Zaid Harchaoui and Cordelia Schmid.
    Learning to Detect Motion Boundaries. In CVPR, 2015.
     
    
