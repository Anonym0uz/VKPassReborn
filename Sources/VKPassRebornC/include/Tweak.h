#import <UIKit/UIKit.h>
@interface AppDelegate : UIResponder <UIApplicationDelegate>
@end

@interface VANavigationController : UINavigationController
@end

@interface VAViewController: UIViewController
@end

@interface ChatController: VAViewController

@end

@interface AudioSubscriptionChecker : NSObject
- (_Bool)subscriptionActive;
- (void)updateExpiresDate:(unsigned long long)arg1 musicSubscriptionPurchasedDuringSession:(_Bool)arg2;
@end

@interface VKController : VAViewController
@end

@interface VKMController : VKController
@end

@interface VKMScrollViewController : VKMController
@end

@protocol DeselectableTableController <NSObject>
- (void)VKMTablePerformDeselect:(_Bool)arg1;
@end

@interface VKMTableController : VKMScrollViewController <UITableViewDataSource, UITableViewDelegate, DeselectableTableController>
{
    UITableView *_tableView;
    UIColor *_separatorColor;
}

@property(retain, nonatomic) UIColor *separatorColor; // @synthesize separatorColor=_separatorColor;
@property(readonly, retain, nonatomic) UITableView *tableView; // @synthesize tableView=_tableView;
- (void)updateVisibleDecorations;
- (void)updateDecorationForHeader:(id)arg1 atSection:(long long)arg2 withStrategy:(id)arg3;
- (void)updateDecorationForCell:(id)arg1 atIndexPath:(id)arg2 withStrategy:(id)arg3;
- (void)updateBackgroundColor;
- (id)VKMTableView:(id)arg1 trailingSwipeActionsConfigurationForRowAtIndexPath:(id)arg2;
- (id)VKMTableView:(id)arg1 leadingSwipeActionsConfigurationForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 trailingSwipeActionsConfigurationForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 leadingSwipeActionsConfigurationForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 editActionsForRowAtIndexPath:(id)arg2;
- (void)layoutTableView;
- (_Bool)shouldTrackViewsForCellAtIndexPath:(id)arg1;
- (void)willDismissSearchController:(id)arg1 animated:(_Bool)arg2;
- (void)willPresentSearchController:(id)arg1 animated:(_Bool)arg2;
- (void)VKMSearchSetupHeader:(id)arg1;
- (struct CGPoint)getTargetContentOffset:(struct CGPoint)arg1 contentInset:(struct UIEdgeInsets)arg2 searchBar:(id)arg3;
- (void)redrawSectionFooters;
- (void)redrawSectionHeadersWithUppercasedTitle:(_Bool)arg1;
- (void)tableView:(id)arg1 didEndEditingRowAtIndexPath:(id)arg2;
- (void)tableView:(id)arg1 willBeginEditingRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2;
- (void)tableView:(id)arg1 willDisplayHeaderView:(id)arg2 forSection:(long long)arg3;
- (void)tableView:(id)arg1 willDisplayCell:(id)arg2 forRowAtIndexPath:(id)arg3;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 titleForHeaderInSection:(long long)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)tableView:(id)arg1 sectionForSectionIndexTitle:(id)arg2 atIndex:(long long)arg3;
- (id)sectionIndexTitlesForTableView:(id)arg1;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (void)VKMTablePerformDeselect:(_Bool)arg1;
- (double)VKMTableCellSeparatorInsetForIndexPath:(id)arg1;
- (void)model:(id)arg1 updated:(id)arg2;
- (void)actionSearchScopeChanged:(id)arg1;
- (void)VKMTableUpdatedIndex;
- (void)VKMTableDiscovered:(id)arg1 cell:(id)arg2;
- (void)updateFooter;
- (void)VKMSetupSearch;
- (void)VKMSetupSearchScopes:(id)arg1;
- (void)VKMScrollViewSetFooter:(id)arg1;
- (struct UIEdgeInsets)VKMScrollViewTeaserInsets;
- (id)VKMScrollView;
- (void)setEditing:(_Bool)arg1 animated:(_Bool)arg2;
- (void)viewWillLayoutSubviews;
- (void)viewWillAppear:(_Bool)arg1;
- (void)viewDidLoad;
- (void)loadView;
- (_Bool)VKMResetEditingOnEmptyIndex;
- (Class)VKMTableViewClass;
- (long long)VKMTableStyle;
- (id)backgroundDecorationStrategy;
- (id)initWithMain:(id)arg1 andModel:(id)arg2;
@end

