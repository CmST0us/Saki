//
//  LAppBundle.h
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (LAppBundle)
+ (NSBundle *)live2DResourceBundle;
+ (NSBundle *)modelResourceBundleWithName:(NSString *)name;

- (NSString *)model3FilePath;
@end

NS_ASSUME_NONNULL_END
