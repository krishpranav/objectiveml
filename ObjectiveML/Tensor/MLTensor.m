/**
 * @file MLTensor.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>
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

- (void)randomize {
    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < self.cols; j++) {
            self.data[i][j] = @( ((float)arc4random() / UINT32_MAX) * 2 - 1 );
        }
    }
}

- (MLTensor *)dot:(MLTensor *)other {
    if (self.cols != other.rows) {
        NSLog(@"Matrix dimension mismatch!");
        return nil;
    }

    MLTensor *result = [[MLTensor alloc] initWithRows:self.rows cols:other.cols];

    for (int i = 0; i < self.rows; i++) {
        for (int j = 0; j < other.cols; j++) {
            float sum = 0.0;
            
            for (int k = 0; k < self.cols; k++) {
                sum += [self.data[i][k] floatValue] * [other.data[k][j] floatValue];
            }

            result.data[i][j] = @(sum);
        }
    }

    return result;
}

- (void)print {
    for (NSArray *row in self.data) {
        NSMutableString *rowStr = [NSMutableString string];

        for (NSNumber *val in row) {
            [rowStr appendFormat:@"%.2f ", [val floatValue]];
        }

        NSLog(@"%@", rowStr);
    }
}

@end