@interface VKMLiveController : VKMTableController
@end

@interface MenuProfileView : UIView
@end

@interface SideMenuHeaderView : UIView
@property(retain, nonatomic) MenuProfileView *profileView;
@end

@interface SideMenuView : UIView
@property(retain, nonatomic) SideMenuHeaderView *menuHeaderView;
@end


@interface SideMenuViewController : VKMLiveController
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2;
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2;
- (void)setupBottomButton;
@end

@interface BaseSettingsController : VKMTableController
{
}

- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 cellForRowAtIndexPath:(id)arg2;
- (long long)tableView:(id)arg1 numberOfRowsInSection:(long long)arg2;
- (long long)numberOfSectionsInTableView:(id)arg1;
- (_Bool)tableView:(id)arg1 canEditRowAtIndexPath:(id)arg2;
- (void)render;
- (void)settingsCellRender:(id)arg1 enable:(_Bool)arg2 on:(_Bool)arg3;
- (id)detailCheckmarkCellWith:(id)arg1 detail:(id)arg2;
- (void)fillDetailDisclosureCell:(id)arg1 with:(id)arg2 detail:(id)arg3;
- (id)detailDisclosureCellWith:(id)arg1 detail:(id)arg2;
- (id)settingsCellWithTitle:(id)arg1 style:(long long)arg2 switch:(SEL)arg3;
- (Class)cellClass;
- (void)VKMScrollViewSetFooter:(id)arg1;
- (long long)VKMTableStyle;
- (void)viewWillAppear:(_Bool)arg1;
- (void)viewDidLoad;
- (id)initWithMain:(id)arg1 andModel:(id)arg2;

@end

@protocol IVKMCell <NSObject>
- (void)refresh;
- (_Bool)selected;
- (void)detach;
- (void)attach:(id)arg1;
- (void)addOpaque:(UIView *)arg1;
@end

@interface PassportCardCell : UITableViewCell
@end

@interface VKMCell : UITableViewCell <IVKMCell>

+ (void)prerender:(id)arg1;
- (void)thumbnailView:(id)arg1 selected:(id)arg2;
- (void)refresh;
- (_Bool)selected;
- (void)detach;
- (void)attach:(id)arg1;
- (void)addOpaque:(id)arg1;
- (void)prepareForReuse;
- (void)layoutSubviews;
- (id)initWithStyle:(long long)arg1 reuseIdentifier:(id)arg2;

@end

@interface ModernSettingsController : BaseSettingsController
{
    _Bool _APNSEnabled;
    _Bool _defaultRowSelected;
    PassportCardCell *_cellPassportCard;
    UIViewController *_passportPresentationController;
    VKMCell *_cellNotifications;
    VKMCell *_cellDontDisturb;
    VKMCell *_cellGeneral;
    VKMCell *_cellCalls;
    VKMCell *_cellAccount;
    VKMCell *_cellPrivacy;
    VKMCell *_cellBlacklist;
    VKMCell *_cellLogout;
    VKMCell *_cellBalance;
    VKMCell *_cellSubscriptions;
    VKMCell *_cellTransactions;
    VKMCell *_cellAbout;
    VKMCell *_cellHelp;
    VKMCell *_cellApperance;
    VKMCell *_cellBugTracker;
    VKMCell *_cellDevMenu;
    NSIndexPath *_selectedRow;
    NSIndexPath *_generalCellIndexPath;
}

