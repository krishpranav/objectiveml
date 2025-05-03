/**
 * @file MLDenseLayer.h
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <Foundation/Foundation.h>
#import "MLTensor.h"

@interface MLDenseLayer : NSObject

@property (nonatomic, strong) MLTensor *weights;
@property (nonatomic, strong) MLTensor *bias;

@end
