//
//  AXAssetViewController.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXAssetViewController.h"
#import "AXAssetHandler.h"
#import "PHAsset+Utility.h"

@interface AXAssetViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIView *containerView;


@end

@implementation AXAssetViewController

+ (instancetype)instance {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    AXAssetViewController *assetViewController = [storyboard instantiateViewControllerWithIdentifier:@"AXAssetViewController"];
    return assetViewController;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.largeTitleDisplayMode = UINavigationItemLargeTitleDisplayModeNever;
    [self loadAsset];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadAsset {
    if(self.asset) {
        self.title = [self.asset fileName];
        NSURL *assetURL = nil;
        NSString *localPath = [[AXAssetHandler sharedHandler] localPathForAsset:_asset];
        if(localPath != nil) {
            assetURL = [NSURL fileURLWithPath:localPath];
        } else {
            assetURL = [_asset fileURL];
        }

        switch (_asset.playbackStyle) {
                case PHAssetPlaybackStyleUnsupported:
                [AXUtility showErrorAlertWithTitle:@"Unsupported Format"
                                           message:nil];
                break;
            case PHAssetPlaybackStyleImage:
                if(assetURL) {
                    if([[NSFileManager defaultManager] fileExistsAtPath:assetURL.path]) {
                        self.imageView.hidden = NO;                        
                        [self.imageView sd_setImageWithURL:assetURL placeholderImage:[UIImage imageNamed:@"placeholder"]];
                    }
                }
                break;
            case PHAssetPlaybackStyleLivePhoto:
                break;
            case PHAssetPlaybackStyleImageAnimated:
                break;
            case PHAssetPlaybackStyleVideo: {
                AVPlayer *player = [AVPlayer playerWithURL:assetURL];
                AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
                playerLayer.bounds = self.view.layer.bounds;
                
                playerLayer.frame = CGRectMake(0,
                                               0,
                                               _containerView.layer.frame.size.width,
                                               _containerView.layer.frame.size.height);
                [self.containerView.layer insertSublayer:playerLayer atIndex:0];
                self.imageView.hidden = YES;
                break;
            }
            case PHAssetPlaybackStyleVideoLooping:
                break;
                default:
                break;
        }
    }
}
@end
