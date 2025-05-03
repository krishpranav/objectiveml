/**
 * @file MLHaltonInterface.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>

@class Matrix;

@interface HaltonInterface : NSObject

+ (Matrix *)sampleWithDimension:(int)dimension count:(int)count;

@end
