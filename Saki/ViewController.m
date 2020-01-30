//
//  ViewController.m
//  Saki
//
//  Created by CmST0us on 2020/1/30.
//  Copyright © 2020 eki. All rights reserved.
//

#import "ViewController.h"
#import "LAppModel.h"
#import "LAppBundle.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    LAppModel *model = [[LAppModel alloc] initWithName:@"Haru"];
    [model loadModel];
    [model loadTexture];
    NSLog(@"Load");
    // Do any additional setup after loading the view.
}


@end
