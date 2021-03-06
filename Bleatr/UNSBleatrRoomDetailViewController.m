//
//  UNSDetailViewController.m
//  Bleatr
//
//  Created by Mark Pauley on 2/9/14.
//  Copyright (c) 2014 Unsaturated. All rights reserved.
//

#import "UNSBleatrRoomDetailViewController.h"
#import "UNSBleatrRoom.h"
#import <AudioToolbox/AudioToolbox.h>

@interface UNSBleatrRoomDetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;

@property (strong,nonatomic) UNSBleatrRoom* room;
@end

@implementation UNSBleatrRoomDetailViewController

#pragma mark - Managing the detail item

+(SystemSoundID)bleatSoundID {
  static SystemSoundID bleatSoundID = 0;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    NSString *soundPath =  [[NSBundle mainBundle] pathForResource:@"Bleat" ofType:@"aif"];
    AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath: soundPath], &bleatSoundID);
  });
  return bleatSoundID;
}

- (void)setDetailItem:(id)newDetailItem
{
  if (_detailItem != newDetailItem) {
    _detailItem = newDetailItem;
    if(self.room) {
      [self.room removeObserver:self forKeyPath:@"bleats"];
    }
    self.room = (UNSBleatrRoom*)_detailItem;
    [self.room addObserver:self forKeyPath:@"bleats" options:NSKeyValueObservingOptionNew context:nil];
    
    // Update the view.
    [self configureView];
  }
  
  if (self.masterPopoverController != nil) {
    [self.masterPopoverController dismissPopoverAnimated:YES];
  }
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
  if([keyPath isEqualToString:@"bleats"]) {
    NSLog(@"BAAAH! (new bleat)");
    AudioServicesPlaySystemSound([[self class] bleatSoundID]);
  }
}

- (void)configureView
{
  // Update the user interface for the detail item.
  
  if (self.detailItem) {
    self.detailDescriptionLabel.text = [self.detailItem description];
  }
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  [self configureView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
  barButtonItem.title = NSLocalizedString(@"Home", @"Bleatr Room List");
  [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
  self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
  // Called when the view is shown again in the split view, invalidating the button and popover controller.
  [self.navigationItem setLeftBarButtonItem:nil animated:YES];
  self.masterPopoverController = nil;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
}

- (IBAction)postBleat:(id)sender {
  [self.room postBleat:@"BAAAAH!"];
}

@end
