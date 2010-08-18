//
//  WebViewScreenSaverView.h
//  WebViewScreenSaver
//
//  Created by Alastair Tse on 8/8/10.
//  Copyright (c) 2010, Alastair Tse. All rights reserved.
//

#import <ScreenSaver/ScreenSaver.h>
#import <WebKit/WebKit.h>

// A simple screen saver that is a configurable webview driven from a list
// of URLs.
@interface WebViewScreenSaverView : ScreenSaverView  {
 @private
  WebView *webView_;
  // Options UI
  NSWindow *sheet_;
  NSTableView *urlList_;
  // Options Data
  NSMutableArray *urls_;
  NSInteger currentIndex_;
}

@property (nonatomic, retain) IBOutlet NSWindow *sheet;
@property (nonatomic, retain) IBOutlet NSTableView *urlList;

- (IBAction)dismissConfigSheet:(id)sender;
- (IBAction)addRow:(id)sender;
- (IBAction)removeRow:(id)sender;

@end
