#import "Tweaks/YouTubeHeader/YTSettingsViewController.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItem.h"
#import "Tweaks/YouTubeHeader/YTSettingsSectionItemManager.h"
#import "Header.h"

@interface YTSettingsSectionItemManager (YouPiP)
- (void)updateYouTubeMusicPlusSectionWithEntry:(id)entry;
@end

static const NSInteger YouTubeMusicPlusSection = 500;

extern NSBundle *YouTubeMusicPlusBundle();
extern BOOL hideHUD();
extern BOOL oled();
extern BOOL oledKB();
extern BOOL ytMusicDisableHighContrastIcons();

// Settings
%hook YTAppSettingsPresentationData
+ (NSArray *)settingsCategoryOrder {
    NSArray *order = %orig;
    NSMutableArray *mutableOrder = [order mutableCopy];
    NSUInteger insertIndex = [order indexOfObject:@(1)];
    if (insertIndex != NSNotFound)
        [mutableOrder insertObject:@(YouTubeMusicPlusSection) atIndex:insertIndex + 1];
    return mutableOrder;
}
%end

%hook YTSettingsSectionItemManager
%new 
- (void)updateYouTubeMusicPlusSectionWithEntry:(id)entry {
    YTSettingsViewController *delegate = [self valueForKey:@"_dataDelegate"];
    NSBundle *tweakBundle = uYouPlusBundle();
    
    YTSettingsSectionItem *ytMusicDisableHighContrastIcons = [[%c(YTSettingsSectionItem) alloc] initWithTitle:@"Revert The High Contrast Icons (YTMusicDisableHighContrastIcons)" titleDescription:@"App restart is required."];
    ytMusicDisableHighContrastIcons.hasSwitch = YES;
    ytMusicDisableHighContrastIcons.switchVisible = YES;
    ytMusicDisableHighContrastIcons.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"ytMusicDisableHighContrastIcons_enabled"];
    ytMusicDisableHighContrastIcons.switchBlock = ^BOOL (YTSettingsCell *cell, BOOL enabled) {
        [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"ytMusicDisableHighContrastIcons_enabled"];
        return YES;
    };
    
    NSMutableArray <YTSettingsSectionItem *> *sectionItems = [NSMutableArray arrayWithArray:@[ytMusicDisableHighContrastIcons]];
    [delegate setSectionItems:sectionItems forCategory:YouTubeMusicPlusSection title:@"YouTubeMusicPlus" titleDescription:nil headerHidden:NO];
}

- (void)updateSectionForCategory:(NSUInteger)category withEntry:(id)entry {
    if (category == YouTubeMusicPlusSection) {
        [self updateYouTubeMusicPlusSectionWithEntry:entry];
        return;
    }
    %orig;
}
%end
