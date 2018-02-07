//
//  AXAssetDownloadOperation.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AssetDownloadOperationDelegate <NSObject>
- (void) didFinishDownloadingAsset:(NSString *)assetIdentifier fileName:(NSString *)fileName;
- (void) didFinishWithError:(NSError *)error;
@end

@interface AXAssetDownloadOperation : NSOperation

@property (weak) id<AssetDownloadOperationDelegate> delegate;
- (instancetype) initWithAsset:(PHAsset *)asset;
@end
