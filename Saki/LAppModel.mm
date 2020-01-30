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
#import "CubismModelSettingJson.hpp"
#import "CubismRenderer_OpenGLES2.hpp"
#import "LAppBundle.h"
#import "LAppModel.h"
#import "LAppTextureManager.h"
namespace app {
class Model : public Csm::CubismUserModel {
    
};
}

@interface LAppModel ()
@property (nonatomic, copy) NSString *assetName;
@property (nonatomic, assign) Csm::ICubismModelSetting *modelSetting;
@property (nonatomic, assign) app::Model *model;
@end
@implementation LAppModel
- (void)dealloc {
    if (_modelSetting != nullptr) {
        delete _modelSetting;
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

- (void)loadModel {
    NSString *modelFileName = [NSString stringWithCString:_modelSetting->GetModelFileName() encoding:NSUTF8StringEncoding];
    if (modelFileName &&
        modelFileName.length > 0) {
        NSString *filePath = [[[NSBundle modelResourceBundleWithName:self.assetName] bundlePath] stringByAppendingPathComponent:modelFileName];
        NSData *fileData = [[NSData alloc] initWithContentsOfFile:filePath];
        self.model->LoadModel((const Csm::csmByte *)fileData.bytes, (Csm::csmSizeInt)fileData.length);
    }
}

- (void)loadTexture {
    self.model->CreateRenderer();
    Csm::csmInt32 textureCount = self.modelSetting->GetTextureCount();
    NSString *textureDirPath = [[NSBundle modelResourceBundleWithName:self.assetName] bundlePath];
    for (int i = 0; i < textureCount; ++i) {
        NSString *textureFileName = [[NSString alloc] initWithCString:self.modelSetting->GetTextureFileName(i) encoding:NSUTF8StringEncoding];
        NSString *textureFilePath = [textureDirPath stringByAppendingPathComponent:textureFileName];
        CVOpenGLESTextureRef texture = [[LAppTextureManager sharedInstance] copyOpenGLESTextureWithImage:[UIImage imageWithContentsOfFile:textureFilePath]];
        if (texture) {
            GLuint textureID = CVOpenGLESTextureGetName(texture);
            self.model->GetRenderer<Csm::Rendering::CubismRenderer_OpenGLES2>()->BindTexture(i, textureID);
            CFRelease(texture);
        }
    }
}

@end
