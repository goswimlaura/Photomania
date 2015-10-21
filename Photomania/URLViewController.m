//
//  URLViewController.m
//  Photomania
//
//  Created by Joseph Gordon on 9/29/15.
//  Copyright © 2015 Laura Gordon. All rights reserved.
//

#import "URLViewController.h"

@interface URLViewController ()
@property (weak, nonatomic) IBOutlet UITextView *urlTextView;

@end

@implementation URLViewController

- (void)setUrl:(NSURL *)url
{
    _url =url;
    [self updateUI];
    
}

-(void) viewDidLoad
{
    [super viewDidLoad];
    [self updateUI];
    
}

- (void) updateUI
{
    self.urlTextView.text = [self.url absoluteString];
}
@end