@property(retain, nonatomic) NSIndexPath *generalCellIndexPath; // @synthesize generalCellIndexPath=_generalCellIndexPath;
@property(nonatomic) _Bool defaultRowSelected; // @synthesize defaultRowSelected=_defaultRowSelected;
@property(retain, nonatomic) NSIndexPath *selectedRow; // @synthesize selectedRow=_selectedRow;
@property(retain, nonatomic) VKMCell *cellDevMenu; // @synthesize cellDevMenu=_cellDevMenu;
@property(retain, nonatomic) VKMCell *cellBugTracker; // @synthesize cellBugTracker=_cellBugTracker;
@property(retain, nonatomic) VKMCell *cellApperance; // @synthesize cellApperance=_cellApperance;
@property(retain, nonatomic) VKMCell *cellHelp; // @synthesize cellHelp=_cellHelp;
@property(retain, nonatomic) VKMCell *cellAbout; // @synthesize cellAbout=_cellAbout;
@property(retain, nonatomic) VKMCell *cellTransactions; // @synthesize cellTransactions=_cellTransactions;
@property(retain, nonatomic) VKMCell *cellSubscriptions; // @synthesize cellSubscriptions=_cellSubscriptions;
@property(retain, nonatomic) VKMCell *cellBalance; // @synthesize cellBalance=_cellBalance;
@property(retain, nonatomic) VKMCell *cellLogout; // @synthesize cellLogout=_cellLogout;
@property(retain, nonatomic) VKMCell *cellBlacklist; // @synthesize cellBlacklist=_cellBlacklist;
@property(retain, nonatomic) VKMCell *cellPrivacy; // @synthesize cellPrivacy=_cellPrivacy;
@property(retain, nonatomic) VKMCell *cellAccount; // @synthesize cellAccount=_cellAccount;
@property(retain, nonatomic) VKMCell *cellCalls; // @synthesize cellCalls=_cellCalls;
@property(retain, nonatomic) VKMCell *cellGeneral; // @synthesize cellGeneral=_cellGeneral;
@property(retain, nonatomic) VKMCell *cellDontDisturb; // @synthesize cellDontDisturb=_cellDontDisturb;
@property(retain, nonatomic) VKMCell *cellNotifications; // @synthesize cellNotifications=_cellNotifications;
@property(retain, nonatomic) UIViewController *passportPresentationController; // @synthesize passportPresentationController=_passportPresentationController;
@property(retain, nonatomic) PassportCardCell *cellPassportCard; // @synthesize cellPassportCard=_cellPassportCard;
- (id)passportView;
- (id)dashboardConfiguration;
- (_Bool)dashboardEnabled;
- (double)passportHeight;
- (_Bool)VKMControllerMessengerSupportLargeTitle;
- (id)orwellScreen;
- (id)VKMControllerStatsRef;
- (void)showWebAppController:(id)arg1;
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForRowAtIndexPath:(id)arg2;
- (double)tableView:(id)arg1 heightForFooterInSection:(long long)arg2;
- (_Bool)tableView:(id)arg1 shouldHighlightRowAtIndexPath:(id)arg2;
- (id)tableView:(id)arg1 viewForHeaderInSection:(long long)arg2;
- (double)tableView:(id)arg1 heightForHeaderInSection:(long long)arg2;
- (void)timePickerCancel:(id)arg1;
- (void)timePicker:(id)arg1 selectedTime:(id)arg2;
- (void)handleTokenChangedAction:(id)arg1;
- (void)handleSpecialSettingsMenuGesture:(id)arg1;
- (_Bool)checkOrNotifyPushEnabled;
- (void)actionProfilePhoto:(id)arg1;
- (void)render;
- (_Bool)APNSEnabled;
- (id)helpCells;
- (id)moneyCells;
- (_Bool)hidesSubscriptions;
- (void)showVC:(id)arg1;
- (void)viewDidAppear:(_Bool)arg1;
- (void)viewWillAppear:(_Bool)arg1;
- (void)viewDidLoad;
- (void)notificationActivity:(id)arg1;
- (id)initWithMain:(id)arg1 andModel:(id)arg2;
@end

@interface FeedController : VKMLiveController
@end

@interface ProfileWallController : FeedController
@end

@interface UserWallController : ProfileWallController
@property(retain, nonatomic) UIBarButtonItem *qrButton;
@property(retain, nonatomic) VANavigationController *navigationController;
@end

@interface SelfWallController : UserWallController
@end

@interface BaseSectionedSettingsController : BaseSettingsController
@end

@interface AboutViewController : BaseSectionedSettingsController
- (void)tableView:(id)arg1 didSelectRowAtIndexPath:(id)arg2;
- (id)cellTitleForCell:(unsigned long long)arg1;
@end
