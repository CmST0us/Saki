//
//  LAppOpenGLManager.h
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreImage/CoreImage.h>
#import <OpenGLES/ES3/gl.h>
#import <OpenGLES/ES3/glext.h>
#import <OpenGLES/EAGL.h>

NS_ASSUME_NONNULL_BEGIN

#define LAppGLContextAction(block) [[LAppOpenGLManager sharedInstance] inContext:block];
#define LAppGLContext [LAppOpenGLManager sharedInstance].glContext
#define LAppOpenGLManagerInstance [LAppOpenGLManager sharedInstance]

@interface LAppOpenGLManager : NSObject
@property (nonatomic, readonly) EAGLContext *glContext;

+ (instancetype)sharedInstance;

- (void)setup;
- (void)clean;

- (BOOL)createTexture:(GLuint *)textureID
            withImage:(UIImage *)image;
- (void)releaseTexture:(GLuint)texture;

- (void)inContext:(dispatch_block_t)block;

@end

NS_ASSUME_NONNULL_END
