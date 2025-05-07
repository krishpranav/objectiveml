/**
 * @file MLMissingValue.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import "MLMissingValue.h"

MLMissingValue *uniValue;

@implementation MLMissingValue

+ (instancetype)missingValue
{
    if (!uniValue) {
        uniValue = [[MLMissingValue alloc] init];
    }

    return uniValue;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [MLMissingValue missingValue];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {}

@end
