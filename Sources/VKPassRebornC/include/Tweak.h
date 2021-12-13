#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@end

//@interface VANavigationController : UINavigationController
//
//@end

@interface VAViewController: UIViewController
@end

@interface ChatController: VAViewController

@end

@interface AudioSubscriptionChecker : NSObject
- (_Bool)subscriptionActive;
- (void)updateExpiresDate:(unsigned long long)arg1 musicSubscriptionPurchasedDuringSession:(_Bool)arg2;
@end
