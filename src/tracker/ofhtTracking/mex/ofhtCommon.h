#include <iostream>
#include <vector>
#include <map>
#include <set>

#include <math.h>

#include <openssl/md5.h>
#include <Eigen/Dense>

#include <matrix.h>
#include <mex.h>

#include "common.h"

using namespace std;
using namespace Eigen;


///////////////////////////////////////
//Parameter setting
///////////////////////////////////////
float QUAN_SCALE = 0.1f;
float QUAN_THETA = 2.0f;
float QUAN_COOR = 2.0f;

int NUM_OF_RET = 5;


//////////////////////////////////////
#define PI 3.14159265
typedef unsigned char uchar;


//////////////////////////////////////////////////////////////////
inline float eDist(float pt1x, float pt1y, float pt2x, float pt2y)
{
    return sqrt((pt2x-pt1x)*(pt2x-pt1x) + (pt2y-pt1y)*(pt2y-pt1y));
}

vector<float> calcScaleAndTheta(VectorXf x)
{
    vector<float> ret(4);

    float scale, theta;

    if (abs(x(0)) < 0.00001) {
        theta = 0.5f;
    } else {
        theta = atan2(x(1), x(0));
    }

    scale = x(0) / cos(theta); 

    theta = theta * 180 / PI;
    
    ret[0] = scale;
    ret[1] = theta;    
    ret[2] = x(2);
    ret[3] = x(3);

    //DEBUG - show the return vec
    // for (int i = 0; i < ret.size(); ++i) {
    //     mexPrintf("%0.02f\t", ret[i]);
    // }
    // mexPrintf("\n");

    return ret;
}

vector<float> calcTransMatrix(
    float *prevPt, 
    float *currPt, 
    int   idxi, 
    int   idxj, 
    int   noOfPt)
{

    MatrixXf A(4,4);
    VectorXf b(4);

    A << prevPt[idxi],        -prevPt[idxi+noOfPt], 1.0, 0.0, 
         prevPt[idxi+noOfPt], prevPt[idxi],         0.0, 1.0, 
         prevPt[idxj],        -prevPt[idxj+noOfPt], 1.0, 0.0, 
         prevPt[idxj+noOfPt], prevPt[idxj],         0.0, 1.0;

    b << currPt[idxi], currPt[idxi+noOfPt], currPt[idxj], currPt[idxj+noOfPt];      

    VectorXf x = A.fullPivLu().solve(b);
    //VectorXf x = A.colPivHouseholderQr().solve(b);
    //VectorXf x = A.partialPivLu().solve(b);
    
    // cout << "A:" << endl;
    // cout << A << endl;

    // cout << "b:" << endl;
    // cout << b << endl;

    // cout << "x:" << endl;
    // cout << x << endl;
  
    return calcScaleAndTheta(x);
}

string genHashCode(vector<int> &vec)
{
    int *data = vec.data();
    uchar hash[MD5_DIGEST_LENGTH];

    MD5((uchar*)data, sizeof(int) * vec.size(), (uchar*)hash);

    // for (int i = 0; i < MD5_DIGEST_LENGTH; ++i) {
    //     mexPrintf("%02x ", hash[i]);
    // }
    // mexPrintf("\n");                

    //Convert HEX to string
    char hashString[2 * MD5_DIGEST_LENGTH];

    for (int i = 0; i < MD5_DIGEST_LENGTH; i++) {
        snprintf(hashString + 2*i, 3, "%02x", hash[i]);
    
        //printf("hash[iter] = %02x\n",hash[iter]);
        //printf("hashString = %s\n",hashString);
    }
    
    string hashCode(hashString);

    return hashCode;
}


