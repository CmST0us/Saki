    //
//  LAppModel.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreImage/CoreImage.h>
#import <CoreVideo/CoreVideo.h>
#import "CubismUserModel.hpp"
#import "CubismIdManager.hpp"
#import "CubismDefaultParameterId.hpp"
#import "CubismModelSettingJson.hpp"
#import "CubismRenderer_OpenGLES2.hpp"
#import "LAppBundle.h"
#import "LAppModel.h"
#import "LAppOpenGLManager.h"

#define LAppModelParameter(key) Csm::CubismFramework::GetIdManager()->GetId(key)

namespace app {
class Model : public Csm::CubismUserModel {
public:
    Csm::CubismPose *GetPose() {
        return _pose;
    }
};
}

@interface LAppModel ()
@property (nonatomic, copy) NSString *assetName;
@property (nonatomic, assign) Csm::ICubismModelSetting *modelSetting;
@property (nonatomic, assign) app::Model *model;

@property (nonatomic, assign) Csm::CubismPose *modelPose;
@property (nonatomic, assign) Csm::CubismBreath *modelBreath;
@end
@implementation LAppModel
- (void)dealloc {
    [self releaseTexture];
    
    if (_modelSetting != nullptr) {
        delete _modelSetting;
    }
    
    if (_modelBreath) {
        Csm::CubismBreath::Delete(_modelBreath);
        _modelBreath = nullptr;
    }
    
    if (_model) {
        delete _model;
    }
}

- (instancetype)initWithName:(NSString *)name {
    self = [super init];
    if (self) {
        _assetName = name;
        _modelSetting = nullptr;
        
        NSString *model3FilePath = [[NSBundle modelResourceBundleWithName:name] model3FilePath];
        if (model3FilePath == nil) {
            return nil;
        }
        NSData *jsonFile = [[NSData alloc] initWithContentsOfFile:model3FilePath];
        _modelSetting = new Csm::CubismModelSettingJson((const Csm::csmByte *)jsonFile.bytes, (Csm::csmSizeInt)jsonFile.length);
        _model = new app::Model;
    }
    return self;
}

- (void)setMVPMatrixWithSize:(CGSize)size {
    Csm::CubismMatrix44 projectionMatrix;
    projectionMatrix.Scale(1, size.width / size.height);
    projectionMatrix.MultiplyByMatrix(self.model->GetModelMatrix());
    
    self.model->GetRenderer<Csm::Rendering::CubismRenderer_OpenGLES2>()->SetMvpMatrix(&projectionMatrix);
}

- (void)loadAsset {
    [self loadModel];
    [self loadPose];
    [self createRender];
    [self loadTexture];
}

- (void)loadModel {
    NSString *modelFileName = [NSString stringWithCString:self.modelSetting->GetModelFileName() encoding:NSUTF8StringEncoding];
    if (modelFileName &&
        modelFileName.length > 0) {
        NSString *filePath = [[[NSBundle modelResourceBundleWithName:self.assetName] bundlePath] stringByAppendingPathComponent:modelFileName];
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        self.model->LoadModel((const Csm::csmByte *)fileData.bytes, (Csm::csmSizeInt)fileData.length);
    }
    
    Csm::csmMap<Csm::csmString, Csm::csmFloat32> layout;
    self.modelSetting->GetLayoutMap(layout);

    // モデルのレイアウトを設定。
    self.model->GetModelMatrix()->SetupFromLayout(layout);
}

- (void)loadPose {
    NSString *poseFileName = [NSString stringWithCString:self.modelSetting->GetPoseFileName() encoding:NSUTF8StringEncoding];
    if (poseFileName &&
        poseFileName.length > 0) {
        NSString *filePath = [[[NSBundle modelResourceBundleWithName:self.assetName] bundlePath] stringByAppendingPathComponent:poseFileName];
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        self.model->LoadPose((const Csm::csmByte *)fileData.bytes, (Csm::csmSizeInt)fileData.length);
        self.modelPose = self.model->GetPose();
    }
}

