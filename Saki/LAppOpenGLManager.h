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
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <OpenGLES/EAGL.h>
#import <GLKit/GLKit.h>

NS_ASSUME_NONNULL_BEGIN

#define LAppGLContextAction(block) [[LAppOpenGLManager sharedInstance] inContext:block];
#define LAppGLContext [LAppOpenGLManager sharedInstance].glContext
#define LAppOpenGLManagerInstance [LAppOpenGLManager sharedInstance]

@interface LAppOpenGLManager : NSObject
@property (nonatomic, readonly) EAGLContext *glContext;
@property (nonatomic, readonly) NSTimeInterval deltaTime;
+ (instancetype)sharedInstance;

- (void)setup;
- (void)clean;

#pragma mark - Texture

- (BOOL)createTexture:(GLuint *)textureID
         withFilePath:(NSString *)filePath;
- (void)releaseTexture:(GLuint)texture;

- (void)inContext:(dispatch_block_t)block;

#pragma mark - Time
- (void)updateTime;

@end

NS_ASSUME_NONNULL_END
