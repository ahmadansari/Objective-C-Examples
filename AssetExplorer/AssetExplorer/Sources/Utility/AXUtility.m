//
//  AXUtility.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXUtility.h"
#import "UIViewController+Utils.h"

@implementation AXUtility

#pragma mark - Generic Alert
+ (void)showNoConnectivityAlert {
    [AXUtility showAlertWithTitle:LOC(@"KEY_STRING_ERROR")
                       message:LOC(@"KEY_STRING_NO_CONNECTIVITY")
             cancelButtonTitle:LOC(@"KEY_STRING_CANCEL")];
}

+ (void)showErrorAlertWithTitle:(NSString *)title message:(NSString *)message {
    [AXUtility showAlertWithTitle:title ? title : LOC(@"KEY_STRING_ERROR")
                       message:message
             cancelButtonTitle:LOC(@"KEY_STRING_CANCEL")];
}

+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message {
    [AXUtility showAlertWithTitle:title
                       message:message
             cancelButtonTitle:LOC(@"KEY_STRING_OK")];
}

+ (void)showAlertWithTitle:(NSString *)title
                   message:(NSString *)message
         cancelButtonTitle:(NSString *)cancelButtonTitle {
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:title
                                        message:message
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            [alert
             addAction:[UIAlertAction actionWithTitle:cancelButtonTitle
                        ? cancelButtonTitle
                                                     : LOC(@"KEY_STRING_CANCEL")
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
            [[UIViewController currentViewController] presentViewController:alert
                                                                   animated:YES
                                                                 completion:nil];
        }
    });
}

@end
