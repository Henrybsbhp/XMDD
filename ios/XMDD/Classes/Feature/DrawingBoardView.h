//
//  DrawingBoardView.h
//  XiaoMa
//
//  Created by 刘亚威 on 15/8/3.
//  Copyright (c) 2015年 jiangjunchen. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum : NSInteger
{
    DrawingBoardViewStatusNone = 0,
    DrawingBoardViewStatusSuccess,
    DrawingBoardViewStatusFail
}DrawingBoardViewStatus;

@interface DrawingBoardView : UIView
///(default is DrawingBoardViewStatusNone)
@property (nonatomic, assign) DrawingBoardViewStatus drawingStatus;

- (void)drawSuccessByFrame;

-(void) drawSuccess;

-(void) drawFailure;

-(void)drawWithStatus:(DrawingBoardViewStatus)status;

@end
