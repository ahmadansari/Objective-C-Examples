//
//  PHAsset+Utility.h
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import <Photos/Photos.h>

@interface PHAsset (Utility)

//Asset file Name
- (NSString *)fileName;
//Asset file path on device
- (NSURL *)fileURL;

@end
