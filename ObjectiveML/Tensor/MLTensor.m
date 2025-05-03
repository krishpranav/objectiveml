/**
 * @file MLTensor.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "MLTensor.h"

@implementation MLTensor

- (instancetype)initWithRows:(NSInteger)rows cols:(NSInteger)cols {
    self = [super init];

    if (self) {
        _rows = rows;
        _cols = cols;
        _data = [NSMutableArray arrayWithCapacity:rows];

        for (int i = 0; i < rows; i++) {
            NSMutableArray *row = [NSMutableArray arrayWithCapacity:cols];

            for (int j = 0; j < cols; j++) {
                [row addObject:@0.0];
            }

            [_data addObject:row];
        }
    }

    return self;
}

@end
