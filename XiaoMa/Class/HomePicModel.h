//
//  HomePicModel.h
//  XiaoMa
//
//  Created by jt on 16/1/12.
//  Copyright © 2016年 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HomeItem : NSObject<NSCoding>

@property (nonatomic,strong)NSNumber * homeItemId;

@property (nonatomic,copy)NSString * homeItemTitle;
@property (nonatomic,copy)NSString * homeItemPicUrl;
@property (nonatomic,copy)NSString * homeItemRedirect;

@property (nonatomic,copy)NSString * defaultImageName;
@property (nonatomic)BOOL isNewFlag;

- (instancetype)initWithId:(NSNumber *)itemId titlt:(NSString *)title
                    picUrl:(NSString *)picurl andUrl:(NSString *)url
                 imageName:(NSString *)imageName isnew:(BOOL)flag;

@end

@interface HomePicModel : NSObject<NSCoding>

///homepage九宫格钮配置信息
@property (nonatomic,strong)NSArray * homeItemArray;

///处理homepicmodel，判断是否需要显示new标签及默认图片；
- (HomePicModel *)analyzeHomePicModel:(HomePicModel *)model;

+ (instancetype)homeWithJSONResponse:(NSDictionary *)rsp;

@end
