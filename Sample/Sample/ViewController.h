//
//  ViewController.h
//  Sample
//
//  Created by Ross Gibson on 30/08/2013.
//  Copyright (c) 2013 Awarai Studios Limited. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASBanker.h"

@interface ViewController : UIViewController <ASBankerDelegate>

@property (strong, nonatomic) ASBanker *banker;
@property (strong, nonatomic) SKProduct *product;

#pragma mark - Actions

- (IBAction)purchaseButtonTapped:(id)sender;
- (IBAction)restoreButtonTapped:(id)sender;

@end
