//
//  AppDelegate.m
//  Photomania
//
//  Created by Joseph Gordon on 9/24/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "AppDelegate.h"
#import "FlickrFetcher.h"
#import "Photo+Flickr.h"
#import "AppDelegate+MOC.h"
#import "PhotoDatabaseAvailability.h"
#import "Photographer+Create.h"


@interface AppDelegate() <NSURLSessionDownloadDelegate>
@property (copy, nonatomic) void (^flickrDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *flickrDownloadSession;
@property (strong, nonatomic) NSTimer *flickrForegroundFetchTimer;
@property (strong, nonatomic) NSManagedObjectContext *photoDatabaseContext;

@end

//name of Flickr fetching background download session
#define FLICKR_FETCH @"Flickr Just Uploaded Fetch"

//how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_FLICKR_FETCH_INTERVAL (20*60)

//how long we will wait for a Flickr fetch to return when we are in the background
#define BACKGROUND_FLICKR_FETCH_TIMEOUT (10)

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
    
    //get the context
    self.photoDatabaseContext = [self createMainQueueManagedObjectContext];
    
    //as soon as we launch call a flickr fetch
    [self startFlickrFetch];
    
    return YES;
}

//background method
-(void) application:(UIApplication *)application performFetchWithCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    //[self startFlickrFetch];
    if(self.photoDatabaseContext) {
        NSURLSessionConfiguration *sessionConfig = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        sessionConfig.allowsCellularAccess = NO;
        sessionConfig.timeoutIntervalForRequest = BACKGROUND_FLICKR_FETCH_TIMEOUT; //want to be a good background citizen
        NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfig];
        NSURLRequest *request = [[NSURLRequest alloc]initWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]] ;
        NSURLSessionDownloadTask * task;
        task = [session downloadTaskWithRequest:request
                              completionHandler:^(NSURL *localfile, NSURLResponse *response, NSError *error){
                if (error) {
                    NSLog(@"Flickr background fetch failed %@", error.localizedDescription);
                    completionHandler(UIBackgroundFetchResultNoData);
                }else {
                        [self loadFlickrPhotosFromLocalURL:localfile
                                               intoContext:self.photoDatabaseContext
                                       andThenExecuteBlock:^{completionHandler(UIBackgroundFetchResultNewData);
                                       }
    
            ];
                }
        }];
                                                                   [task resume];
                                                                   }else {
    completionHandler(UIBackgroundFetchResultNoData);
                                                                   }
}

//background method
-(void) application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler
{
    self.flickrDownloadBackgroundURLSessionCompletionHandler = completionHandler;
}

#pragma mark - Database Context

-(void) setPhotoDatabaseContext:(NSManagedObjectContext *)photoDatabaseContext
{
    //posting to the radio station
    _photoDatabaseContext = photoDatabaseContext;
    
    //make sure "the user" Photographer exists at all times
     if (photoDatabaseContext)
     {
        [Photographer userInManagedObjectContext:photoDatabaseContext];
     }
    
    //Every 20 minutes start flickrfetch and get new info. FOREGROUND FETCHING
    [NSTimer scheduledTimerWithTimeInterval:20*60
                                    target:self
                                  selector:@selector(startFlickrFetch:)
                                  userInfo:nil
                                   repeats:YES];
    
    
    
    [self.flickrForegroundFetchTimer invalidate];
    self.flickrForegroundFetchTimer  = nil;
    
    if (self.photoDatabaseContext)
    {
        self.flickrForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_FLICKR_FETCH_INTERVAL
                                                                           target:self selector:@selector(startFlickrFetch:) userInfo:nil repeats:YES];
    }
    
    NSDictionary *userInfo = self.photoDatabaseContext ? @{ PhotoDatabaseAvailabilityContext : self.photoDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:PhotoDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
}

#pragma mark - Flickr Fetching



