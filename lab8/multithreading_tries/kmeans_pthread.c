/**************************************************************

        The program reads an RGB bitmap image file and uses the K-Means
algorithm algorithm to compress the image by clustering all pixels Author: Nikos
Bellas, ECE Department, University of Thessaly, Volos, GR
**************************************************************/

/**************************************************************
 * 	Optimized by:
 * 			Zachariadis Charalampos 	03734
 * 		 	Raftopoulos Emmanouil		03735
 **************************************************************/

#include "qdbmp.h"
#include <pthread.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

#define MAX_THREADS 2

UCHAR r, g, b;
MEANS *means; /* Holds the (R, G, B) means of each cluster  */
BMP *bmp;
UINT *cluster;  /* For each pixel position, it shows the cluster that this
                 pixel belongs */
int noClusters; /* Number of of clusters. It is given by the user */
UINT width, height;
int noOfMoves; /* Total number of inter-cluster moves between two succesive
                  iterations */
typedef struct limits {
  UINT start_row;
  UINT end_row;
  UINT start_col;
  UINT end_col;
} limits;

void *analyzeIcon(limits *lim);

/* Creates a negative image of the input bitmap file */
int main(int argc, char *argv[]) {
  register UINT row, col;
  register UINT i;
  UINT dist, minDist, minCluster, iter = 0, maxIterations = 7;

  UINT totr, totb, totg, sizeCluster;
  pthread_t t1, t2;
  limits lim1, lim2;

  /* Check arguments */
  if (__builtin_expect(argc != 4, 0)) {
    fprintf(stderr,
            "Usage: %s <input file> <output files> <Number of Clusters>\n",
            argv[0]);
    return 1;
  }

  /* Read the input (uncompressed) image file */
  bmp = BMP_ReadFile(argv[1]);
  BMP_CHECK_ERROR(stdout, -1);

  /* Get image's dimensions */
  width = BMP_GetWidth(bmp);
  height = BMP_GetHeight(bmp);

  noClusters = atoi(argv[3]);
  means = (MEANS *)calloc(noClusters, sizeof(MEANS));

  /* 1. Initialize cluster means with (R, G, B) values from random coordinates
   * of the Input Image*/
  srand(time(NULL));
  for (i = 0; i < noClusters; ++i) {

    col = rand() % width;
    row = rand() % height;

    /* Get pixel's RGB values */
    BMP_GetPixelRGB(bmp, col, row, &r, &g, &b);
    // BMP_GetPixelRGB(bmp, col, row, &rgb);

    means[i].r = r;
    means[i].g = g;
    means[i].b = b;
  }

  /* The cluster assignement for each pixel */
  cluster = (UINT *)calloc(
      width * height,
      sizeof(UINT)); /* Important to also initialize all entries to 0 */
  if (__builtin_expect(cluster == NULL, 0)) {
    free(cluster);
    free(bmp);
    return 1;
  }

  lim1.start_row = 0;
  lim1.end_row = height >> 1;
  lim1.start_col = 0;
  lim1.end_col = width;

  lim2.start_row = height >> 1;
  lim2.end_row = height;
  lim2.start_col = 0;
  lim2.end_col = width;

  /* Main loop runs at least once */

  printf("%ld x %ld\n", width, height);
  do {

    noOfMoves = 0;
    ++iter;
    printf("ITER %ld\n", iter);

    /* 2. Go through each pixel in the input image and calculate its nearest
       mean. The output of phase 2 is the cluster* data structure. */
    pthread_create(&t1, NULL, analyzeIcon, &lim1);
    pthread_create(&t2, NULL, analyzeIcon, &lim2);

    pthread_join(t1, NULL);
    pthread_join(t2, NULL);
    /* 3. Update the mean of each cluster based on the pixels assigned to them.
     */
    if (noOfMoves != 1) {
      break;
    }

    for (i = 0; i < noClusters; ++i) {

      totr = totb = totg = 0;
      sizeCluster = 0;

      for (row = 0; row < height; ++row) {
        for (col = 0; col < width; ++col) {

          if (*(cluster + row * width + col) == i) {
            BMP_GetPixelRGB(bmp, col, row, &r, &g, &b);
            // BMP_GetPixelRGB(bmp, col, row, &rgb);
            totr += r;
            totg += g;
            totb += b;
            sizeCluster++;
          }
        }
      }

      double reciprocalSizeCluster = 1.0 / sizeCluster;
      means[i].r = (UCHAR)(totr * reciprocalSizeCluster);
      means[i].g = (UCHAR)(totg * reciprocalSizeCluster);
      means[i].b = (UCHAR)(totb * reciprocalSizeCluster);
    }

    /* 4. Goto 2 if not convergence and less than a max number of iterations.
     * Else goto 5 */
  } while ((iter < maxIterations) && (noOfMoves == 1));

  for (i = 0; i < noClusters; ++i) {
    printf("means[%lu] = (%d, %d, %d)\n", i, means[i].r, means[i].g,
           means[i].b);
  }

  /* 5. Replace the pixel of the original image with the mean of the
   * corresponding cluster */

  for (row = 0; row < height; ++row) {
    for (col = 0; col < width; ++col) {

      i = *(cluster + row * width + col);
      r = means[i].r;
      g = means[i].g;
      b = means[i].b;

      /* Note: colors are stored in BGR order */

      BMP_SetPixelRGB(bmp, col, row, r, g, b);
    }
  }
  /* Write out the output image and finish */
  BMP_WriteFile(bmp, argv[2]);
  BMP_CHECK_ERROR(stdout, -2);

  /* Free all memory allocated for the image */
  BMP_Free(bmp);

  return 0;
}

void *analyzeIcon(limits *lim) {
  for (register UINT row = lim->start_row; row < lim->end_row; ++row) {
    for (register UINT col = lim->start_col; col < lim->end_col; ++col) {

      /* Calculate the location of the relevant pixel (rows are flipped) */
      /*pixel = bmp->Data + ( ( bmp->Header.Height - row - 1 ) *
       * bytes_per_row
       * + col  * bytes_per_pixel );*/

      /* Get pixel's RGB values */
      BMP_GetPixelRGB(bmp, col, row, &r, &g, &b);
      // BMP_GetPixelRGB(bmp, col, row, &rgb);

      int minDist = 16384; /* Larger than the lagest possible value (and a power
                          of 2) */
      UINT minCluster;
      for (register int i = 0; i < noClusters; ++i) {

        /* Distance metric. May replace with something cheaper */
        UINT dist =
            (UINT)abs((r + g + b) - (means[i].r + means[i].g + means[i].b));
        minCluster = (dist < minDist) ? i : minCluster;
        minDist = (dist < minDist) ? dist : minDist;
      }

      int *currentCluster = cluster + row * width + col;

      if (__builtin_expect(*currentCluster == minCluster, 1)) {
        continue;
      }

      *currentCluster = minCluster;
      noOfMoves = 1;

    } /* for */
  }   /* for */
}