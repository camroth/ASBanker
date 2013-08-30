//
//  ViewController.m
//  Sample
//
//  Created by Ross Gibson on 30/08/2013.
//  Copyright (c) 2013 Awarai Studios Limited. All rights reserved.
//

#import "ViewController.h"

@interface ViewController () {
    IBOutlet UIButton *purchaseButton;
    IBOutlet UIButton *restoreButton;
    IBOutlet UIActivityIndicatorView *activityIndicator;
}

@end

@implementation ViewController

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
	self.banker = [[ASBanker alloc] init];
	_banker.delegate = self;
	[_banker fetchProducts:@[@"com.awaraistudios.testapp.upgrade"]]; // This is not a valid product, please change for your own.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Actions

- (IBAction)purchaseButtonTapped:(id)sender {
    [activityIndicator startAnimating];
	purchaseButton.hidden = YES;
	restoreButton.hidden = YES;
	
	[_banker purchaseItem:_product];
}

- (IBAction)restoreButtonTapped:(id)sender {
    [activityIndicator startAnimating];
	purchaseButton.hidden = YES;
	restoreButton.hidden = YES;
	
	[_banker restorePurchases];
}

#pragma mark - ASInAppPurchaseDelegate

// Required

- (void)bankerFailedToConnect {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Alert view title") message:NSLocalizedString(@"Something went wrong whilst trying to connect to the iTunes Store. Please try again.", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil];
	[av show];
	
	[activityIndicator stopAnimating];
}

- (void)bankerNoProductsFound {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Alert view title") message:NSLocalizedString(@"Something went wrong whilst trying to connect to the iTunes Store. Please try again.", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil];
	[av show];
	
	[activityIndicator stopAnimating];
}

- (void)bankerFoundProducts:(NSArray *)products {
    _product = [products objectAtIndex:0];
	
	NSString *title = [NSString stringWithFormat:@"Purchase: %@", [_product localizedPrice]];
	[purchaseButton setTitle:title forState:UIControlStateNormal];
	
	[activityIndicator stopAnimating];
	purchaseButton.hidden = NO;
	restoreButton.hidden = NO;
}

- (void)bankerFoundInvalidProducts:(NSArray *)products {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Alert view title") message:NSLocalizedString(@"Something went wrong whilst trying to connect to the iTunes Store. Please try again.", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil];
	[av show];
	
	[activityIndicator stopAnimating];
}

- (void)bankerProvideContent:(SKPaymentTransaction *)paymentTransaction {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	[defaults setBool:YES forKey:@"InAppPurchase"];
	[defaults synchronize];
	
	UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Nice one!", @"Alert view title") message:NSLocalizedString(@"You've been updraded. Thanks for your support, we hope you enjoy the app.", @"Alert message") delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil];
	[av show];
}

- (void)bankerPurchaseComplete:(SKPaymentTransaction *)paymentTransaction {
    
}

- (void)bankerPurchaseFailed:(NSString *)productIdentifier withError:(NSString *)errorDescription {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops!", @"Alert view title") message:NSLocalizedString(@"Something went wrong whilst trying to connect to the iTunes Store. Please try again.", @"Alert message") delegate:nil cancelButtonTitle:NSLocalizedString(@"OK", @"Button title") otherButtonTitles:nil];
	[av show];
	
	[activityIndicator stopAnimating];
	purchaseButton.hidden = NO;
	restoreButton.hidden = NO;
}

- (void)bankerPurchaseCancelledByUser:(NSString *)productIdentifier {
    [activityIndicator stopAnimating];
	purchaseButton.hidden = NO;
	restoreButton.hidden = NO;
}

- (void)bankerFailedRestorePurchases {
    [activityIndicator stopAnimating];
	purchaseButton.hidden = NO;
	restoreButton.hidden = NO;
}

// Optional

- (void)bankerDidRestorePurchases {
   
}

@end
