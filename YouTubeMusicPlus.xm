#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <objc/runtime.h>
#import <dlfcn.h>
#import "Header.h"

// Tweak's bundle for Localizations support - @PoomSmart - https://github.com/PoomSmart/YouPiP/commit/aea2473f64c75d73cab713e1e2d5d0a77675024f
NSBundle *YouTubeMusicPlusBundle() {
    static NSBundle *bundle = nil;
    static dispatch_once_t onceToken;
 	dispatch_once(&onceToken, ^{
        NSString *tweakBundlePath = [[NSBundle mainBundle] pathForResource:@"YouTubeMusicPlus" ofType:@"bundle"];
        bundle = [NSBundle bundleWithPath:tweakBundlePath];
    });
    return bundle;
}
NSBundle *tweakBundle = YouTubeMusicPlusBundle();

// 
BOOL ytDisableHighContrastIcons () {
      return [[NSUserDefaults standardUserDefaults] boolForKey:@"ytDisableHighContrastIcons_enabled"];
}

// YTMusicDisableHighContrastIcons - @arichorn - https://github.com/arichorn/YTMusicDisableHighContrastIcons
%group gYTDisableHighContrastIcons
%hook YTCommonColorPalette
- (UIColor *)textPrimary {
     if (self.pageStyle == 1) {
         return [UIColor colorWithWhite:0.565 alpha:1];
     }
         return [UIColor colorWithWhite:0.5 alpha:1];
 }
- (UIColor *)textSecondary {
    if (self.pageStyle == 1) {
        return [UIColor colorWithWhite:0.565 alpha:1];
     }
        return [UIColor colorWithWhite:0.5 alpha:1];
 }
%end
%end

// iOS 16 uYou crash fix - @level3tjg
%group iOS16
%hook OBPrivacyLinkButton
%new
- (instancetype)initWithCaption:(NSString *)caption
                     buttonText:(NSString *)buttonText
                          image:(UIImage *)image
                      imageSize:(CGSize)imageSize
                   useLargeIcon:(BOOL)useLargeIcon {
  return [self initWithCaption:caption
                    buttonText:buttonText
                         image:image
                     imageSize:imageSize
                  useLargeIcon:useLargeIcon
               displayLanguage:[NSLocale currentLocale].languageCode];
}
%end
%end

# pragma mark - ctor
%ctor {
    %init;
    if (![[[[NSUserDefaults standardUserDefaults] dictionaryRepresentation] allKeys] containsObject:@"relatedVideosAtTheEndOfYTVideos"]) { 
       [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"relatedVideosAtTheEndOfYTVideos"]; 
    }
    if (@available(iOS 16, *)) {
       %init(iOS16);
    }
    if (ytMusicDisableHighContrastIcons()) {
       %init(gYTDisableHighContrastIcons);
    }
}
