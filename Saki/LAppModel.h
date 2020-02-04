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

- (void)onUpdate;
@end

NS_ASSUME_NONNULL_END
