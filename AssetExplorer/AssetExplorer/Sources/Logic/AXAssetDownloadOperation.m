//
//  AXAssetDownloadOperation.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXAssetDownloadOperation.h"
#import "AXAssetHandler.h"

@interface AXAssetDownloadOperation ()

@property (nonatomic) PHAsset *asset;
@end

@implementation AXAssetDownloadOperation

- (instancetype) initWithAsset:(PHAsset *)asset {
    if(self = [super init]) {
        self.asset = asset;
    }
    return self;
}

- (void)main {
    @autoreleasepool {
        if(self.asset != nil) {
            [self downloadAsset];
        }
    }
}

- (void) downloadAsset {
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager]
         requestImageDataForAsset:self.asset
         options:imageRequestOptions
         resultHandler:^(NSData *imageData, NSString *dataUTI,
                         UIImageOrientation orientation,
                         NSDictionary *info)
         {
             if ([info objectForKey:@"PHImageFileURLKey"]) {
                 NSURL *fileURL = [info objectForKey:@"PHImageFileURLKey"];
                 
                 NSString *assetIdentifier = self.asset.localIdentifier;
                 
                 
                 //Remove Previous Asset for ID
                 NSString *localPath = [[AXAssetHandler sharedHandler] localPathForAsset:_asset];
                 NSError *error = nil;
                 if([[NSFileManager defaultManager] removeItemAtPath:localPath
                                                               error:&error]) {
                     DDLogDebug(@"Previous File for Asset Removed");
                 }
                 if(error) {
                     DDLogError(@"Asset Remove Error: %@", error);
                 }
                 
                 // optionally, write the video to the temp directory
                 NSString *timestamp = [NSString stringWithFormat:@"%.0f",[[NSDate date] timeIntervalSince1970]];
                 NSString *fileName = [timestamp stringByAppendingFormat:@"_%@",[fileURL lastPathComponent]];
                 
                 NSString *filePath = [[self documentsDirectoryPath] stringByAppendingPathComponent:fileName];
                 
                 error = nil;
                 BOOL writeResult = [imageData writeToURL:[NSURL fileURLWithPath:filePath] options:NSDataWritingAtomic error:&error];
                 
                 if(writeResult) {
                     DDLogDebug(@"Asset Saved");
                     if(_delegate && [_delegate respondsToSelector:@selector(didFinishDownloadingAsset:fileName:)]) {
                         [_delegate didFinishDownloadingAsset:assetIdentifier
                                                     fileName:fileName];
                     }
                 }
                 else {
                     DDLogDebug(@"Write Operation Failed");
                     if(_delegate && [_delegate respondsToSelector:@selector(didFinishWithError:)]) {
                         [_delegate didFinishWithError:error];
                     }
                 }
             }
         }];
}

- (NSString *)documentsDirectoryPath {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        return [paths firstObject];
    }
}

@end
