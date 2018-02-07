//
//  PHAsset+Utility.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "PHAsset+Utility.h"

@implementation PHAsset (Utility)

//Asset file Name
- (NSString *)fileName {
    NSArray *resources = [PHAssetResource assetResourcesForAsset:self];
    return ((PHAssetResource*)resources[0]).originalFilename;
}

//Asset file path on device
- (NSURL *)fileURL {
    __block NSURL *url = nil;
    __block BOOL processingRequest = YES;
    @autoreleasepool {
        PHImageRequestOptions * imageRequestOptions = [[PHImageRequestOptions alloc] init];
        imageRequestOptions.synchronous = YES;
        [[PHImageManager defaultManager]
         requestImageDataForAsset:self
         options:imageRequestOptions
         resultHandler:^(NSData *imageData, NSString *dataUTI,
                         UIImageOrientation orientation,
                         NSDictionary *info)
         {
             if ([info objectForKey:@"PHImageFileURLKey"]) {
                 // path looks like this -
                 // file:///var/mobile/Media/DCIM/###APPLE/IMG_####.JPG
                 url = [info objectForKey:@"PHImageFileURLKey"];
             }
             processingRequest = NO;
         }];
        while (processingRequest) {
            // 1/1000 of a second
            NSDate *stopDate = [NSDate dateWithTimeIntervalSinceNow:0.001];
            [[NSRunLoop currentRunLoop] runUntilDate:stopDate];
        }
    }
    return url;
}

@end
