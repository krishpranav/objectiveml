/**
 * @file ObjectiveMLTests.m
 * @author Krisna Pranav
 * @version 1.0
 * @date 2025-05-03
 *
 * @copyright Copyright (c) 2025 Krisna Pranav
 *
 */

#import <XCTest/XCTest.h>
#import "MLTensor.h"
#import "MLDenseLayer.h"

@interface ObjectiveMLTests : XCTestCase
@end

@implementation ObjectiveMLTests

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

#pragma mark - Tensor Tests

- (void)testTensorInitializationAndStructure {
    MLTensor *tensor = [[MLTensor alloc] initWithRows:10 cols:20];
    XCTAssertEqual(tensor.rows, 10);
    XCTAssertEqual(tensor.cols, 20);
    XCTAssertEqual(tensor.data.count, 10);
    for (NSArray *row in tensor.data) {
        XCTAssertEqual(row.count, 20);
    }
}

- (void)testTensorRandomValuesWithinRange {
    MLTensor *tensor = [[MLTensor alloc] initWithRows:10 cols:10];
    [tensor randomize];
    for (NSArray *row in tensor.data) {
        for (NSNumber *num in row) {
            float val = [num floatValue];
            XCTAssertTrue(val >= -1.0 && val <= 1.0);
        }
    }
}

- (void)testTensorAddition {
    MLTensor *a = [[MLTensor alloc] initWithRows:2 cols:2];
    MLTensor *b = [[MLTensor alloc] initWithRows:2 cols:2];

    a.data = [@[@[@1, @2], @[@3, @4]] mutableCopy];
    b.data = [@[@[@5, @6], @[@7, @8]] mutableCopy];

    MLTensor *sum = [a add:b];
    NSArray *expected = @[@[@6, @8], @[@10, @12]];

    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            XCTAssertEqualWithAccuracy([sum.data[i][j] floatValue], [expected[i][j] floatValue], 0.0001);
}

- (void)testTensorTranspose {
    MLTensor *tensor = [[MLTensor alloc] initWithRows:2 cols:3];
    tensor.data = [@[@[@1, @2, @3], @[@4, @5, @6]] mutableCopy];

    MLTensor *transposed = [tensor transpose];
    NSArray *expected = @[@[@1, @4], @[@2, @5], @[@3, @6]];

    XCTAssertEqual(transposed.rows, 3);
    XCTAssertEqual(transposed.cols, 2);

    for (int i = 0; i < 3; i++)
        for (int j = 0; j < 2; j++)
            XCTAssertEqualWithAccuracy([transposed.data[i][j] floatValue], [expected[i][j] floatValue], 0.0001);
}

- (void)testTensorDotProduct {
    MLTensor *a = [[MLTensor alloc] initWithRows:2 cols:3];
    MLTensor *b = [[MLTensor alloc] initWithRows:3 cols:2];

    a.data = [@[@[@1, @2, @3], @[@4, @5, @6]] mutableCopy];
    b.data = [@[@[@7, @8], @[@9, @10], @[@11, @12]] mutableCopy];

    MLTensor *product = [a dot:b];

    NSArray *expected = @[
        @[@(1*7 + 2*9 + 3*11), @(1*8 + 2*10 + 3*12)],
        @[@(4*7 + 5*9 + 6*11), @(4*8 + 5*10 + 6*12)]
    ];

    XCTAssertEqual(product.rows, 2);
    XCTAssertEqual(product.cols, 2);

    for (int i = 0; i < 2; i++)
        for (int j = 0; j < 2; j++)
            XCTAssertEqualWithAccuracy([product.data[i][j] floatValue], [expected[i][j] floatValue], 0.0001);
}

- (void)testTensorMismatchDotProductFails {
    MLTensor *a = [[MLTensor alloc] initWithRows:2 cols:3];
    MLTensor *b = [[MLTensor alloc] initWithRows:4 cols:2]; // Invalid

    XCTAssertThrowsSpecificNamed([a dot:b], NSException, NSInvalidArgumentException);
}

#pragma mark - Dense Layer Tests

- (void)testDenseLayerForwardProp {
    MLDenseLayer *dense = [[MLDenseLayer alloc] initWithInputSize:3 outputSize:2];

    MLTensor *input = [[MLTensor alloc] initWithRows:1 cols:3];
    input.data = [@[@[@1.0, @2.0, @3.0]] mutableCopy];

    // Manually set weights and biases for predictable results
    dense.weights.data = [@[
        @[@0.1, @0.2],
        @[@0.3, @0.4],
        @[@0.5, @0.6]
    ] mutableCopy];
    dense.biases.data = [@[@0.5, @-0.5] mutableCopy];

    MLTensor *output = [dense forward:input];

    float expected0 = 1.0*0.1 + 2.0*0.3 + 3.0*0.5 + 0.5;  // Neuron 1
    float expected1 = 1.0*0.2 + 2.0*0.4 + 3.0*0.6 - 0.5;  // Neuron 2

    XCTAssertEqual(output.rows, 1);
    XCTAssertEqual(output.cols, 2);
    XCTAssertEqualWithAccuracy([output.data[0][0] floatValue], expected0, 0.0001);
    XCTAssertEqualWithAccuracy([output.data[0][1] floatValue], expected1, 0.0001);
}

- (void)testMultipleDenseLayers {
    MLTensor *input = [[MLTensor alloc] initWithRows:1 cols:4];
    input.data = [@[@[@1, @2, @3, @4]] mutableCopy];

    MLDenseLayer *layer1 = [[MLDenseLayer alloc] initWithInputSize:4 outputSize:3];
    MLDenseLayer *layer2 = [[MLDenseLayer alloc] initWithInputSize:3 outputSize:2];

    MLTensor *output1 = [layer1 forward:input];
    MLTensor *output2 = [layer2 forward:output1];

    XCTAssertEqual(output2.rows, 1);
    XCTAssertEqual(output2.cols, 2);
}

- (void)testPerformanceOfMatrixMultiplication {
    [self measureBlock:^{
        MLTensor *a = [[MLTensor alloc] initWithRows:100 cols:200];
        MLTensor *b = [[MLTensor alloc] initWithRows:200 cols:300];
        [a randomize];
        [b randomize];

        MLTensor *result = [a dot:b];
        XCTAssertEqual(result.rows, 100);
        XCTAssertEqual(result.cols, 300);
    }];
}

@end
