//
//  UIViewController+Utils.h
//  EFB
//
//  Created by Ahmad Ansari on 8/15/16.
//  Copyright © 2016 Acacus Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (Utils)

// Class Methods
+ (UIViewController *)currentViewController;

// Instance Methods
- (BOOL)isViewVisible;
- (BOOL)isRootViewController;
@end
