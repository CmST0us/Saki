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
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    [self.glView setContext:LAppGLContext];
    LAppGLContextAction(^{
        self.haru = [[LAppModel alloc] initWithName:@"Haru"];
        [self.haru loadAsset];
        [self.haru startBreath];
    });
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [LAppOpenGLManagerInstance updateTime];
    
    glClear(GL_COLOR_BUFFER_BIT);
    [self.haru setMVPMatrixWithSize:self.screenSize];
    [self.haru onUpdate];
    glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
}

@end