- (void)loadMotion {
    Csm::csmInt32 motionGroupCount = self.modelSetting->GetMotionGroupCount();
    for (Csm::csmInt32 i = 0; i < motionGroupCount; ++i) {
        const Csm::csmChar *motionGroupName = self.modelSetting->GetMotionGroupName(i);
        Csm::csmInt32 motionCount = self.modelSetting->GetMotionCount(motionGroupName);
        for (Csm::csmInt32 j = 0; j < motionCount; ++j) {
            NSString *fileName = [NSString stringWithCString:self.modelSetting->GetMotionFileName(motionGroupName, j) encoding:NSUTF8StringEncoding];
            NSString *filePath = [[[NSBundle modelResourceBundleWithName:self.assetName] bundlePath] stringByAppendingPathComponent:fileName];
            NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
            self.model->LoadMotion((const Csm::csmByte *)fileData.bytes, (Csm::csmSizeInt)fileData.length, motionGroupName);
        }
    }
}

- (void)createRender {
    self.model->CreateRenderer();
}

- (void)loadTexture {
    Csm::csmInt32 textureCount = self.modelSetting->GetTextureCount();
    NSString *textureDirPath = [[NSBundle modelResourceBundleWithName:self.assetName] bundlePath];
    for (int i = 0; i < textureCount; ++i) {
        NSString *textureFileName = [[NSString alloc] initWithCString:self.modelSetting->GetTextureFileName(i) encoding:NSUTF8StringEncoding];
        NSString *textureFilePath = [textureDirPath stringByAppendingPathComponent:textureFileName];
        GLuint texture;
        if ([LAppOpenGLManagerInstance createTexture:&texture withImage:[UIImage imageWithContentsOfFile:textureFilePath]]) {
            self.model->GetRenderer<Csm::Rendering::CubismRenderer_OpenGLES2>()->BindTexture(i, texture);
        }
    }
}

- (void)releaseTexture {
    Csm::csmInt32 textureCount = self.modelSetting->GetTextureCount();
    auto map = self.model->GetRenderer<Csm::Rendering::CubismRenderer_OpenGLES2>()->GetBindedTextures();
    for (Csm::csmInt32 i = 0; i < textureCount; ++i) {
        GLuint texture = map[i];
        [LAppOpenGLManagerInstance releaseTexture:texture];
    }
}

- (void)startMotionWithName:(NSString *)motionName
                 fadeInTime:(NSTimeInterval)fadeInTime
                fadeOutTime:(NSTimeInterval)fadeOutTime
                     isLoop:(BOOL)isLoop {
    
}

- (void)startBreath {
    self.modelBreath = Csm::CubismBreath::Create();
    Csm::csmVector<Csm::CubismBreath::BreathParameterData> breathParameters;

    breathParameters.PushBack(Csm::CubismBreath::BreathParameterData(LAppModelParameter(Csm::DefaultParameterId::ParamAngleX), 0.0f, 15.0f, 6.5345f, 0.5f));
    breathParameters.PushBack(Csm::CubismBreath::BreathParameterData(LAppModelParameter(Csm::DefaultParameterId::ParamAngleY), 0.0f, 8.0f, 3.5345f, 0.5f));
    breathParameters.PushBack(Csm::CubismBreath::BreathParameterData(LAppModelParameter(Csm::DefaultParameterId::ParamAngleZ), 0.0f, 10.0f, 5.5345f, 0.5f));
    breathParameters.PushBack(Csm::CubismBreath::BreathParameterData(LAppModelParameter(Csm::DefaultParameterId::ParamBodyAngleX), 0.0f, 4.0f, 15.5345f, 0.5f));
    breathParameters.PushBack(Csm::CubismBreath::BreathParameterData(LAppModelParameter(Csm::DefaultParameterId::ParamBreath), 0.5f, 0.5f, 3.2345f, 0.5f));

    self.modelBreath->SetParameters(breathParameters);
}

- (void)stopBreath {
    Csm::CubismBreath::Delete(self.modelBreath);
    self.modelBreath = nullptr;
}

- (CGFloat)canvasWidth {
    return self.model->GetModel()->GetCanvasWidth();
}

- (CGFloat)canvasHeight {
    return self.model->GetModel()->GetCanvasHeight();
}

#pragma mark - On Update
- (void)onUpdate {
    /// 设置模型参数
    self.model->GetModel()->LoadParameters();
    
    self.model->GetModel()->SaveParameters();
    
    /// 更新并绘制
    if (self.modelBreath) {
        self.modelBreath->UpdateParameters(self.model->GetModel(), LAppOpenGLManagerInstance.deltaTime);
    }
    if (self.modelPose) {
        self.modelPose->UpdateParameters(self.model->GetModel(), LAppOpenGLManagerInstance.deltaTime);
    }
    self.model->GetModel()->Update();
    self.model->GetRenderer<Csm::Rendering::CubismRenderer_OpenGLES2>()->DrawModel();
}
@end
