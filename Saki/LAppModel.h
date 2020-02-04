//
//  LAppModel.h
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define kLAppModelDefaultExpressionPriority (3)

typedef NSString * LAppParam;

extern LAppParam const LAppParamAngleX;
extern LAppParam const LAppParamAngleY;
extern LAppParam const LAppParamAngleZ;
extern LAppParam const LAppParamMouthOpenY;

@interface LAppModel : NSObject
@property (nonatomic, readonly) CGFloat canvasWidth;
@property (nonatomic, readonly) CGFloat canvasHeight;

@property (nonatomic, readonly) NSArray<NSString *> *expressionName;

- (nullable instancetype)initWithName:(NSString *)name;

- (void)setMVPMatrixWithSize:(CGSize)size;

- (void)loadAsset;

- (void)startBreath;
- (void)stopBreath;

- (void)startExpressionWithName:(NSString *)expressionName;
- (void)startExpressionWithName:(NSString *)expressionName
                     autoDelete:(BOOL)autoDelete
                       priority:(NSInteger)priority;

- (void)setParam:(LAppParam)param forValue:(NSNumber *)value;
- (void)setParam:(LAppParam)param forValue:(NSNumber *)value width:(CGFloat)width;

- (void)onUpdateWithParameterUpdate:(dispatch_block_t)block;
@end

NS_ASSUME_NONNULL_END
