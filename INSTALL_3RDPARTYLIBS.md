Installing 3rd party libraries
------------------------------

For convenience, we provide packages with all the required 3rd party libraries
adapted to our framework, except **Eigen3** and **openssl**. They are located in 
the folders `src/3rdparty` and `src/tracker/3rdparty_script`. The libraries provided
in `src/3rdparty` are the same as provided by the original authors, except for some name 
changes and removal of unused files for convenience. In `src/tracker/3rdparty_script`,
we provide codes that include our modifications. The packages also include compiled mex files
for Linux (Xubuntu 16.04). All the packages were downloaded on April 21, 2016.

We use the following 3rd party libraries:
- [Thomas Brox's optical flow](http://lmb.informatik.uni-freiburg.de/resources/binaries/pami2010Matlab.zip)
- [Deqing Sun's optical flow](http://cs.brown.edu/people/dqsun/code/cvpr10_flow_code.zip)
- [Piotr Dollar's Toolbox](https://github.com/pdollar/toolbox)
- [Piotr Dollar's SedToolbox](https://github.com/pdollar/edges)
- [Philipp Weinzaepfel's Motion Boundaries](http://pascal.inrialpes.fr/data2/motionboundaries/MotionBoundariesCode_v1.0.tar.gz)
    * [LDOF models for Motion Boundaries](http://pascal.inrialpes.fr/data2/motionboundaries/model_SintelClean_LDOF.zip)


Manual installation
-------------------
Should you need to install the 3rd party libraries by yourself, you can do so
by following the next steps (updated on April 21, 2016). If you find difficulties
you can try looking at our provided package to see if your folder hierarchy
is correct.

- Thomas Brox's optical flow, Deqing Sun's optical flow and Piotr Dollar's Toolbox
  * extract their contents to the `src/3rdparty` folder

- Piotr Dollar's SedToolbox
  * extract its contents to the `src/3rdparty` folder
  * follow the instructions included in their readme to compile the mex files

- Philipp Weinzaepfel's Motion Boundaries
  * extract its contents to the `src/3rdparty` folder
  * follow the instructions included in their readme to compile the mex files
  * in order to avoid a naming conflict with Piotr Dollar's SedToolbox, we add 
    the "mb" prefix to three files:
    - rename edgesChns.m to mbEdgesChns.m
    - rename edgesDetect.m to mbEdgesDetect.m
    - rename the compiled edgesDetectMex to mbEdgesDetectMex
  * the source code of mbEdgesChns.m and mbEdgesDetect.m must also be edited
    to account for the naming changes. We provide SED commands that can be
    used in Linux terminal to replace the contents automatically:
    - sed -i.bak -e 's/edgesDetect/mbEdgesDetect/g' -e 's/edgesChns/mbEdgesChns/g' mbEdgesDetect.m 
    - sed -i.bak s/edgesChns/mbEdgesChns/g mbEdgesChns.m
  * download the LDOF models and extract them to the folder where the
    other models are in the Motion Boundary package.

- calcEdgeBoxScore (with our modifications)
  * follow the instructions included in the readme file in `src/tracker/3rdparty_script`
    to compile the mex files
    
