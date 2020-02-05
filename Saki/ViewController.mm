//
//  ViewController.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <ARKit/ARKit.h>
#import <SceneKit/SceneKit.h>
#import <OpenGLES/EAGL.h>
#import <OpenGLES/ES2/gl.h>
#import <Vision/Vision.h>
#import "MPControlValueLinear.h"

#import "CubismModelMatrix.hpp"
#import "ViewController.h"
#import "LAppModel.h"
#import "LAppBundle.h"
#import "LAppOpenGLManager.h"
@interface ViewController () <ARSessionDelegate>
@property (weak, nonatomic) IBOutlet UISlider *ASlider;
@property (weak, nonatomic) IBOutlet UISlider *BSlider;
@property (weak, nonatomic) IBOutlet UISlider *CSlider;
@property (weak, nonatomic) IBOutlet UISlider *DSlider;

@property (nonatomic, assign) CGFloat headYaw;
@property (nonatomic, assign) CGFloat headPitch;
@property (nonatomic, assign) CGFloat headRoll;
@property (nonatomic, assign) CGFloat mouthOpenY;
@property (nonatomic, assign) CGFloat eyeLOpen;
@property (nonatomic, assign) CGFloat eyeROpen;
@property (nonatomic, assign) CGFloat eyeX;
@property (nonatomic, assign) CGFloat eyeY;
@property (nonatomic, assign) CGFloat bodyX;
@property (nonatomic, assign) CGFloat bodyY;
@property (nonatomic, assign) CGFloat bodyAngleX;
@property (nonatomic, assign) CGFloat bodyAngleY;
@property (nonatomic, assign) CGFloat bodyAngleZ;

@property (nonatomic) GLKView *glView;
@property (nonatomic, strong) LAppModel *haru;
@property (nonatomic, assign) CGSize screenSize;
@property (nonatomic, assign) NSInteger expressionCount;

@property (nonatomic, strong) ARSession *arSession;
@property (nonatomic, strong) SCNNode *faceNode;
@property (nonatomic, strong) SCNNode *leftEyeNode;
@property (nonatomic, strong) SCNNode *rightEyeNode;

@property (nonatomic, strong) MPControlValueLinear *eyeLinearX;
@property (nonatomic, strong) MPControlValueLinear *eyeLinearY;
@end

@implementation ViewController

- (GLKView *)glView {
    return (GLKView *)self.view;
}

- (SCNNode *)faceNode {
    if (_faceNode == nil) {
        _faceNode = [SCNNode node];
    }
    return _faceNode;
}

- (SCNNode *)leftEyeNode {
    if (_leftEyeNode == nil) {
        _leftEyeNode = [SCNNode node];
    }
    return _leftEyeNode;
}

- (SCNNode *)rightEyeNode {
    if (_rightEyeNode == nil) {
        _rightEyeNode = [SCNNode node];
    }
    return _rightEyeNode;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.screenSize = [[UIScreen mainScreen] bounds].size;
    
    [self.glView setContext:LAppGLContext];
    LAppGLContextAction(^{
        self.haru = [[LAppModel alloc] initWithName:@"Haru"];
        [self.haru loadAsset];
        self.expressionCount = self.haru.expressionName.count;
        self.eyeLinearX = [[MPControlValueLinear alloc] initWithOutputMax:[self.haru paramMaxValue:LAppParamEyeBallX].doubleValue
                                                               outputMin:[self.haru paramMinValue:LAppParamEyeBallX].doubleValue
                                                                inputMax:45
                                                                inputMin:-45];
        self.eyeLinearY = [[MPControlValueLinear alloc] initWithOutputMax:[self.haru paramMaxValue:LAppParamEyeBallY].doubleValue
                                                                outputMin:[self.haru paramMinValue:LAppParamEyeBallY].doubleValue
                                                                 inputMax:45
                                                                 inputMin:-45];
        [self.haru startBreath];
    });
    
    [self setupARSession];
}

- (void)setupARSession {
    self.arSession = [[ARSession alloc] init];
    ARFaceTrackingConfiguration *faceTracking = [[ARFaceTrackingConfiguration alloc] init];
    faceTracking.worldAlignment = ARWorldAlignmentCamera;
    self.arSession.delegate = self;
    [self.arSession runWithConfiguration:faceTracking];
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
        [self.haru setParam:LAppParamEyeLOpen forValue:@(self.eyeLOpen)];
        [self.haru setParam:LAppParamEyeROpen forValue:@(self.eyeROpen)];
        [self.haru setParam:LAppParamEyeBallX forValue:@(self.eyeX)];
        [self.haru setParam:LAppParamEyeBallY forValue:@(self.eyeY)];
        [self.haru setParam:LAppParamBodyAngleX forValue:@(self.bodyAngleX)];
        [self.haru setParam:LAppParamBodyAngleY forValue:@(self.bodyAngleY)];
        [self.haru setParam:LAppParamBodyAngleZ forValue:@(self.bodyAngleZ)];
    }];
    glClearColor(0, 1, 0, 1);
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

- (IBAction)handleASlideChange:(id)sender {
    self.bodyAngleX = self.ASlider.value;
}
- (IBAction)handleBSlideChange:(id)sender {
    self.bodyAngleY = self.BSlider.value;
}
- (IBAction)handleCSlideChange:(id)sender {
    self.bodyAngleZ = self.CSlider.value;
}
- (IBAction)handleDSlideChange:(id)sender {
    self.mouthOpenY = self.DSlider.value;
}


#pragma mark - Delegate
- (void)session:(ARSession *)session didUpdateAnchors:(NSArray<__kindof ARAnchor *> *)anchors {
    ARFaceAnchor *faceAnchor = anchors.firstObject;
    if (faceAnchor) {
        self.faceNode.simdTransform = faceAnchor.transform;
        if (@available(iOS 12.0, *)) {
            self.leftEyeNode.simdTransform = faceAnchor.leftEyeTransform;
            self.rightEyeNode.simdTransform = faceAnchor.rightEyeTransform;
        }
        
        self.headPitch = -(180 / M_PI) * self.faceNode.eulerAngles.x;
        self.headYaw = (180 / M_PI) * self.faceNode.eulerAngles.y;
        self.headRoll = -(180 / M_PI) * self.faceNode.eulerAngles.z + 90.0;
        self.bodyAngleX = self.headYaw / 4;
        self.bodyAngleY = self.headPitch / 2;
        self.bodyAngleZ = self.headRoll / 2;
        
        self.eyeLOpen = 1 - faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkLeft].floatValue;
        self.eyeROpen = 1 - faceAnchor.blendShapes[ARBlendShapeLocationEyeBlinkRight].floatValue;
        self.eyeX = [self.eyeLinearX calc:(180 / M_PI) * self.leftEyeNode.eulerAngles.y];
        self.eyeY = - [self.eyeLinearY calc:(180 / M_PI) * self.leftEyeNode.eulerAngles.x];
        self.mouthOpenY = faceAnchor.blendShapes[ARBlendShapeLocationJawOpen].floatValue;
        
    }
}

@end
