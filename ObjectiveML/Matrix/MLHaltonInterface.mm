/**
 * @file MLHaltonInterface.mm
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "HaltonInterface.h"
#import "Matrix.h"
#import "halton_sampler.h"

@implementation HaltonInterface

+ (Matrix *)sampleWithDimension:(int)dimension count:(int)count
{
    Halton_sampler halton_sampler;
    halton_sampler.init_faure();

    Matrix *result = [Matrix matrixOfRows:dimension columns:count];

    for (unsigned i = 0; i < dimension; ++i) // Iterate over rows.
    {
        for (unsigned j = 0; j < count; ++j) // Iterate over columns.
        {
            [result i:i j:j set:halton_sampler.sample(i, j)];
        }
    }
    return result;
}

@end
