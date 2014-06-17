//
//  ASBanker.m
//
//  Created by Ross Gibson on 30/08/2013.
//  Copyright (c) 2013 Awarai Studios Limited. All rights reserved.
//

#import "ASBanker.h"

@implementation ASBanker

- (id)init {
	self = [super init];
	if (self != nil) {
		[[SKPaymentQueue defaultQueue] addTransactionObserver:self];
		self.products = [@{} mutableCopy];
		self.bundleIdentifier = @"";
	}
	return self;
}

- (id)initWithDelegate:(id <ASBankerDelegate>)delegate {
	return [self initWithDelegate:delegate andBundleIdentifier:[[NSBundle mainBundle] bundleIdentifier]];
}

- (id)initWithDelegate:(id <ASBankerDelegate>)delegate andBundleIdentifier:(NSString *)bundleIdentifier {
	self = [super init];
	if (self) {
		self.delegate = delegate;
		self.bundleIdentifier = bundleIdentifier;
	}
	return self;
}

- (void)dealloc {
	self.productsRequest.delegate = nil;
    self.productsRequest = nil;
	self.delegate = nil;
	
	[[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
}


- (BOOL)canMakePurchases {
    return [SKPaymentQueue canMakePayments];
}

- (void)fetchProducts:(NSArray *)productIdentifiers {
	if (productIdentifiers == nil) {
        [self failedToConnect];
    } else {
        NSSet *productIdentifiersSet = [NSSet setWithArray:productIdentifiers];
        
        self.productsRequest = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiersSet];
        _productsRequest.delegate = self;
        [_productsRequest start];
    }
}

- (void)fetchProductIdentifiers:(NSArray *)productIdentifiers {
	NSMutableArray *idents = [@[] mutableCopy];
	for (NSString *ident in productIdentifiers) {
		if (![self.products objectForKey:ident]) {
			NSString *fullIdentifier = [NSString stringWithFormat:@"%@.%@", self.bundleIdentifier, ident];
			[idents addObject:fullIdentifier];
		}
	}
	[self fetchProducts:[NSArray arrayWithArray:idents]];
}

- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response {
    NSArray *products = response.products;
	
	if (products == nil || [products count] == 0) {
		[self noProductsFound];
	} else {
		[self foundProducts:products];
	}
	
	if (response.invalidProductIdentifiers != nil && [response.invalidProductIdentifiers count] > 0) {
        [self foundInvalidProducts:response.invalidProductIdentifiers];
	}
    
    self.productsRequest = nil;
}

- (void)request:(SKRequest *)request didFailWithError:(NSError *)error {
	[self failedToConnect];
}

- (void)failedToConnect {
	if ([self.delegate respondsToSelector:@selector(bankerFailedToConnect)]) {
		[_delegate performSelector:@selector(bankerFailedToConnect)];
	}
}

- (void)noProductsFound {
	if ([self.delegate respondsToSelector:@selector(abankerNoProductsFound)]) {
		[_delegate performSelector:@selector(bankerNoProductsFound)];
	}
}

- (void)foundProducts:(NSArray *)products {
	for (SKProduct *product in products) {
		[self.products setObject:product forKey:[product productIdentifier]];
	}
	
	if ([self.delegate respondsToSelector:@selector(bankerFoundProducts:)]) {
		[_delegate performSelector:@selector(bankerFoundProducts:) withObject:[self arrayOfProducts]];
	}
}

- (void)foundInvalidProducts:(NSArray *)products {
	if ([self.delegate respondsToSelector:@selector(bankerFoundInvalidProducts:)]) {
		[_delegate performSelector:@selector(bankerFoundInvalidProducts:) withObject:products];
	}
}

- (void)purchaseItem:(SKProduct *)product {
    if (product == nil) {
        [self noProductsFound];
    } else {
        SKPayment *payment = [SKPayment paymentWithProduct:product];
        [[SKPaymentQueue defaultQueue] addPayment:payment];
    }
}

- (void)restorePurchases {
    [[SKPaymentQueue defaultQueue] restoreCompletedTransactions];
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction {
	[[NSUserDefaults standardUserDefaults] setValue:transaction.transactionReceipt forKey:transaction.payment.productIdentifier];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)provideContent:(SKPaymentTransaction *)paymentTransaction {
    if ([self.delegate respondsToSelector:@selector(bankerProvideContent:)]) {
        [_delegate performSelector:@selector(bankerProvideContent:) withObject:paymentTransaction];
	}
}

- (NSArray *)arrayOfProducts {
	NSMutableArray *array = [@[] mutableCopy];
	for (NSString *key in [self.products allKeys]) {
		[array addObject:self.products[key]];
	}
	return [NSArray arrayWithArray:array];
}

- (void)completeTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction];
    [self provideContent:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
	
    if ([self.delegate respondsToSelector:@selector(bankerPurchaseComplete:)]) {
		[_delegate performSelector:@selector(bankerPurchaseComplete:) withObject:transaction];
	}
}

- (void)restoreTransaction:(SKPaymentTransaction *)transaction {
    [self recordTransaction:transaction.originalTransaction];
    [self provideContent:transaction];
    [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    
    if ([self.delegate respondsToSelector:@selector(bankerPurchaseComplete:)]) {
		[_delegate performSelector:@selector(bankerPurchaseComplete:) withObject:transaction.originalTransaction];
	}
}

- (void)failedTransaction:(SKPaymentTransaction *)transaction {
	if (transaction.error.code != SKErrorPaymentCancelled) {
		if ([self.delegate respondsToSelector:@selector(bankerPurchaseFailed: withError:)]) {
			[_delegate performSelector:@selector(bankerPurchaseFailed: withError:) withObject:transaction.payment.productIdentifier withObject:[transaction.error localizedDescription]];
		}
    } else {
		if ([self.delegate respondsToSelector:@selector(bankerPurchaseCancelledByUser:)]) {
			[_delegate performSelector:@selector(bankerPurchaseCancelledByUser:) withObject:transaction.payment.productIdentifier];
		}
	}
	
	[[SKPaymentQueue defaultQueue] finishTransaction:transaction];
}

- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
            case SKPaymentTransactionStatePurchasing:
                break;
				
            case SKPaymentTransactionStatePurchased:
                [self completeTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateFailed:
                [self failedTransaction:transaction];
                break;
				
            case SKPaymentTransactionStateRestored:
                [self restoreTransaction:transaction];
                break;
				
            default:
                break;
        }
    }
}

- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue {
    if ([self.delegate respondsToSelector:@selector(bankerDidRestorePurchases)]) {
		[_delegate performSelector:@selector(bankerDidRestorePurchases)];
	}
}

- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error {
    if ([self.delegate respondsToSelector:@selector(bankerFailedRestorePurchases)]) {
		[_delegate performSelector:@selector(bankerFailedRestorePurchases)];
	}
}

@end
