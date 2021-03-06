#import <FSSwitchDataSource.h>
#import <FSSwitchPanel.h>
#import <Foundation/Foundation.h>
#import <limits.h>
#import <ManagedConfiguration/ManagedConfiguration.h>

#define PLIST_PATH @"/var/mobile/Library/Preferences/com.flipswitch.autolock.plist"

@interface AutolockSwitch : NSObject <FSSwitchDataSource>
@end

%hook MCProfileConnection

- (void)_effectiveSettingsDidChange:(id)notification
{
    [[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:@"com.a3tweaks.switch.autolock"];
	%orig();
}

%end

@implementation AutolockSwitch

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
	int currentAutoLockValue = [[[[MCProfileConnection sharedConnection] effectiveParametersForValueSetting:@"maxInactivity"] objectForKey:@"value"] intValue];
    return (currentAutoLockValue == INT_MAX) ? FSSwitchStateOff : FSSwitchStateOn;
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
	if (newState == FSSwitchStateIndeterminate)
		return;
	
	NSMutableDictionary *prefsDict = [NSMutableDictionary dictionaryWithContentsOfFile:PLIST_PATH] ?: [NSMutableDictionary dictionary];
	NSNumber *toggledValue;
    if (newState) {
        toggledValue = [prefsDict objectForKey:@"autoLockValue"] ?: [NSNumber numberWithInt:60];
    } else {
        int currentAutoLockValue = [[[[MCProfileConnection sharedConnection] effectiveParametersForValueSetting:@"maxInactivity"] objectForKey:@"value"] intValue];
        if (currentAutoLockValue != INT_MAX) {
            [prefsDict setObject:[NSNumber numberWithInt:currentAutoLockValue] forKey:@"autoLockValue"];
            [prefsDict writeToFile:PLIST_PATH atomically:YES];
        }
        toggledValue = [NSNumber numberWithInt:INT_MAX];
    }
    [[MCProfileConnection sharedConnection] setValue:toggledValue forSetting:@"maxInactivity"];
}

@end
