//
//  MainViewController.h
//  PythonTest
//
//  Created by Christopher Collins on 16/06/13.
//  Copyright (c) 2013 Chris Collins. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)showInfo:(id)sender;

@end