-(void) startFlickrFetch
{
    //creates a task and resumes the task and the delegate gets called instead of a completion andler
    [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        if(![downloadTasks count]) {
            NSURLSessionDownloadTask *task = [self.flickrDownloadSession downloadTaskWithURL:[FlickrFetcher URLforRecentGeoreferencedPhotos]];
            task.taskDescription = FLICKR_FETCH;
            [task resume];
        }else{
            for (NSURLSessionDownloadTask *task in downloadTasks) [task resume];
                 }
                 }];
}

-(void)startFlickrFetch:(NSTimer *)timer
{
    [self startFlickrFetch];
}

-(NSURLSession *) flickrDownloadSession
{
    //the NSURLSession we will use to fetch flickr data in the background
    //creates a session with a delegate
    
    if(!_flickrDownloadSession){
        static dispatch_once_t onceToken;
        dispatch_once (&onceToken, ^{
            NSURLSessionConfiguration *urlSessionConfig = [NSURLSessionConfiguration backgroundSessionConfigurationWithIdentifier:FLICKR_FETCH];
            urlSessionConfig.allowsCellularAccess = NO;
            _flickrDownloadSession = [NSURLSession sessionWithConfiguration:urlSessionConfig
                                                                   delegate:self
                                                              delegateQueue:nil];
            
        });
    }
    return _flickrDownloadSession;
}

- (NSArray *)flickrPhotosAtURL:(NSURL *)url
{
    
    NSDictionary *flickrPropertyList;
    NSData *flickrJSONData = [NSData dataWithContentsOfURL:url];
    if (flickrJSONData){
        flickrPropertyList = [NSJSONSerialization JSONObjectWithData:flickrJSONData
                                                                        options:0
                                                                         error:NULL];
    }
    NSLog(@"Flickr results = %@", flickrPropertyList);
    return [flickrPropertyList valueForKeyPath:FLICKR_RESULTS_PHOTOS];
    
}

-(void)loadFlickrPhotosFromLocalURL:(NSURL *)localFile
                        intoContext:(NSManagedObjectContext *)context
                andThenExecuteBlock:(void(^)())whenDone
{
    if(context){
        NSArray * photos = [self flickrPhotosAtURL:localFile];
        [context performBlock:^{
            [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
            [context save:NULL];
            if(whenDone) whenDone();
        }];
    }else{
        if(whenDone) whenDone();
    }
}

#pragma  mark - NSURLSessionDownloadDelegate

//required by the protocol
-(void)URLSession:(NSURLSession *)session
     downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
    if([downloadTask.taskDescription isEqualToString:FLICKR_FETCH]) {
        /*NSManagedObjectContext *context = self.photoDatabaseContext;
        if (context) {
            NSArray *photos = [self flickrPhotosAtURL:localFile];
            [context performBlock:^{
                [Photo loadPhotosFromFlickrArray:photos intoManagedObjectContext:context];
                [context save:NULL];
                
            }];
        }else {
            [self flickrDownloadTasksMightBeComplete];
        }*/
        
        
        [self loadFlickrPhotosFromLocalURL:localFile
                               intoContext:self.photoDatabaseContext
                       andThenExecuteBlock:^{
                           [self flickrDownloadTasksMightBeComplete];
                       }
         ];
    }
}

//required by protocol
-(void)URLSession:(NSURLSession *)session
     downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
    
}


//required by protocol
-(void)URLSession:(NSURLSession *)session downloadTask:(nonnull NSURLSessionDownloadTask *)downloadTask
     didWriteData:(int64_t)bytesWritten
totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
    
}

-(void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    if(error && (session ==self.flickrDownloadSession)){
        NSLog(@"Flickr background session failed: %@", error.localizedDescription);
        [self flickrDownloadTasksMightBeComplete];
              
    }
}

-(void)flickrDownloadTasksMightBeComplete
{
    if(self.flickrDownloadBackgroundURLSessionCompletionHandler){
        [self.flickrDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
            if (![downloadTasks count]) { //no more downloads left?
                void (^completionHandler)() = self.flickrDownloadBackgroundURLSessionCompletionHandler;
                if(completionHandler){
                    completionHandler();
                }
            }
        }];
    }
}

@end
