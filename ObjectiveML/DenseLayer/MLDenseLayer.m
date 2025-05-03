/**
 * @file MLDenseLayer.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "MLDenseLayer.h"

@implementation MLDenseLayer

- (instancetype)initWithInputSize:(NSInteger)input outputSize:(NSInteger)output {
    self = [super init];

    if (self) {
        _weights = [[MLTensor alloc] initWithRows:input cols:output];
        [_weights randomize];

        _bias = [[MLTensor alloc] initWithRows:1 cols:output];
        [_bias randomize];
    }
    return self;
}

- (MLTensor *)forward:(MLTensor *)input {
    MLTensor *z = [input dot:self.weights];
    
    for (int i = 0; i < z.rows; i++) {
        for (int j = 0; j < z.cols; j++) {
            float val = [z.data[i][j] floatValue] + [self.bias.data[0][j] floatValue];
            z.data[i][j] = @(val);
        }
    }
    
    return z;
}

@end

