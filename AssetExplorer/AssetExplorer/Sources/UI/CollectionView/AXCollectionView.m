//
//  AXCollectionView.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXCollectionView.h"

// Cell Identifiers
NSString *const collectionCellPhotoItem = @"collectionCellPhotoItem";

@implementation AXCollectionView


- (void)registerCustomCells {
    //Registering Custom Collection Cells
    [self registerClass:[AXAssetCell class] forCellWithReuseIdentifier:collectionCellPhotoItem];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
