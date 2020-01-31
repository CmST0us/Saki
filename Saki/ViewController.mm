//
//  ViewController.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import "CubismModelMatrix.hpp"
#import "ViewController.h"
#import "LAppModel.h"
#import "LAppBundle.h"
#import "LAppOpenGLManager.h"
@interface ViewController ()
@property (nonatomic) GLKView *glView;
@property (nonatomic, strong) LAppModel *haru;
@property (nonatomic, assign) CGSize screenSize;
@end

@implementation ViewController

- (GLKView *)glView {
    return (GLKView *)self.view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.glView setContext:LAppGLContext];
    LAppGLContextAction(^{
        self.haru = [[LAppModel alloc] initWithName:@"Hiyori"];
        [self.haru loadModel];
        [self.haru loadTexture];
    });
    /// 设置尺寸
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    
    LAppGLContextAction(^{
        glClearColor(0, 0, 0, 0);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
        glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);

        glEnable(GL_BLEND);
        glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    });
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClear(GL_COLOR_BUFFER_BIT);
    [self.haru setMVPMatrixWithSize:self.screenSize];
    [self.haru onUpdate];
}

@end
