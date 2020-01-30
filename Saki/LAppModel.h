//
//  LAppModel.h
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface LAppModel : NSObject
- (nullable instancetype)initWithName:(NSString *)name;

- (void)loadModel;
- (void)loadTexture;
@end

NS_ASSUME_NONNULL_END
