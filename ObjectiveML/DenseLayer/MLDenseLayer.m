/**
 * @file MLDenseLayer.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>
#import "MLDenseLayer.h"

@implementation MLDenseLayer

- (instancetype)initWithInputSize:(NSInteger)input outputSize:(NSInteger)output {
    self = [super init]

    if (self) {
        _weights = [[MLTensor alloc] initWithRows:input cols:output];
        [_weights randomize];

        _bias = [[MLTensor alloc] initWithRows:1 cols:output];
        [_bias randomize];
    }

    return self;
}

- (MLTensor *)forward:(MLTensor *)input {
    
}

@end
