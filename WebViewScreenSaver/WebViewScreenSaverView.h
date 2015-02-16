//
//  WebViewScreenSaverView.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
//
//  Copyright 2010 Alastair Tse.
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

#import <Foundation/Foundation.h>
#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

// A simple screen saver that is a configurable webview driven from a list
// of URLs.
@interface WebViewScreenSaverView : ScreenSaverView

@property (nonatomic, strong) IBOutlet NSWindow *sheet;
@property (nonatomic, strong) IBOutlet NSTableView *urlList;
@property (nonatomic, strong) IBOutlet NSTextField *urlsURLField;
@property (nonatomic, strong) IBOutlet NSButton *fetchURLCheckbox;

@property (nonatomic, strong) NSMutableData *receivedData;
@property (nonatomic, strong) NSMutableArray *urls;
@property (nonatomic, copy) NSString *urlsURL;
@property (nonatomic, strong) NSURLConnection *connection;
@property (nonatomic, assign) BOOL shouldFetchURLs;


- (IBAction)dismissConfigSheet:(id)sender;
- (IBAction)addRow:(id)sender;
- (IBAction)removeRow:(id)sender;
- (IBAction)toggleFetchingURLs:(id)sender;

@end
