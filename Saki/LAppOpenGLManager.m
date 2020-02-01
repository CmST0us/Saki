//
//  LAppOpenGLManager.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import "LAppOpenGLManager.h"

@interface LAppOpenGLManager () {
    CVOpenGLESTextureCacheRef _textureCache;
}
@property (nonatomic, assign) NSTimeInterval currentFrame;
@property (nonatomic, assign) NSTimeInterval lastFrame;
@property (nonatomic, assign) NSTimeInterval deltaTime;

@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CIContext *ciContext;

/// GLuint: CVOpenGLESTexture
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, id> *textureMap;
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
    
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES3];
    [EAGLContext setCurrentContext:_glContext];
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                 NULL,
                                 self.glContext,
                                 NULL,
                                 &_textureCache);
    
    _ciContext = [CIContext contextWithOptions:nil];
    _textureMap = [[NSMutableDictionary alloc] init];
}

- (void)clean {
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
    
}

- (BOOL)createTexture:(GLuint *)textureID withImage:(UIImage *)image {
    if (textureID == nil ||
        image == nil) {
        return NO;
    }
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CGFloat width = ciImage.extent.size.width;
    CGFloat height = ciImage.extent.size.height;
    
    NSDictionary *pixelBufferAttribute = @{
        (id)kCVPixelBufferOpenGLESCompatibilityKey: @(YES),
        (id)kCVPixelBufferOpenGLESTextureCacheCompatibilityKey: @(YES)
    };
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width,
                        height,
                        kCVPixelFormatType_32BGRA,
                        (__bridge CFDictionaryRef)pixelBufferAttribute,
                        &pixelBuffer);
    
    [self.ciContext render:ciImage toCVPixelBuffer:pixelBuffer];
    
    CVOpenGLESTextureRef texture;
    CVOpenGLESTextureCacheCreateTextureFromImage(kCFAllocatorDefault,
                                                 _textureCache,
                                                 pixelBuffer,
                                                 NULL,
                                                 GL_TEXTURE_2D,
                                                 GL_RGBA,
                                                 width,
                                                 height,
                                                 GL_BGRA,
                                                 GL_UNSIGNED_BYTE,
                                                 0,
                                                 &texture);
    
    CFRelease(pixelBuffer);
    if (texture) {
        GLuint tID = CVOpenGLESTextureGetName(texture);
        *textureID = tID;
        CVOpenGLESTextureRef currentTexture = (__bridge CVOpenGLESTextureRef)(self.textureMap[@(tID)]);
        if (currentTexture) {
            CFRelease(currentTexture);
        }
        self.textureMap[@(tID)] = (__bridge id)texture;
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
