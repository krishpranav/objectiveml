/**
 * @file MLTensor.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>

@interface MLTensor : NSObject

@property (nonatomic, readonly) NSInteger rows;
@property (nonatomic, readonly) NSInteger cols;
@property (nonatomic, strong) NSMutableArray<NSMutableArray<NSNumber *> *> *data;

- (instancetype)initWithRows:(NSInteger)rows cols:(NSInteger)cols;
- (void)randomize;
- (MLTensor *)dot:(MLTensor *)other;
- (void)print;

@end
