
#include <stdio.h>
#include <float.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <assert.h>

#include "mex.h"

//#include "../../mex/common.h"
#include "E:/»úÆ÷Ñ§Ï°/PST/PST/PST_v1.1/src/tracker/ofhtTracking/mex/common.h"


//data structure
typedef enum RegionType {
    SPECIAL = 1, 
    RECTANGLE, 
    POLYGON
} RegionType;

typedef struct Polygon {
    int count;

    float* x;
    float* y;
} Polygon;

typedef struct Rectangle {
    float x;
    float y;
    float width;
    float height;
} Rectangle;

typedef struct Region {
    enum RegionType type;
    union {
        Rectangle rectangle;
        Polygon polygon;
        int special;
    } data;
} Region;

typedef struct Overlap {
    float overlap;    
    float only1;
    float only2;
} Overlap;

typedef struct Bounds {
    float top;
    float bottom;
    float left;
    float right;
} Bounds;

#define MAX_MASK 4000

//internal functions
Region* __create_region(RegionType type) 
{

    Region* reg = (Region*) malloc(sizeof(Region));

    reg->type = type;

    return reg;

}

Region* region_create_polygon(int count) 
{

    assert(count > 0);

    {

        Region* reg = __create_region(POLYGON);

        reg->data.polygon.count = count;
        reg->data.polygon.x = (float *) malloc(sizeof(float) * count);
        reg->data.polygon.y = (float *) malloc(sizeof(float) * count);

        return reg;

    }
}

Region* get_polygon(const mxArray * input) 
{
    
    Region* p = NULL;
    double *r = (double*)mxGetPr(input);
    int l = mxGetN(input);
    
    if (l % 2 == 0 && l > 6) {
        
        p = region_create_polygon(l / 2);
        
        for (int i = 0; i < p->data.polygon.count; i++) {
            p->data.polygon.x[i] = r[i*2];
            p->data.polygon.y[i] = r[i*2+1];
        }
        
    } else if (l == 4) {
        
        p = region_create_polygon(4);
        
        p->data.polygon.x[0] = r[0];
        p->data.polygon.x[1] = r[0] + r[2];
        p->data.polygon.x[2] = r[0] + r[2];
        p->data.polygon.x[3] = r[0];

        p->data.polygon.y[0] = r[1];
        p->data.polygon.y[1] = r[1];
        p->data.polygon.y[2] = r[1] + r[3];
        p->data.polygon.y[3] = r[1] + r[3];
   
    }  
    
    return p;
    
}

Bounds compute_bounds(Polygon* polygon) 
{

    int i;
    Bounds bounds;
    bounds.top = MAX_MASK;
    bounds.bottom = -MAX_MASK;
    bounds.left = MAX_MASK;
    bounds.right = -MAX_MASK;

    for (i = 0; i < polygon->count; i++) {
        bounds.top = MIN(bounds.top, polygon->y[i]);
        bounds.bottom = MAX(bounds.bottom, polygon->y[i]);
        bounds.left = MIN(bounds.left, polygon->x[i]);
        bounds.right = MAX(bounds.right, polygon->x[i]);
    }

    return bounds;

}

void region_release(Region** region) {

    switch ((*region)->type) {
        case RECTANGLE:
            break;
        case POLYGON:
            free((*region)->data.polygon.x);
            free((*region)->data.polygon.y);
            (*region)->data.polygon.count = 0;
            break;
    }

    free(*region);

    *region = NULL;

}

void free_polygon(Polygon* polygon) 
{

    free(polygon->x);
    free(polygon->y);

    polygon->x = NULL;
    polygon->y = NULL;

    polygon->count = 0;

}

Polygon* allocate_polygon(int count) 
{

    Polygon* polygon = (Polygon*) malloc(sizeof(Polygon));

    polygon->count = count;

    polygon->x = (float*) malloc(sizeof(float) * count);
    polygon->y = (float*) malloc(sizeof(float) * count);

    memset(polygon->x, 0, sizeof(float) * count);
    memset(polygon->y, 0, sizeof(float) * count);

    return polygon;
}

Polygon* clone_polygon(Polygon* polygon) 
{

    Polygon* clone = allocate_polygon(polygon->count);

    memcpy(clone->x, polygon->x, sizeof(float) * polygon->count);
    memcpy(clone->y, polygon->y, sizeof(float) * polygon->count);

    return clone;
}

Polygon* offset_polygon(Polygon* polygon, float x, float y) {

    int i;
    Polygon* clone = clone_polygon(polygon);

    for (i = 0; i < clone->count; i++) {
        clone->x[i] += x;
        clone->y[i] += y;
    }

    return clone;
}

void rasterize_polygon(Polygon* polygon, char* mask, int width, int height) 
{

    int nodes, pixelY, i, j, swap;

    int* nodeX = (int*) malloc(sizeof(int) * polygon->count);

    memset(mask, 0, width * height * sizeof(char));

    /*  Loop through the rows of the image. */
    for (pixelY = 0; pixelY < height; pixelY++) {

        /*  Build a list of nodes. */
        nodes = 0;
        j = polygon->count - 1;

        for (i = 0; i < polygon->count; i++) {
            if (polygon->y[i] < (double) pixelY && polygon->y[j] >= (double) pixelY ||
                     polygon->y[j] < (double) pixelY && polygon->y[i] >= (double) pixelY) {
                nodeX[nodes++] = (int) (polygon->x[i] + (pixelY - polygon->y[i]) /
                     (polygon->y[j] - polygon->y[i]) * (polygon->x[j] - polygon->x[i])); 
            }
            j = i; 
        }

        /* Sort the nodes, via a simple â€œBubbleâ€?sort. */
        i = 0;
        while (i < nodes-1) {
            if (nodeX[i]>nodeX[i+1]) {
                swap = nodeX[i];
                nodeX[i] = nodeX[i+1];
                nodeX[i+1] = swap; 
                if (i) i--; 
            } else {
                i++; 
            }
        }

        /*  Fill the pixels between node pairs. */
        for (i=0; i<nodes; i+=2) {
            if (nodeX[i] >= width) break;
            if (nodeX[i+1] > 0 ) {
                if (nodeX[i] < 0 ) nodeX[i] = 0;
                if (nodeX[i+1] > width) nodeX[i+1] = width - 1;
                for (j = nodeX[i]; j < nodeX[i+1]; j++)
                    mask[pixelY * width + j] = 1; 
            }
        }
    }

    free(nodeX);

}

