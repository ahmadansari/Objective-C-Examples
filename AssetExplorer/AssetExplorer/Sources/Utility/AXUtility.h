//
//  AXUtility.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AXUtility : NSObject

#pragma mark - Generic Alert
+ (void)showNoConnectivityAlert;
+ (void)showErrorAlertWithTitle:(NSString * _Nullable )title message:(NSString * _Nullable )message;
+ (void)showAlertWithTitle:(NSString * _Nullable )title message:(NSString * _Nullable )message;
+ (void)showAlertWithTitle:(NSString * _Nullable )title
                   message:(NSString * _Nullable )message
         cancelButtonTitle:(NSString * _Nullable )cancelButtonTitle;
@end
