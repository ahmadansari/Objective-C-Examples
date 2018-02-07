//
//  AXAssetHandler.m
//  AssetExplorer
//
//  Created by Ahmad Ansari on 07/02/2018.
//  Copyright © 2018 Ahmad Ansari. All rights reserved.
//

#import "AXAssetHandler.h"
#import "AXAssetDownloadOperation.h"
#import "CompilerMacros.h"

@interface AXAssetHandler () <AssetDownloadOperationDelegate> 
{
@private
    NSOperationQueue *downloadQueue;
    dispatch_queue_t delegateDispatchQueue;
    void *delegateQueueTag;
}
@property (nonatomic, strong, readwrite) NSDictionary * _Nullable savedAssets;
@property (nonatomic, strong, readwrite) NSArray<NSString *> * _Nullable downloadingAssets;
@end

@implementation AXAssetHandler

#pragma mark -
#pragma mark ARC Singleton Implementation
static AXAssetHandler *sharedInstance = nil;
+ (instancetype)sharedHandler {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (id)init {
    Class myClass = [self class];
    @synchronized(myClass) {
        if ((self = [super init]) != nil) {
            sharedInstance = self;
            // Do any other initialisation stuff here
            multicastSyncDelegate = (GCDMulticastDelegate<AssetHandlerDelegate> *)[[GCDMulticastDelegate alloc] init];
            
            downloadQueue = [[NSOperationQueue alloc] init];
            downloadQueue.maxConcurrentOperationCount = kMaxConcurrentOperationCount;
            
            delegateQueueTag = &delegateQueueTag;
            delegateDispatchQueue = dispatch_queue_create("AssetExplorer.delegateDispatchQueue", DISPATCH_QUEUE_SERIAL);

        }
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [super allocWithZone:zone];
    });
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

#pragma mark - Saved Assets Accessors
- (NSDictionary *)savedAssets {
    return (NSDictionary *) [NSKeyedUnarchiver
                             unarchiveObjectWithData:[[NSUserDefaults standardUserDefaults]
                                                      valueForKey:kSavedAssets]];
}

- (void)setSavedAssets:(NSDictionary *)savedAssets {
    [[NSUserDefaults standardUserDefaults]
     setValue:[NSKeyedArchiver archivedDataWithRootObject:savedAssets]
     forKey:kSavedAssets];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Utility Methods
- (BOOL) isAssetDownloaded:(PHAsset *_Nullable)asset {
    if(asset) {
        NSString *fileName = [self.savedAssets valueForKey:asset.localIdentifier];
        if(!isEmpty(fileName)) {
            NSString *filePath = [[[AXAssetHandler sharedHandler] documentsDirectoryPath] stringByAppendingPathComponent:fileName];
            if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                return YES;
            }
        }
    }
    return NO;
}

- (BOOL) isAssetDownloadedWithIdentifier:(NSString *_Nullable)assetIdentifier {
    if(assetIdentifier) {
        PHAsset *asset = [self assetWithIdentifier:assetIdentifier];
        return [self isAssetDownloaded:asset];
    }
    return NO;
}

- (BOOL) isAssetDownloadingWithIdentifier:(NSString *_Nullable)assetIdentifier {
    if(assetIdentifier) {
        PHAsset *asset = [self assetWithIdentifier:assetIdentifier];
        return [self isAssetDownloading:asset];
    }
    return NO;
}


- (BOOL) isAssetDownloading:(PHAsset *)asset {
    if(asset) {
        NSArray *allOperations = [downloadQueue operations];
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF.asset.localIdentifier == %@", asset.localIdentifier];
        NSArray *fileteredOperations = [allOperations filteredArrayUsingPredicate:predicate];
        if([fileteredOperations count] > 0) {
            return YES;
        }
    }
    return NO;
}

- (void) markAssetAsDownloaded:(NSString *)identifier filePath:(NSString *)filePath {
    NSMutableDictionary *assets = [[self savedAssets] mutableCopy];
    if(!assets) {
        assets = [NSMutableDictionary dictionary];
    }
    [assets setObject:filePath forKey:identifier];
    [self setSavedAssets:assets];
}

- (PHAsset *)assetWithIdentifier:(NSString *)assetIdentifier {
    return [[PHAsset fetchAssetsWithLocalIdentifiers:@[assetIdentifier] options:nil] firstObject];
}

- (void) downloadAssets:(NSArray *)assets {
    @autoreleasepool {
        for (PHAsset *asset in assets) {
            if(asset) {
                if([self isAssetDownloading:asset] == NO) {
                    AXAssetDownloadOperation *operation = [[AXAssetDownloadOperation alloc] initWithAsset:asset];
                    operation.delegate = self;
                    [downloadQueue addOperation:operation];
                    [self postDelegateMethod:@selector(didStartDownloadingAsset:)
                                  withObject:asset];
                }
            }
        }
    }
}

- (NSString *)localPathForAsset:(PHAsset *_Nullable)asset {
    NSString *localPath = nil;
    if(asset) {
        NSString *fileName = [self.savedAssets valueForKey:asset.localIdentifier];
        if(!isEmpty(fileName)) {
            localPath = [[[AXAssetHandler sharedHandler] documentsDirectoryPath] stringByAppendingPathComponent:fileName];
        }
    }
    return localPath;
}

- (NSString *)documentsDirectoryPath {
    @autoreleasepool {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                             NSUserDomainMask, YES);
        return [paths firstObject];
    }
}

