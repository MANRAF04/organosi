/**************************************************************

	The program reads an RGB bitmap image file and uses the K-Means algorithm
	algorithm to compress the image by clustering all pixels
        Author: Nikos Bellas, ECE Department, University of Thessaly, Volos, GR
**************************************************************/

#include "qdbmp.h"     
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include <omp.h>

/* Creates a negative image of the input bitmap file */
int main( int argc, char* argv[] )
{
	BMP*	bmp;
	UINT*   cluster;   /* For each pixel position, it shows the cluster that this pixel belongs */
	UCHAR	r, g, b;
	register UINT    width, height, row, col;
	register UINT    i;
	MEANS*  means;   /* Holds the (R, G, B) means of each cluster  */
	UINT    noClusters;   /* Number of of clusters. It is given by the user */
	UINT    dist, minDist, minCluster, iter = 0, maxIterations = 10;
	UINT    noOfMoves;     /* Total number of inter-cluster moves between two succesive iterations */
	UINT    totr, totb, totg, sizeCluster;

	/* Check arguments */
	if ( __builtin_expect(argc != 4,0) )
	{ 
		fprintf( stderr, "Usage: %s <input file> <output files> <Number of Clusters>\n", argv[ 0 ] );
		return 1;
	}

	/* Read the input (uncompressed) image file */
	bmp = BMP_ReadFile( argv[ 1 ] );
	BMP_CHECK_ERROR( stdout, -1 ); 
    
    
	/* Get image's dimensions */
	width = BMP_GetWidth( bmp );
	height = BMP_GetHeight( bmp );

	noClusters = ( UINT ) atoi(argv[3]);   
	means = (MEANS *) calloc( noClusters, sizeof( MEANS ) );
    
	/* 1. Initialize cluster means with (R, G, B) values from random coordinates of the Input Image*/
	srand (time(NULL));
    for (i = 0; i < noClusters; ++i) {

    	col = rand() % width;
        row = rand() % height;

        /* Get pixel's RGB values */
		BMP_GetPixelRGB( bmp, col, row, &r, &g, &b );

		means[i].r = r;
		means[i].g = g;
		means[i].b = b;
    }
    
    /* The cluster assignement for each pixel */
	cluster = (UINT*) calloc( width*height, sizeof(UINT) );  /* Important to also initialize all entries to 0 */
	if ( __builtin_expect(cluster == NULL,0) )
	{
        free( cluster );
		free( bmp );
		return 1;
	}




    /* Main loop runs at least once */ 
    do {
#pragma omp parallel private(row, col)

    	noOfMoves = 0;
    	++iter; 
    	printf("ITER %ld\n", iter);

        totr = totb = totg = 0;
	   /* 2. Go through each pixel in the input image and calculate its nearest mean. 
	         The output of phase 2 is the cluster* data structure.                    */

		#pragma omp for
		for ( row = 0 ; row < height ; ++row)  {
		  for ( col = 0 ; col < width ; ++col ) {

		
			/* Calculate the location of the relevant pixel (rows are flipped) */
		    /*pixel = bmp->Data + ( ( bmp->Header.Height - row - 1 ) * bytes_per_row + col  * bytes_per_pixel );*/
          
            /* Get pixel's RGB values */
			BMP_GetPixelRGB( bmp, col, row, &r, &g, &b );
			
            minDist = 16384; /* Larger than the lagest possible value (and a power of 2) */ 
			for (i = 0; i < noClusters; ++i) {

                /* Distance metric. May replace with something cheaper */
				dist = (UINT) abs((r+g+b) - (means[i].r + means[i].g + means[i].b));
				minCluster = (dist < minDist) ? i : minCluster;
				minDist = (dist < minDist) ? dist : minDist;

			}

		UINT* currentCluster = cluster + row * width + col;

			if (__builtin_expect(*currentCluster == minCluster,1)) {
				continue;
			}

			*currentCluster = minCluster;

			noOfMoves = 1;

            

		}   /* for */
	   }  /* for */


     /* 3. Update the mean of each cluster based on the pixels assigned to them. */
      if (noOfMoves == 1) {
      	  for (i = 0; i < noClusters; ++i) {

            totr = totb = totg = 0;
            sizeCluster = 0;

		{
			for ( row = 0 ; row < height ; ++row)  {
				{
					for ( col = 0 ; col < width ; ++col ) {

							if (*(cluster+row*width + col) == i) {
								BMP_GetPixelRGB( bmp, col, row, &r, &g, &b );
								totr += r; 
								totg += g;
								totb += b;
								sizeCluster++;
							}
					}
				}
			}
		}
		double reciprocalSizeCluster = 1.0 / sizeCluster;
		means[i].r = (UCHAR)(totr * reciprocalSizeCluster);
    	means[i].g = (UCHAR)(totg * reciprocalSizeCluster);
    	means[i].b = (UCHAR)(totb * reciprocalSizeCluster);

		  }
              
      }

       /* 4. Goto 2 if not convergence and less than a max number of iterations. Else goto 5 */
    } while ((iter < maxIterations) && (noOfMoves == 1));



    for (i = 0; i < noClusters; ++i) {
       printf("means[%lu] = (%d, %d, %d)\n", i, means[i].r, means[i].g, means[i].b);
    }
    

    /* 5. Replace the pixel of the original image with the mean of the corresponding cluster */

	for ( row = 0 ; row < height ; ++row)  {
		for ( col = 0 ; col < width ; ++col ) {
			
			i = *(cluster+row*width + col);
			r = means[i].r;
			g = means[i].g;
			b = means[i].b;
	
		/* Note: colors are stored in BGR order */

		BMP_SetPixelRGB( bmp, col, row, r, g, b );

		}

    }

   /* Write out the output image and finish */
	BMP_WriteFile( bmp, argv[ 2 ] );
	BMP_CHECK_ERROR( stdout, -2 );


	/* Free all memory allocated for the image */
	BMP_Free( bmp );



	return 0;
}