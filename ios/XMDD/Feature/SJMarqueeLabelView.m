//
//  SJMarqueeLabelView.m
//  XMDD
//
//  Created by St.Jimmy on 8/22/16.
//  Copyright © 2016 huika. All rights reserved.
//

#import "SJMarqueeLabelView.h"

@interface SJMarqueeLabelView ()

@property (nonatomic, assign) NSInteger repeatCnt;
@property (nonatomic, assign) NSInteger currentLabelMark;
@property (nonatomic, copy) NSArray *tipsArray;

@end

@implementation SJMarqueeLabelView

- (instancetype)initWithFrame:(CGRect)frame tipsArray:(NSArray *)tipsArray
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.tipsArray = tipsArray;
        [self bundleInit];
    }
    
    return self;
}

- (void)bundleInit
{
    self.label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    self.label2 = [[UILabel alloc] initWithFrame:CGRectMake(0, self.frame.size.height + 1, self.frame.size.width, self.frame.size.height)];
    [self addSubview:self.label1];
    [self addSubview:self.label2];
    self.label1.textColor = HEXCOLOR(@"#454545");
    self.label2.textColor = HEXCOLOR(@"#454545");
    self.label1.font = [UIFont systemFontOfSize:14];
    self.label2.font = [UIFont systemFontOfSize:14];
    self.label1.text = self.tipsArray[self.repeatCnt];
    self.label2.text = self.tipsArray[self.repeatCnt + 1];
    self.currentLabelMark = 1;
    self.clipsToBounds = YES;
}

- (void)showScrollingMessageView
{
    @weakify(self);
    [[RACSignal interval:3 onScheduler:[RACScheduler mainThreadScheduler]]subscribeNext:^(id x) {
        @strongify(self);
        
        CGRect frame = self.label1.frame;
        CGRect frame2 = self.label2.frame;
        
        if (self.currentLabelMark == 2) {
            frame.origin.y = self.frame.size.height + 1;
            self.label1.frame = frame;
            frame.origin.y = 0;
            
            frame2.origin.y = -(self.frame.size.height + 1);
            
            if (self.repeatCnt < self.tipsArray.count - 1) {
                self.label1.text = self.tipsArray[self.repeatCnt + 1];
            } else {
                self.label1.text = self.tipsArray.firstObject;
                self.repeatCnt = -1;
            }
            
            self.currentLabelMark = 1;
            
        } else if (self.currentLabelMark == 1) {
            
            frame2.origin.y = self.frame.size.height + 1;;
            self.label2.frame = frame2;
            frame2.origin.y = -1;
            
            frame.origin.y = -(self.frame.size.height + 1);
            
            if (self.repeatCnt < self.tipsArray.count - 1) {
                self.label2.text = self.tipsArray[self.repeatCnt + 1];
            } else {
                self.label2.text = self.tipsArray.firstObject;
                self.repeatCnt = 0;
            }
            
            self.currentLabelMark = 2;
            
        } else {
            
            frame.origin.y = -(self.frame.size.height + 1);
            frame2.origin.y = 0;
            
            self.currentLabelMark = 2;
        }
        
        [UIView animateWithDuration:0.5 animations:^{
            self.label1.frame = frame;
            self.label2.frame = frame2;
        }];
        
        self.repeatCnt += 1;
    }];
}
@end
