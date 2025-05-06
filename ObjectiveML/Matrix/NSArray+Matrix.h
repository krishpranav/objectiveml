/**
 * @file NSArray+Matrix.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-06
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>
#import "Matrix.h"

@interface NSArray (Matrix)

@property (readonly) Matrix *matrixSum;

@property (readonly) Matrix *matrixProduct;

@property (readonly) Matrix *matrixMean;

@property (readonly) Matrix *matrixMax;

@property (readonly) Matrix *matrixMin;

@end
