//
//  WVSSConfigController.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@protocol WVSSConfigControllerDelegate;

@interface WVSSConfigController : NSObject <NSTableViewDataSource, NSTableViewDelegate>

@property(nonatomic, strong) id<WVSSConfigControllerDelegate> delegate;

@property(nonatomic, strong) IBOutlet NSWindow *sheet;
@property(nonatomic, strong) IBOutlet NSView *sheetContents;

@property(nonatomic, strong) IBOutlet NSTableView *urlTable;
@property(nonatomic, strong) IBOutlet NSTextField *urlsURLField;
@property(nonatomic, strong) IBOutlet NSButton *fetchURLCheckbox;

- (instancetype)initWithUserDefaults:(NSUserDefaults *)userDefaults;
- (void)synchronize;

- (NSArray *)addresses;
- (void)appendAddress;
- (void)removeAddressAtIndex:(NSInteger)index;

- (IBAction)addRow:(id)sender;
- (IBAction)removeRow:(id)sender;

- (IBAction)dismissConfigSheet:(id)sender;
- (IBAction)toggleFetchingURLs:(id)sender;
- (IBAction)tableViewCellDidEdit:(id)sender;

- (void)fetchAddresses;

- (NSWindow *)configureSheet;

@end

@protocol WVSSConfigControllerDelegate <NSObject>

- (void)configController:(WVSSConfigController *)configController dismissConfigSheet:(NSWindow *)sheet;

@end
