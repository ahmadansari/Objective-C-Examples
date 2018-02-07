//
//  UIViewController+Utils.m
//  EFB
//
//  Created by Ahmad Ansari on 8/15/16.
//  Copyright © 2016 Acacus Technologies. All rights reserved.
//

#import "UIViewController+Utils.h"

@implementation UIViewController (Utils)

// Class Methods
+ (UIViewController *)currentViewController {

  // Find best view controller
  UIViewController *viewController =
      [UIApplication sharedApplication].keyWindow.rootViewController;
  return [UIViewController findBestViewController:viewController];
}

+ (UIViewController *)findBestViewController:(UIViewController *)vc {

  if (vc.presentedViewController) {

    // Return presented view controller
    return [UIViewController findBestViewController:vc.presentedViewController];

  } else if ([vc isKindOfClass:[UISplitViewController class]]) {

    // Return right hand side
    UISplitViewController *svc = (UISplitViewController *)vc;
    if (svc.viewControllers.count > 0)
      return [UIViewController
          findBestViewController:svc.viewControllers.lastObject];
    else
      return vc;

  } else if ([vc isKindOfClass:[UINavigationController class]]) {

    // Return top view
    UINavigationController *svc = (UINavigationController *)vc;
    if (svc.viewControllers.count > 0)
      return [UIViewController findBestViewController:svc.topViewController];
    else
      return vc;

  } else if ([vc isKindOfClass:[UITabBarController class]]) {

    // Return visible view
    UITabBarController *svc = (UITabBarController *)vc;
    if (svc.viewControllers.count > 0)
      return
          [UIViewController findBestViewController:svc.selectedViewController];
    else
      return vc;

  } else {

    // Unknown view controller type, return last child view controller
    return vc;
  }
}

// Instance Methods
- (BOOL)isViewVisible {
  if ([self isViewLoaded]) {
    return ([self.view window] != nil);
  }
  return NO;
}

- (BOOL)isRootViewController {
  BOOL isRoot = NO;
  if(self.navigationController != nil) {
    NSArray *viewControllers = [self.navigationController viewControllers];
    if(!isEmpty(viewControllers)) {
      if(self == [viewControllers firstObject]) {
        isRoot = YES;
      }
    }
  }
  return isRoot;
}
@end
