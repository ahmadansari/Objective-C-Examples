//
//  AXAssetViewController.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AXAssetViewController : UIViewController

@property (nonatomic, weak) PHAsset *asset;

+ (instancetype)instance;
@end
