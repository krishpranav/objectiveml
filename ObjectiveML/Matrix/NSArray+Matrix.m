/**
 * @file NSArray+Matrix.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-06
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "NSArray+Matrix.h"

@implementation NSArray (Matrix)

- (Matrix *)matrixSum
{
    Matrix *result;
    for (Matrix *m in self)
    {
        NSAssert([m isKindOfClass:[Matrix class]], @"Array element is not a matrix");
        if (!result)
        {
            result = [m copy];
        }
        else
        {
            [result add:m];
        }
    }
    return result;
}

- (Matrix *)matrixMean
{
    Matrix *result = [self matrixSum];
    [result multiplyWithScalar:1.0 / (double)self.count];
    return result;
}

- (Matrix *)matrixProduct
{
    Matrix *result;
    for (Matrix *m in self)
    {
        NSAssert([m isKindOfClass:[Matrix class]], @"Array element is not a matrix");
        if (!result)
        {
            result = [m copy];
        }
        else
        {
            [result elementWiseMultiply:m];
        }
    }
    return result;
}

- (Matrix *)matrixMax
{
    Matrix *result;
    for (Matrix *m in self)
    {
        NSAssert([m isKindOfClass:[Matrix class]], @"Array element is not a matrix");
        if (!result)
        {
            result = [m copy];
        }
        else
        {
            for (int i=0, n=(int)result.count; i<n; i++)
            {
                double maxValue = -DBL_MAX;
                for (Matrix *m in self)
                {
                    maxValue = MAX(maxValue, [m i:i j:0]);
                }
                [result i:i j:0 set:maxValue];
            }
        }
    }
    return result;
}

- (Matrix *)matrixMin
{
    Matrix *result;
    for (Matrix *m in self)
    {
        NSAssert([m isKindOfClass:[Matrix class]], @"Array element is not a matrix");
        if (!result)
        {
            result = [m copy];
        }
        else
        {
            for (int i=0, n=(int)result.count; i<n; i++)
            {
                double minValue = DBL_MAX;
                for (Matrix *m in self)
                {
                    minValue = MIN(minValue, [m i:i j:0]);
                }
                [result i:i j:0 set:minValue];
            }
        }
    }
    return result;
}

@end
