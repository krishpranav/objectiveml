/**
 * @file NSIndexSet+Sampling.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-07
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "NSIndexSet+Sampling.h"

#define ARC4RANDOM_MAX      0x100000000

@implementation NSIndexSet (Sampling)

+ (instancetype)indexesForSampling:(NSUInteger)samples inRange:(NSRange)range replacement:(BOOL)replacement
{
    NSMutableIndexSet *selectedIndexes = [NSMutableIndexSet indexSet];

    if (replacement) {
        NSUInteger N = range.length;
        for (NSUInteger i=0; i<samples; i++) {
            [selectedIndexes addIndex:range.location + (int)(N * (double)arc4random() / ARC4RANDOM_MAX)];
        }
    } else {
        NSUInteger N = range.length;
        NSUInteger i = 0;
        NSUInteger n = MIN(N, samples);

        while (n > 0) {
            if (N * (double)arc4random() / ARC4RANDOM_MAX <= n) {
                [selectedIndexes addIndex:range.location + i];
                n--;
            }

            i++;
            N--;
        }
    }
    return selectedIndexes;
}

@end
