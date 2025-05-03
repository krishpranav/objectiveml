/**
 * @file MLMatrix+Advanced.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>
#import "Matrix.h"
#import "Matrix+Manipulate.h"
#import "Matrix+Map.h"
#import <Accelerate/Accelerate.h>

@interface Matrix (Advanced)

+ (instancetype)uniformRandomLowerBound:(Matrix *)lower upperBound:(Matrix *)upper;

+ (instancetype)uniformRandomRows:(int)rows columns:(int)columns domain:(YCDomain)domain;

+ (instancetype)uniformRandomLowerBound:(Matrix *)lower
                             upperBound:(Matrix *)upper
                                  count:(int)count;

+ (instancetype)normalRandomMean:(Matrix *)mean variance:(Matrix *)variance;

+ (instancetype)normalRandomRows:(int)rows
                         columns:(int)columns
                            mean:(double)mean
                        variance:(double)variance;

+ (instancetype)normalRandomMean:(Matrix *)mean
                        variance:(Matrix *)variance
                           count:(int)count;

+ (instancetype)sobolSequenceLowerBound:(Matrix *)lower
                             upperBound:(Matrix *)upper
                                  count:(int)count;

+ (instancetype)haltonSequenceWithLowerBound:(Matrix *)lower
                                  upperBound:(Matrix *)upper
                                       count:(int)count;

- (Matrix *)pseudoInverse;

- (NSDictionary *)SVD;

- (Matrix *)solve:(Matrix *)B;

- (void)cholesky;

- (Matrix *)matrixByCholesky;

- (Matrix *)realEigenvalues;

- (NSDictionary *)eigenvectorsAndEigenvalues;

- (double)determinant;

- (Matrix *)sumsOfRows;

- (Matrix *)sumsOfColumns;

- (Matrix *)meansOfRows;

- (Matrix *)meansOfColumns;

- (Matrix *)variancesOfRows;

- (Matrix *)variancesOfColumns;

- (Matrix *)sampleVariancesOfRows;

- (Matrix *)sampleVariancesOfColumns;

- (Matrix *)minimumsOfRows;

- (Matrix *)maximumsOfRows;

- (Matrix *)minimumsOfColumns;

- (Matrix *)maximumsOfColumns;

- (Matrix *)matrixByApplyingFunction:(double (^)(double value))function;

- (void)applyFunction:(double (^)(double value))function;

- (double)euclideanDistanceTo:(Matrix *)other;

- (double)quadranceTo:(Matrix *)other;

- (void)bernoulli;

@end
