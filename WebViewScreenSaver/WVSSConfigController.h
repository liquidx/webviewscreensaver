//
//  WVSSConfigController.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 26/04/2015.
//
//  Copyright 2015 Alastair Tse.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

#import <AppKit/AppKit.h>
#import <Foundation/Foundation.h>

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
- (IBAction)resetData:(id)sender;

- (IBAction)dismissConfigSheet:(id)sender;
- (IBAction)toggleFetchingURLs:(id)sender;
- (IBAction)tableViewCellDidEdit:(id)sender;

- (void)fetchAddresses;

- (NSWindow *)configureSheet;

@end

@protocol WVSSConfigControllerDelegate <NSObject>

- (void)configController:(WVSSConfigController *)configController
      dismissConfigSheet:(NSWindow *)sheet;

@end
