//
//  WYOCNetworkViewController.m
//  WYOCNetwork
//
//  Created by 407671883@qq.com on 11/07/2018.
//  Copyright (c) 2018 407671883@qq.com. All rights reserved.
//

#import "WYOCNetworkViewController.h"

#import <WYOCNetwork.h>

@interface WYOCNetworkViewController ()

@end

@implementation WYOCNetworkViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [WYOCNetwork openLog];
    [WYOCNetwork GET:@"" parameters:nil success:^(WYOCNetworkModel * _Nonnull responseObject) {
        
    } failure:^(NSError * _Nonnull error) {
        
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
