#import <FSSwitchDataSource.h>
#import <FSSwitchPanel.h>

#import <SpringBoard/SpringBoard.h>

@interface BluetoothSwitch : NSObject <FSSwitchDataSource>
- (void)_bluetoothStateDidChange:(NSNotification *)notification;
@end

static FSSwitchState state;
static BluetoothManager *mrManager;

@implementation BluetoothSwitch

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bluetoothStateDidChange:) name:@"BluetoothPowerChangedNotification" object:nil];
        // iOS 11+
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bluetoothStateDidChange:) name:@"BluetoothStateChangedNotification" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_bluetoothStateDidChange:) name:@"BluetoothConnectionStatusChangedNotification" object:nil];

        mrManager = [%c(BluetoothManager) sharedInstance];
    }

    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [super dealloc];
}

- (void)_bluetoothStateDidChange:(NSNotification *)notification
{
    [[FSSwitchPanel sharedPanel] stateDidChangeForSwitchIdentifier:@"com.a3tweaks.switch.bluetooth"];
}

#pragma mark - FSSwitchDataSource

- (FSSwitchState)stateForSwitchIdentifier:(NSString *)switchIdentifier
{
    if ([mrManager respondsToSelector:@selector(bluetoothState)]) {
        // iOS 11 <
        BluetoothState state = [mrManager bluetoothState];
        if (state == BluetoothStateConnected || BluetoothStateDisconnected) {
            return FSSwitchStateOn;
        } else if (state == BluetoothStatePowerOff) {
            return FSSwitchStateOff;
        }
    } else {
        // iOS 10 >
        return [mrManager powered];
    }
}

- (void)applyState:(FSSwitchState)newState forSwitchIdentifier:(NSString *)switchIdentifier
{
    if (newState == FSSwitchStateIndeterminate)
        return;
    state = newState;

    [mrManager setPowered:newState];
    [mrManager setEnabled:newState];
}

@end
