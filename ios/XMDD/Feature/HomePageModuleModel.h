//
//  HomePageModuleModel.h
//  XMDD
//
//  Created by fuqi on 16/8/5.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomePageModuleModel : NSObject

@property (nonatomic,strong)NSArray * moduleArray;

@property (nonatomic)NSInteger numOfColumn;
@property (nonatomic)NSInteger numOfRow;

/// 设置九宫格（父视图，单块宽高）
- (void)setupSquaresViewWithContainView:(UIView *)containView andItemWith:(CGFloat)width andItemHeigth:(CGFloat)height;
/// 刷新九宫格
- (void)refreshSquareView:(UIView *)containView;

@end
