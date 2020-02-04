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
@property (weak, nonatomic) IBOutlet UISlider *headYawSlider;
@property (weak, nonatomic) IBOutlet UISlider *headPitchSlider;
@property (weak, nonatomic) IBOutlet UISlider *headRollSlider;
@property (weak, nonatomic) IBOutlet UISlider *mouthSlider;

@property (nonatomic, assign) CGFloat headYaw;
@property (nonatomic, assign) CGFloat headPitch;
@property (nonatomic, assign) CGFloat headRoll;
@property (nonatomic, assign) CGFloat mouthOpenY;

@property (nonatomic) GLKView *glView;
@property (nonatomic, strong) LAppModel *haru;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) NSInteger expressionCount;

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
        self.expressionCount = self.haru.expressionName.count;
        [self.haru startBreath];
    });
}

- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    [LAppOpenGLManagerInstance updateTime];
    
    glClear(GL_COLOR_BUFFER_BIT);
    [self.haru setMVPMatrixWithSize:self.screenSize];
    [self.haru onUpdateWithParameterUpdate:^{
        [self.haru setParam:LAppParamAngleX forValue:@(self.headYaw)];
        [self.haru setParam:LAppParamAngleY forValue:@(self.headPitch)];
        [self.haru setParam:LAppParamAngleZ forValue:@(self.headRoll)];
        [self.haru setParam:LAppParamMouthOpenY forValue:@(self.mouthOpenY)];
    }];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.expressionCount == 0) return;
    static NSInteger index = 0;
    index += 1;
    if (index == self.expressionCount) {
        index = 0;
    }
    [self.haru startExpressionWithName:self.haru.expressionName[index]];
}

#pragma mark - Action

- (IBAction)handleHeadYawSlideChange:(id)sender {
    self.headYaw = self.headYawSlider.value;
}
- (IBAction)handleHeadPitchSlideChange:(id)sender {
    self.headPitch = self.headPitchSlider.value;
}
- (IBAction)handleHeadRollSlideChange:(id)sender {
    self.headRoll = self.headRollSlider.value;
}
- (IBAction)handleMouthSlideChange:(id)sender {
    self.mouthOpenY = self.mouthSlider.value;
}

@end
