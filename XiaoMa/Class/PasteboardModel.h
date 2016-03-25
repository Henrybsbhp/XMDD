//
//  PasteboardModel.h
//  XiaoMa
//
//  Created by jt on 16/3/21.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PasteboardModel : NSObject

- (void)prepareForShareWhisper:(NSString *)whisper;

- (BOOL)checkPasteboard;

@property (nonatomic, copy) void(^cancelClickBlock)(id);

@property (nonatomic, copy) void(^nextClickBlock)(id);

@end
