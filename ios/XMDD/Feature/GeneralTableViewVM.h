//
//  GeneralTableViewVM.h
//  XMDD
//
//  Created by St.Jimmy on 19/10/2016.
//  Copyright © 2016 huika. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeneralTableViewVM : NSObject <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) CKList *dataSource;

@end
