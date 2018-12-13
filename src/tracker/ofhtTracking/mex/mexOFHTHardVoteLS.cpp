/** Function to do optical flow based on hough transform tracking


Expected inputs:

Outputs:

*/

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

#include "ofhtCommon.h"

using namespace std;
using namespace Eigen;

#define USAGE_NOTE "TODO: This is mex function!"

//typedef pair<int, vector<int> > IdxPair;
typedef pair<string, vector<int> > IdxPair;

//////////////////////////////////////////////////////////////////
inline float inlQuantization(float val, float quan)
{
    val = val / quan;    
    
    int qval = round(val);    

    return qval;
}    

vector<int> quantizeVal(vector<float> inputVec)
{

    float quanScale = QUAN_SCALE;  
    float quanTheta = QUAN_THETA;
    float quanCoor = QUAN_COOR;

    vector<int> quanVec;

    int qscale = inlQuantization(inputVec[0], quanScale);
    int qtheta = inlQuantization(inputVec[1], quanTheta);
    int qdx = inlQuantization(inputVec[2], quanCoor);
    int qdy = inlQuantization(inputVec[3], quanCoor);

    quanVec.push_back(qscale);
    quanVec.push_back(qtheta);
    quanVec.push_back(qdx);
    quanVec.push_back(qdy);

    return quanVec;
}

vector<vector<float> > deQuantizeVal(vector<IdxPair> inputVec, int noOfRetVal)
{
    vector<vector<float> > retVec(noOfRetVal);

    float quanScale = QUAN_SCALE;  
    float quanTheta = QUAN_THETA;
    float quanCoor = QUAN_COOR;

    int noOfEle = inputVec[0].second.size();

    for (int i = 0; i < noOfRetVal; ++i) {
        vector<float> tmpVec(noOfEle);
        
        tmpVec[0] = inputVec[i].second[0] * quanScale;
        tmpVec[1] = inputVec[i].second[1] * quanTheta;
        tmpVec[2] = inputVec[i].second[2] * quanCoor;
        tmpVec[3] = inputVec[i].second[3] * quanCoor;
        tmpVec[4] = inputVec[i].second[4];
        
        retVec[i] = tmpVec;
    }

    return retVec;
}

vector<vector<float> > calcLeastSquare(
    vector<IdxPair> sortInd, 
    int noOfRetVal,
    map< string, set<int> > hashVoteList,
    float *prevPt,
    float *currPt,
    int noOfPt)
{
    vector<vector<float> > retVec(noOfRetVal);

    for (int i = 0; i < noOfRetVal; ++i) {
        string hashCode = sortInd[i].first;

        set<int> voteList = hashVoteList[hashCode];

        int noOfVote = voteList.size();

        MatrixXf A(2*noOfVote, 4);
        VectorXf b(2*noOfVote);

        int r = 0;
        for (set<int>::iterator it = voteList.begin(); it != voteList.end(); ++it) {

            int idxi = *it;

            A(r*2, 0) = prevPt[idxi];
            A(r*2, 1) = -prevPt[idxi+noOfPt];
            A(r*2, 2) = 1.0f;
            A(r*2, 3) = 0.0f;

            A(r*2+1, 0) = prevPt[idxi+noOfPt];
            A(r*2+1, 1) = prevPt[idxi];
            A(r*2+1, 2) = 0.0f;
            A(r*2+1, 3) = 1.0f;

            b(r*2) = currPt[idxi];
            b(r*2+1) = currPt[idxi + noOfPt];

            r++;
        }

        //solve least square by Eigen
        //VectorXf x = A.jacobiSvd(ComputeThinU | ComputeThinV).solve(b);

        VectorXf x = A.fullPivHouseholderQr().solve(b);

        // cout << "Least square results: " << endl;
        // cout << x << endl;

        //calcuate scale and theta
        retVec[i] = calcScaleAndTheta(x);

        retVec[i].push_back((float)sortInd[i].second[4]);

        //prepare the return value

    } //for (int i = 0; i < noOfRetVal; ++i) { ...

    return retVec;
}

