//
//  InsInputNameVC.m
//  XiaoMa
//
//  Created by jiangjunchen on 15/12/8.
//  Copyright © 2015年 jiangjunchen. All rights reserved.
//

#import "InsInputNameVC.h"
#import "CKLine.h"

@interface InsInputNameVC ()
@property (nonatomic, weak) IBOutlet CKLine *line;
@end

@implementation InsInputNameVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.line.lineAlignment = CKLineAlignmentHorizontalTop;
}

- (void)didReceiveMemoryWarning{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