#pragma mark - AssetDownloadOperationDelegate
- (void) didFinishDownloadingAsset:(NSString *)assetIdentifier fileName:(NSString *)fileName {
    [[AXAssetHandler sharedHandler] markAssetAsDownloaded:assetIdentifier filePath:fileName];
    [self postDelegateMethod:@selector(didFinishDownloadingAsset:)
                  withObject:@{@"assetIdentifier":assetIdentifier,
                               @"fileName":fileName,
                               }];
}

- (void) didFinishWithError:(NSError *)error {
    DDLogDebug(@"Write Operation Failed: %@", error.localizedDescription);
    [self postDelegateMethod:@selector(didFinishWithError:)
                  withObject:error];
}

@end

@implementation AXAssetHandler (Delegation)
/**
 *  Multicast Delegatation
 */
- (void)addDelegate:(id)delegate {
    [self addDelegate:delegate delegateQueue:delegateDispatchQueue];
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue {
    // Asynchronous operation (if outside sipQueue)
    dispatch_block_t block = ^{
        [multicastSyncDelegate addDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(delegateQueueTag)) {
        block();
    } else {
        dispatch_async(delegateDispatchQueue, block);
    }
}

- (void)removeDelegate:(id)delegate {
    [self removeDelegate:delegate delegateQueue:delegateDispatchQueue];
}

- (void)removeDelegate:(id)delegate
         delegateQueue:(dispatch_queue_t)delegateQueue {
    // Synchronous operation
    
    dispatch_block_t block = ^{
        [multicastSyncDelegate removeDelegate:delegate delegateQueue:delegateQueue];
    };
    
    if (dispatch_get_specific(delegateQueueTag)) {
        block();
    } else {
        dispatch_sync(delegateDispatchQueue, block);
    }
}

- (void)removeAllDelegates {
    dispatch_block_t block = ^{
        [multicastSyncDelegate removeAllDelegates];
    };
    
    if (dispatch_get_specific(delegateQueueTag)) {
        block();
    } else {
        dispatch_sync(delegateDispatchQueue, block);
    }
}

- (void)postDelegateMethod:(SEL)selector withObject:(id)object {
    if ([multicastSyncDelegate
         hasDelegateThatRespondsToSelector:selector]) // Atleast one of the
        // delegates implement
        // the method
    {
        // Notify all interested delegates.
        // This must be done serially to allow them to alter the element in a
        // thread-safe manner.
        
        GCDMulticastDelegateEnumerator *delegateEnumerator =
        [multicastSyncDelegate delegateEnumerator];
        
        dispatch_async(
                       dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                           @autoreleasepool {
                               id<AssetHandlerDelegate> delegate;
                               dispatch_queue_t dQueue;
                               //            DDLogInfo(@"Delegate Count: %lu",
                               //                      (unsigned long)[delegateEnumerator
                               //                      count]);
                               while ([delegateEnumerator getNextDelegate:&delegate
                                                            delegateQueue:&dQueue
                                                              forSelector:selector]) {
                                   dispatch_sync(dQueue, ^{
                                       @autoreleasepool {
                                           SuppressPerformSelectorLeakWarning(
                                                                              if (delegate != nil &&
                                                                                  [(NSObject *)delegate respondsToSelector:selector]) {
                                                                                  [(NSObject *)delegate performSelector:selector
                                                                                                             withObject:object];
                                                                              });
                                       }
                                   });
                               }
                           }
                       });
    }
}

@end

