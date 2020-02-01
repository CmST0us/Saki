//
//  LAppOpenGLManager.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import "LAppOpenGLManager.h"

@interface LAppOpenGLManager () {
    
}
@property (nonatomic, assign) NSTimeInterval currentFrame;
@property (nonatomic, assign) NSTimeInterval lastFrame;
@property (nonatomic, assign) NSTimeInterval deltaTime;

@property (nonatomic, strong) EAGLContext *glContext;

/// GLuint: GLKTextureInfo
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, GLKTextureInfo *> *textureMap;
@end

@implementation LAppOpenGLManager

+ (instancetype)sharedInstance {
    static LAppOpenGLManager *manager;
    @synchronized (self) {
        if (manager == nil) {
            manager = [[LAppOpenGLManager alloc] init];
        }
        return manager;
    }
}

- (void)setup {
    [self updateTime];
    
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    [EAGLContext setCurrentContext:_glContext];
    _textureMap = [[NSMutableDictionary alloc] init];
}

- (void)clean {
    [self.textureMap removeAllObjects];
}

- (BOOL)createTexture:(GLuint *)textureID withImage:(UIImage *)image {
    if (textureID == nil ||
        image == nil) {
        return NO;
    }
    CGImageRef cgImage = image.CGImage;
    GLKTextureInfo *textureInfo = [GLKTextureLoader textureWithCGImage:cgImage options:nil error:nil];
    if (textureInfo) {
        GLuint tID = textureInfo.name;
        *textureID = tID;
        self.textureMap[@(tID)] = textureInfo;
        return YES;
    }
    return NO;
}

- (void)releaseTexture:(GLuint)texture {
    CVOpenGLESTextureRef currentTexture = (__bridge CVOpenGLESTextureRef)(self.textureMap[@(texture)]);
    if (currentTexture) {
        CFRelease(currentTexture);
    }
    [self.textureMap removeObjectForKey:@(texture)];
}

- (void)inContext:(dispatch_block_t)block {
    EAGLContext *currentContext = [EAGLContext currentContext];
    EAGLContext *workingContext = nil;
    if (currentContext == self.glContext) {
        workingContext = currentContext;
    } else {
        workingContext = self.glContext;
    }
    
    [EAGLContext setCurrentContext:workingContext];
    if (block) {
        block();
    }
    [EAGLContext setCurrentContext:currentContext];
}

#pragma mark - Time
- (void)updateTime {
    NSDate *now = [NSDate date];
    NSTimeInterval unixtime = [now timeIntervalSince1970];
    self.currentFrame = unixtime;
    self.deltaTime = self.currentFrame - self.lastFrame;
    self.lastFrame = self.currentFrame;
}
@end
