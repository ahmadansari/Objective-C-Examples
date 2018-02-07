//
//  AXAssetCell.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXAssetCell.h"
#import "AXAssetHandler.h"

@interface AXAssetCell()
@property (readwrite) BOOL cellSelected;
@end

@implementation AXAssetCell

- (BOOL)toggleSelection {
    self.selectedImage.hidden = _cellSelected;
    _cellSelected = !_cellSelected;
    return _cellSelected;
}

- (void)cancelSelection {
    self.selectedImage.hidden = YES;
    _cellSelected = NO;
}

- (void) updateAssetState:(BOOL)selectionEnabled {
    if(selectionEnabled == NO) {
        [self cancelSelection];
        if([[AXAssetHandler sharedHandler] isAssetDownloadedWithIdentifier:_assetIdentifier]) {
            self.downloadedImage.hidden = NO;
        } else {
            self.downloadedImage.hidden = YES;
        }
        
        if([[AXAssetHandler sharedHandler] isAssetDownloadingWithIdentifier:_assetIdentifier]) {
            self.activityIndicator.hidden = NO;
        } else {
            self.activityIndicator.hidden = YES;
        }
    } else {
        self.downloadedImage.hidden = YES;
        self.activityIndicator.hidden = YES;
    }
}

@end
