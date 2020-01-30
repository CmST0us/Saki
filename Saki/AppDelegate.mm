//
//  AppDelegate.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import "Live2DCubismCore.hpp"
#import "LAppAllocator.h"
#import "LAppTextureManager.h"
#import "AppDelegate.h"

class LAppLogger {
public:
    static void logMessage(const Csm::csmChar* message) {
        printf("%s", message);
    }
};

@interface AppDelegate ()
@property (nonatomic, assign) LAppAllocator cubismAllocator;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [[LAppTextureManager sharedInstance] setup];
    [self setupLive2DSDK];
    return YES;
}

- (void)setupLive2DSDK {
    Csm::CubismFramework::Option cubismOption;
    // prepare for Cubism Framework API.
    cubismOption.LogFunction = LAppLogger::logMessage;
    cubismOption.LoggingLevel = Live2D::Cubism::Framework::CubismFramework::Option::LogLevel_Info;
    
    Csm::CubismFramework::StartUp(&_cubismAllocator, &cubismOption);
    Csm::CubismFramework::Initialize();
}

@end
