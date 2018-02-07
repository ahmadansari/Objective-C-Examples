//
//  AXAssetHandler.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDMulticastDelegate.h"


@protocol AssetHandlerDelegate <NSObject>
- (void)didStartDownloadingAsset:(PHAsset *_Nullable)asset;
- (void) didFinishDownloadingAsset:(NSDictionary *_Nullable)downloadInfo;
- (void) didFinishWithError:(NSError *_Nullable)error;
@end


@interface AXAssetHandler : NSObject {
    @private
    GCDMulticastDelegate<AssetHandlerDelegate> *multicastSyncDelegate;
}
@property (nonatomic, strong, readonly) NSDictionary * _Nullable savedAssets;

+ (instancetype _Nonnull)sharedHandler;

- (BOOL) isAssetDownloaded:(PHAsset *_Nullable)asset;
- (BOOL) isAssetDownloading:(PHAsset *_Nullable)asset;
- (BOOL) isAssetDownloadedWithIdentifier:(NSString *_Nullable)assetIdentifier;
- (BOOL) isAssetDownloadingWithIdentifier:(NSString *_Nullable)assetIdentifier;
- (void) downloadAssets:(NSArray *_Nullable)assets;
- (PHAsset *_Nullable)assetWithIdentifier:(NSString *_Nullable)assetIdentifier;
- (NSString *_Nullable)localPathForAsset:(PHAsset *_Nullable)asset;
@end


@interface AXAssetHandler (Delegation)
/**
 *  Multicast Delegatation
 */

- (void)addDelegate:(id _Nullable)delegate;
- (void)removeDelegate:(id _Nullable)delegate;

- (void)addDelegate:(id _Nullable)delegate delegateQueue:(dispatch_queue_t _Nullable)delegateQueue;
- (void)removeDelegate:(id _Nullable)delegate
         delegateQueue:(dispatch_queue_t _Nullable)delegateQueue;

- (void)removeAllDelegates;

/**
 *  Post Delegate Methods
 *
 *  @param selector Target Selector.
 *  @param object   Target Object.
 */
- (void)postDelegateMethod:(SEL _Nonnull)selector withObject:(id _Nullable)object;

@end