//DESCEND
// inline bool comparator(const IdxPair& l, const IdxPair& r)
// {   
//     return l.first > r.first; 
// }


inline bool comparator(const IdxPair& l, const IdxPair& r)
{   
    return l.second[4] > r.second[4]; 
}

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    float minDist = 25.f;

    map< string, vector<int> > hashTable;
    map< string, set<int> > hashVoteList;

    vector<IdxPair> sortInd;
    int loopNum = 0;
    vector<vector<float> > retVal;

    if (nrhs == 3) {
        double *tmp = (double *)mxGetData(prhs[2]);
        minDist = (float)tmp[0]; 
        //mexPrintf("minDist = %0.02f\n", minDist);       
    }    

    //check input variable
    if (nrhs == 3 || nrhs == 2) {
        if (mxGetClassID(prhs[0]) != mxSINGLE_CLASS || 
            mxGetClassID(prhs[1]) != mxSINGLE_CLASS) {
            mexErrMsgTxt(USAGE_NOTE);
        }

        int noOfPrevPt = mxGetM(prhs[0]);
        int noOfCurrPt = mxGetM(prhs[1]);

        //mexPrintf("noOfPrevPt = %d, noOfCurrPt = %d\n", noOfPrevPt, noOfCurrPt);

        if (noOfPrevPt != noOfCurrPt) {
            mexErrMsgTxt("The number of matched points is invalid!");
        }

        float *prevPt = (float *)mxGetData(prhs[0]);
        float *currPt = (float *)mxGetData(prhs[1]);

        //DEBUG - show all the points
        // for (int i = 0; i < noOfPrevPt; ++i) {
        //     mexPrintf("%0.02f, %0.02f\n", prevPt[i], prevPt[i+noOfPrevPt]);
        // }
        // mexPrintf("noOfPrevPt: %d, noOfCurrPt: %d\n", noOfPrevPt, noOfCurrPt);

        //fix bug: at least two points should be collected for hough voting
        int noOfValidPts = 0;
        while (1) {
            for (int i = 0; i < noOfPrevPt; ++i) {
                for (int j = i+1; j < noOfCurrPt; ++j) {
                    if (eDist(prevPt[i], prevPt[i+noOfPrevPt], 
                          prevPt[j], prevPt[j+noOfPrevPt]) > minDist) {
                        noOfValidPts = noOfValidPts + 2;
                    }
                }
            } 
            //mexPrintf("noOfValidPts = %d\n", noOfValidPts);

            if (noOfValidPts > 2) {
                break;
            } else {
                minDist = minDist / 2.0;
                mexPrintf("Shrink! minDist = %0.03f\n", minDist);   //potential problem
            }   

            if (minDist <= 2.0f) {
                break;
            }        

        }

        //return with empty matrix
        if (minDist <= 2.0) {
            mxArray *retMatrix = mxCreateNumericMatrix(0, 0, mxSINGLE_CLASS, mxREAL);
            mxArray *retLoopNum = mxCreateNumericMatrix(0, 0, mxINT32_CLASS, mxREAL);

            mexPrintf("Not enough valid points for ofht estimation!\n");
            
            plhs[0] = retMatrix;
            plhs[1] = retLoopNum;

            return;
        }

                
        for (int i = 0; i < noOfPrevPt; ++i) {
            for (int j = i+1; j < noOfCurrPt; ++j) {
                
                if (eDist(prevPt[i], prevPt[i+noOfPrevPt], 
                          prevPt[j], prevPt[j+noOfPrevPt]) < minDist) {
                    continue;
                }

                loopNum++;
                //mexPrintf("loopNum = %d\n", loopNum);

                vector<float> vec = calcTransMatrix(prevPt, currPt, 
                                                    i, j, noOfPrevPt);    

                vector<int> quanVec = quantizeVal(vec);

                //DEBUG - show quantified vector results
                // for (int i = 0;  i < quanVec.size(); ++i){
                //     mexPrintf("%0.02f\t%d\n", vec[i], quanVec[i]);
                // }                

                string hashCode = genHashCode(quanVec);
                
                if (hashTable.find(hashCode) == hashTable.end()) {
                    //mexPrintf("Could not find the key!\n");

                    quanVec.push_back(1);
                    hashTable[hashCode] = quanVec;

                    set<int> tmpSet;
                    tmpSet.insert(i);
                    tmpSet.insert(j);
                    hashVoteList[hashCode] = tmpSet;

                } else {
                    hashTable[hashCode][4]++;

                    hashVoteList[hashCode].insert(i);
                    hashVoteList[hashCode].insert(j);

                }

                //DEBUG - check hashing results
                // vector<int> checkVec = hashTable[hashCode];

                // for (vector<int>::iterator i = checkVec.begin(); 
                //      i != checkVec.end(); ++i) {
                //     cout << *i << endl;
                // } 
                //return;

            } //for (int j = i+1; j < noOfCurrPt; ++j) { ...
        }//for (int i = 0; i < noOfPrevPt; ++i) {

        //DEBUG - check all hash code
        // for (map<string, vector<int> >::iterator it = hashTable.begin(); 
        //     it != hashTable.end(); ++it) {
            
        //     vector<int> checkVec = it->second;

        //     for (vector<int>::iterator i = checkVec.begin(); 
        //          i != checkVec.end(); ++i) {
        //         mexPrintf("%d ", *i);
        //     }  
        //     mexPrintf("\n");
        // }

        for (map<string, vector<int> >::iterator it = hashTable.begin(); 
             it != hashTable.end(); ++it) {
            
            // vector<int> checkVec = it->second;
            // sortInd.push_back(make_pair(checkVec[4], checkVec));

            //vector<int> checkVec = it->second;
            sortInd.push_back(make_pair(it->first, it->second));
        }

        //DEBUG - show vector pair
        // mexPrintf("Before sorting ...\n");
        // for (int i = 0; i < sortInd.size(); ++i) {
        //     mexPrintf("%s: %d\n", sortInd[i].first.c_str(), sortInd[i].second[4]);
        // }

        //Sort pair results
        sort(sortInd.begin(), sortInd.end(), comparator);

        // mexPrintf("After sorting ...\n");
        // for (int i = 0; i < sortInd.size(); ++i) {
        //     mexPrintf("%s: %d\n", sortInd[i].first.c_str(), sortInd[i].second[4]);
        // }

        //dequantize the results
        int noOfRetVal = MIN(NUM_OF_RET, sortInd.size());

        //use Least Square to calculate reture value
        retVal = calcLeastSquare(sortInd, noOfRetVal, hashVoteList, 
                                 prevPt, currPt, noOfPrevPt);

        //use deQuantizd hard vote results as return value
        //retVal = deQuantizeVal(sortInd, noOfRetVal);

    } else {
        mexErrMsgTxt(USAGE_NOTE);
    }

    //mexPrintf("Total number of hashTable entry: %d\n", sortInd.size());

    //check output vairable
    if (nlhs == 2) {
        //mexPrintf("The output is valid!\n");

        //int height = MIN(NUM_OF_RET, sortInd.size());
        int height = retVal.size();
        //int width = sortInd[0].second.size();
        int width = retVal[0].size();

        mxArray *retMatrix = mxCreateNumericMatrix(height, width, 
                                                   mxSINGLE_CLASS, mxREAL);
        float *retMatrixData = (float *)mxGetData(retMatrix);

        for (int i = 0; i < height; ++i) {
            //mexPrintf("%d: %d\n", sortInd[i].first, sortInd[i].second[4]);

            for (int j = 0; j < width; ++j) {
                int idx = j * height + i;

                //retMatrixData[idx] = sortInd[i].second[j];
                retMatrixData[idx] = retVal[i][j];
            }            
        }

        mxArray *retLoopNum = mxCreateNumericMatrix(1, 1, mxINT32_CLASS, mxREAL);
        int *retLoopNumData = (int *)mxGetData(retLoopNum); 

        retLoopNumData[0] = loopNum;

        plhs[0] = retMatrix;
        plhs[1] = retLoopNum;


    } else {
        mexPrintf("The output is invalid!");
        mexErrMsgTxt(USAGE_NOTE);
    }

    return;

}