float compute_polygon_overlap(
    Polygon* p1, 
    Polygon* p2, 
    float *only1, 
    float *only2) 
{

    int i;
    int mask_1 = 0;
    int mask_2 = 0;
    int mask_intersect = 0;

    Bounds b1 = compute_bounds(p1);
    Bounds b2 = compute_bounds(p2);

    float x = MIN(b1.left, b2.left);
    float y = MIN(b1.top, b2.top);

    int width = (int) (MAX(b1.right, b2.right) - x);    
    int height = (int) (MAX(b1.bottom, b2.bottom) - y);

    // printf("x = %f, y = %f\n", x, y);
    // printf("width = %d, height = %d\n", width, height);

    char* mask1 = (char*) malloc(sizeof(char) * width * height);
    char* mask2 = (char*) malloc(sizeof(char) * width * height);

    Polygon* op1 = offset_polygon(p1, -x, -y);
    Polygon* op2 = offset_polygon(p2, -x, -y);
/*
print_polygon(p1);print_polygon(p2);
print_polygon(op1);print_polygon(op2);
*/
    rasterize_polygon(op1, mask1, width, height); 
    rasterize_polygon(op2, mask2, width, height); 

    // printf("mask1 value: \n");
    // for (i = 0; i < width * height; i++) {
    //     printf("%d ", mask1[i]);
    // }    

    // printf("mask2 value: \n");
    // for (i = 0; i < width * height; i++) {
    //     printf("%d ", mask2[i]);
    // }

    for (i = 0; i < width * height; i++) {
        if (mask1[i] && mask2[i]) mask_intersect++;
        else if (mask1[i]) mask_1++;
        else if (mask2[i]) mask_2++;
    }

    free_polygon(op1);
    free_polygon(op2);

    free(mask1);
    free(mask2);

    if (only1)
        (*only1) = (float) mask_1 / (float) (mask_1 + mask_2 + mask_intersect);

    if (only2)
        (*only2) = (float) mask_2 / (float) (mask_1 + mask_2 + mask_intersect);

    // printf("intersection: %d, mask_1: %d, mask_2: %d\n", mask_intersect, mask_1, mask_2);

    return (float) mask_intersect / (float) (mask_1 + mask_2 + mask_intersect);

}

#define COPY_POLYGON(TP, P) { P.count = TP->data.polygon.count; P.x = TP->data.polygon.x; P.y = TP->data.polygon.y; }

Overlap region_compute_overlap(Region* ra, Region* rb) {

    Region* ta = ra;
    Region* tb = rb;
    Overlap overlap;
    overlap.overlap = 0;
    overlap.only1 = 0;
    overlap.only2 = 0;

    // if (ra->type == RECTANGLE)
    //     ta = region_convert(ra, POLYGON);
            
    // if (rb->type == RECTANGLE)
    //     tb = region_convert(rb, POLYGON);

    if (ta->type == POLYGON && tb->type == POLYGON) {

        Polygon p1, p2;

        COPY_POLYGON(ta, p1);
        COPY_POLYGON(tb, p2);

        overlap.overlap = compute_polygon_overlap(&p1, &p2, &(overlap.only1), &(overlap.only2));

    }

    if (ta != ra)
        region_release(&ta);

    if (tb != rb)
        region_release(&tb);

    return overlap;

}

//gate function
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) 
{

    Region* p1;
    Region* p2;

    if( nrhs != 2 ) mexErrMsgTxt("Two vector arguments (regions) required.");
    if( nlhs != 1 ) mexErrMsgTxt("Exactly one output argument required.");

    for (int i = 0; i < 2; i++) {
        // TODO: accept integer for special frames
        if (mxGetClassID(prhs[i]) != mxDOUBLE_CLASS) {
            mexErrMsgTxt("All input arguments must be of type double");
        }

        // mexPrintf("Number of dimension: %d, number of column: %d\n", 
        //           mxGetNumberOfDimensions(prhs[i]), mxGetM(prhs[i]));

        if ( mxGetNumberOfDimensions(prhs[i]) > 2 || mxGetM(prhs[i]) > 1 ) {
            mexErrMsgTxt("All input arguments must be vectors");
        }    

    }

    p1 = get_polygon(prhs[0]);
    p2 = get_polygon(prhs[1]);
    
    plhs[0] = mxCreateDoubleMatrix(1, 3, mxREAL);
    double *result = (double*) mxGetPr(plhs[0]);
            
    if (p1 && p2) {
        
        Overlap overlap = region_compute_overlap(p1, p2);

        result[0] = overlap.overlap;
        result[1] = overlap.only1;
        result[2] = overlap.only2;
        
    } else {
        
        result[0] = mxGetNaN();
        result[1] = mxGetNaN();
        result[2] = mxGetNaN();
        
    }
    
    if (p1) region_release(&p1);
    if (p2) region_release(&p2);

}

