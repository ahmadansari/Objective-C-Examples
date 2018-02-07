//
//  AXAssetListViewController.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXAssetListViewController.h"
#import "AXAssetViewController.h"
#import "AXCollectionView.h"
#import "PHAsset+Utility.h"
#import "AXAssetHandler.h"

@interface AXAssetListViewController () <UICollectionViewDelegate, UICollectionViewDataSource, PHPhotoLibraryChangeObserver>

@property (weak, nonatomic) IBOutlet AXCollectionView *collectionView;
@property (strong, nonatomic) UIBarButtonItem *selectButton;
@property (strong, nonatomic) UIBarButtonItem *cancelButton;

@property (strong, nonatomic) NSMutableArray *selectedAssets;

@property(nonatomic , strong) PHFetchResult *fetchResults;
@property(nonatomic , strong) PHCachingImageManager *imageManager;
@property(readwrite) CGSize thumbnailSize;
@property(readwrite) BOOL selectionEnabled;

@end

@implementation AXAssetListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = LOC(@"KEY_STRING_APP_TITLE");
    //Setting Up Navigation Bar Style
    self.navigationController.navigationBar.prefersLargeTitles = YES;
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    self.cancelButton =  [[UIBarButtonItem alloc] initWithTitle:LOC(@"KEY_STRING_CANCEL")
                                                          style:UIBarButtonItemStyleDone target:self action:@selector(onTapCancelButton:)];
    
    self.selectButton =  [[UIBarButtonItem alloc] initWithTitle:LOC(@"KEY_STRING_SELECT")
                                                                      style:UIBarButtonItemStylePlain target:self action:@selector(onTapSelectButton:)];
    self.navigationItem.rightBarButtonItem = self.selectButton;
    self.selectedAssets = [NSMutableArray array];
    [self initializeAssets];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    [_imageManager stopCachingImagesForAllAssets];
    [[PHPhotoLibrary sharedPhotoLibrary] unregisterChangeObserver:self];
    [[AXAssetHandler sharedHandler] removeDelegate:self];
}

- (void)initializeAssets {
    [[AXAssetHandler sharedHandler] addDelegate:self];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if (status == PHAuthorizationStatusAuthorized) {
            [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
            PHFetchOptions *allPhotosOptions = [[PHFetchOptions alloc] init];
            allPhotosOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
            self.fetchResults = [PHAsset fetchAssetsWithOptions:allPhotosOptions];
            if(_imageManager == nil) {
                _imageManager = [[PHCachingImageManager alloc] init];
            }
            [self reloadData];
        } else if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            //Not Authorized
        }
    }];
}


#pragma mark - IBActions
- (void)onTapSelectButton:(UIBarButtonItem *)selectButton {
    if(_selectionEnabled) {
        [selectButton setTitle:LOC(@"KEY_STRING_SELECT")];
        self.navigationItem.leftBarButtonItem = nil;
        [[AXAssetHandler sharedHandler] downloadAssets:_selectedAssets];
    } else {
        [selectButton setTitle:LOC(@"KEY_STRING_SAVE")];
        self.navigationItem.leftBarButtonItem = self.cancelButton;
    }
    _selectionEnabled = !_selectionEnabled;
    [self reloadData];
}

- (void)onTapCancelButton:(UIBarButtonItem *)cancelButton {
    self.navigationItem.leftBarButtonItem = nil;
    _selectionEnabled = NO;
    [_selectButton setTitle:LOC(@"KEY_STRING_SELECT")];
    [self.selectedAssets removeAllObjects];
    [self reloadData];
}

#pragma mark - Orientation
- (void)viewWillTransitionToSize:(CGSize)size
       withTransitionCoordinator:
(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    // before rotation
    [coordinator animateAlongsideTransition:^(id _Nonnull context) {
        // during rotation: update our image view's bounds and centre
        [self reloadData];
    } completion:^(id _Nonnull context) {
        // after rotation
    }];
}

#pragma mark - Collection View Methods
#pragma mark-- UICollectionViewDelegateFlowLayout
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float columnCount = 3.0;
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    float cellWidth = (screenWidth - 10) / columnCount;
    CGSize size = CGSizeMake(cellWidth, 150);
    return size;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)
collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 3.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView
                   layout:(UICollectionViewLayout *)
collectionViewLayout
minimumLineSpacingForSectionAtIndex:(NSInteger)section {
    return 5.0;
}

#pragma mark-- UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView
     numberOfItemsInSection:(NSInteger)section {
    return [_fetchResults count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                  cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Configure the cell...
    AXAssetCell *photoCell = [self.collectionView dequeueReusableCellWithReuseIdentifier:collectionCellPhotoItem forIndexPath:indexPath];
    PHAsset *asset = _fetchResults[indexPath.item];
    [_imageManager requestImageForAsset:asset targetSize:photoCell.imageView.frame.size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage *result, NSDictionary *info)
     {
         photoCell.imageView.image = result;
         photoCell.assetIdentifier = asset.localIdentifier;
     }];    
    photoCell.titleLabel.text = [asset fileName];
    [photoCell updateAssetState:self.selectionEnabled];
    return photoCell;
}


#pragma mark-- UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView
didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
    PHAsset *asset = _fetchResults[indexPath.item];
    if(self.selectionEnabled) {
        AXAssetCell *photoCell = (AXAssetCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
        if ([photoCell toggleSelection]) {
            [self.selectedAssets addObject:asset];
        } else {
            [self.selectedAssets removeObject:asset];
        }
        DDLogDebug(@"%@", self.selectedAssets);
    } else {
        //Go for Detail Page
        AXAssetViewController *assetViewController = [AXAssetViewController instance];
        assetViewController.asset = asset;
        [self.navigationController pushViewController:assetViewController animated:YES];
    }
}

- (void) reloadData {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.collectionView reloadData];
    });
}

#pragma mark - PHPhotoLibraryChangeObserver
//Invoked on background queue
- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self initializeAssets];
        [self reloadData];
    });
}


#pragma mark - AssetHandlerDelegate
- (void)didStartDownloadingAsset:(PHAsset *_Nullable)asset {
    [self reloadData];
}

- (void) didFinishDownloadingAsset:(NSDictionary *_Nullable)downloadInfo {
    PHAsset *asset = [[AXAssetHandler sharedHandler] assetWithIdentifier:downloadInfo[@"assetIdentifier"]];
    if(asset) {
        [self.selectedAssets removeObject:asset];
    }
    [self reloadData];
}

- (void) didFinishWithError:(NSError *_Nullable)error {
    [self reloadData];
}

@end
