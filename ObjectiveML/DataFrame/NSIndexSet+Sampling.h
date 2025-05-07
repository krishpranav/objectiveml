/**
 * @file NSIndexSet+Sampling.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-07
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>

@interface NSIndexSet (Sampling)

+ (instancetype)indexesForSampling:(NSUInteger)samples inRange:(NSRange)range replacement:(BOOL)replacement;

@end
