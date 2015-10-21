//
//  ImageViewController.m
//  Imaginarium
//
//  Created by Joseph Gordon on 9/21/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "ImageViewController.h"
#import "URLViewController.h"

@interface ImageViewController () <UIScrollViewDelegate, UISplitViewControllerDelegate>
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImage *image;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) UIPopoverPresentationController *urlPopOverController;

@end

@implementation ImageViewController

-(void) setScrollView:(UIScrollView *)scrollView
{
    _scrollView = scrollView;
    
    //set the zoom scale
    _scrollView.minimumZoomScale = 0.2;
    _scrollView.maximumZoomScale = 2.0;
    
    //to get rid of warning must @interface ImageViewController() to @interface ImageViewController() <UIScrollViewDelegate>
    _scrollView.delegate = self;
    
    
    //set content size of scrollview
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
}

#pragma mark - UIScrollViewDelegate

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Navigation

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[URLViewController class]]){
        URLViewController *urlvc = (URLViewController *)segue.destinationViewController;
        
        /*
        if([segue isKindOfClass:[UIStoryboardPopoverSegue class]]) {
            UIStoryboardPopoverSegue *popoverSegue = (UIStoryboardPopoverSegue *)segue;
            self.urlPopoverController = popoverSegue.popoverController;
        }
         */
        
        urlvc.url = self.imageURL;
    }
}

-(BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"Show URL"]){
        return self.urlPopOverController ? NO: (self.imageURL ? YES:NO);
    } else{
        return [super shouldPerformSegueWithIdentifier:identifier sender:sender];
    }
}

#pragma mark - Setting the Image from the image's URL
-(void)setImageURL:(NSURL *)imageURL
{
    
    _imageURL = imageURL;
    //Call setImage.  Could block main view and makes it slow so do below instaed
    //self.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:self.imageURL]];
    
    
    //dismiss the url if it is already up.
    [self startDownloadingImage];
    
    
    
}

-(void)startDownloadingImage
{
    //clear the image incase there is already one in there to start fresh.
    self.image = nil;
    
    //if you have an image continue
    if (self.imageURL)
    {
        //start the spinner on the users view
        [self.spinner startAnimating];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL];
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        //asking the session to download
        NSURLSessionDownloadTask *task = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable localfile, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            //if no error continue on
            if(!error){
                //this takes a long time so after it is done (5 minutes maybe) check to be sure its still the same request from the user because it is multitasking/multithreading and takes time to complete.
                if ([request.URL isEqual:self.imageURL]){
                    //this is not on the main queue so must put it there.
                    UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:localfile]];
                    //put on the main queue by using this block.  This block is put at the end of the line on the main queue, but it will get done.
                    dispatch_async(dispatch_get_main_queue(), ^{ self.image = image; });
                }
            }
        }];
        
        //must resume or it will just keep spinning.
        [task resume];
    }
}

-(UIImageView *)imageView
{
    if (!_imageView) _imageView = [[UIImageView alloc]init];
    return _imageView;
}

-(UIImage *) image
{
    return self.imageView.image;
}

-(void) setImage:(UIImage *)image;
{
    
    self.scrollView.zoomScale = 1.0;
    self.imageView.image = image;
    self.imageView.frame = CGRectMake(0,0,image.size.width, image.size.height);
    
    //set content size of scrollview
    self.scrollView.contentSize = self.image ? self.image.size : CGSizeZero;
    
    //stop the spinner
    [self.spinner stopAnimating];
    

}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self.scrollView addSubview:self.imageView];
}

#pragma mark UISplitViewControllerDelegate
-(void)awakeFromNib
{
    self.splitViewController.delegate = self;
}

-(BOOL)splitViewController:(UISplitViewController *)svc
  shouldHideViewController:(nonnull UIViewController *)vc
             inOrientation:(UIInterfaceOrientation)orientation
{
    return UIInterfaceOrientationIsPortrait(orientation);
}

-(void) splitViewController:(UISplitViewController *)svc willHideViewController:(nonnull UIViewController *)aViewController withBarButtonItem:(nonnull UIBarButtonItem *)barButtonItem forPopoverController:(nonnull UIPopoverController *)pc
{
    barButtonItem.title = aViewController.title;
    self.navigationItem.leftBarButtonItem = barButtonItem;
}

-(void)splitViewController:(UISplitViewController *)svc willShowViewController:(nonnull UIViewController *)aViewController invalidatingBarButtonItem:(nonnull UIBarButtonItem *)barButtonItem
{
    self.navigationItem.leftBarButtonItem = nil;
}










@end
