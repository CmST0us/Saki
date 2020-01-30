//
//  LAppTextureManager.h
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

@interface LAppTextureManager : NSObject

+ (instancetype)sharedInstance;

- (void)setup;
- (void)clean;

- (CVOpenGLESTextureRef)copyOpenGLESTextureWithImage:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
