//
//  ASBanker.h
//
//  Created by Ross Gibson on 30/08/2013.
//  Copyright (c) 2013 Awarai Studios Limited. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@protocol ASBankerDelegate <NSObject>
@required
- (void)bankerFailedToConnect;
- (void)bankerNoProductsFound;
- (void)bankerFoundProducts:(NSArray *)products;
- (void)bankerFoundInvalidProducts:(NSArray *)products;
- (void)bankerProvideContent:(SKPaymentTransaction *)paymentTransaction;
- (void)bankerPurchaseComplete:(SKPaymentTransaction *)paymentTransaction;
- (void)bankerPurchaseFailed:(NSString *)productIdentifier withError:(NSString *)errorDescription;
- (void)bankerPurchaseCancelledByUser:(NSString *)productIdentifier;
- (void)bankerFailedRestorePurchases;

@optional
- (void)bankerDidRestorePurchases;
@end


@interface ASBanker : NSObject <SKPaymentTransactionObserver, SKProductsRequestDelegate>

@property (nonatomic, assign) UIViewController <ASBankerDelegate> *delegate;
@property (strong, nonatomic) SKProductsRequest *productsRequest;

- (BOOL)canMakePurchases;
- (void)fetchProducts:(NSArray *)productIdentifiers;
- (void)failedToConnect;
- (void)noProductsFound;
- (void)foundProducts:(NSArray *)products;
- (void)foundInvalidProducts:(NSArray *)products;
- (void)purchaseItem:(SKProduct *)product;
- (void)restorePurchases;
- (void)provideContent:(SKPaymentTransaction *)paymentTransaction;

@end


@interface SKProduct (LocalizedPrice)
@property (nonatomic, readonly) NSString *localizedPrice;
@end

@implementation SKProduct (LocalizedPrice)
- (NSString *)localizedPrice {
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end
