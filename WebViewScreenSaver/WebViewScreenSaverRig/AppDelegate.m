//
//  AppDelegate.m
//  WebViewScreenSaverRig
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import "AppDelegate.h"
#import "WVSSConfigController.h"

@interface AppDelegate () <WVSSConfigControllerDelegate>

@property (weak) IBOutlet NSWindow *window;
@property(strong) WVSSConfigController *configController;
@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
  NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
  self.configController = [[WVSSConfigController alloc] initWithUserDefaults:userDefaults];
  self.configController.delegate = self;

  NSWindow *window = [self.configController configureSheet];
  [self.window addChildWindow:window ordered:NSWindowAbove];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
  // Insert code here to tear down your application
}

- (void)configController:(WVSSConfigController *)configController dismissConfigSheet:(NSWindow *)sheet {
  [sheet close];
}

@end
