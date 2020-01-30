//
//  LAppTextureManager.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import "LAppTextureManager.h"

@interface LAppTextureManager () {
    CVOpenGLESTextureCacheRef _textureCache;
}
@property (nonatomic, strong) EAGLContext *glContext;
@property (nonatomic, strong) CIContext *ciContext;
@end

@implementation LAppTextureManager

+ (instancetype)sharedInstance {
    static LAppTextureManager *manager;
    @synchronized (self) {
        if (manager == nil) {
            manager = [[LAppTextureManager alloc] init];
        }
        return manager;
    }
}

- (void)setup {
    _glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
    CVOpenGLESTextureCacheCreate(kCFAllocatorDefault,
                                 NULL,
                                 self.glContext,
                                 NULL,
                                 &_textureCache);
    
    _ciContext = [CIContext contextWithOptions:nil];
}

- (void)clean {
    if (_textureCache) {
        CFRelease(_textureCache);
        _textureCache = NULL;
    }
    
}

- (CVOpenGLESTextureRef)copyOpenGLESTextureWithImage:(UIImage *)image {
    CIImage *ciImage = [[CIImage alloc] initWithImage:image];
    CGFloat width = ciImage.extent.size.width;
    CGFloat height = ciImage.extent.size.height;
    
    CVPixelBufferRef pixelBuffer;
    CVPixelBufferCreate(kCFAllocatorDefault,
                        width,
                        height,
                        kCVPixelFormatType_32BGRA,
                        NULL,
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
                                                 GL_RGBA,
                                                 GL_UNSIGNED_BYTE,
                                                 0,
                                                 &texture);
    
    CFRelease(pixelBuffer);
    return texture;
}
@end
