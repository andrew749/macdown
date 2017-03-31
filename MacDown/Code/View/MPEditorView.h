//
//  MPEditorView.h
//  MacDown
//
//  Created by Tzu-ping Chung  on 30/8.
//  Copyright (c) 2014 Tzu-ping Chung . All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MacDown-Swift.h"

@interface MPEditorView : NSTextView

@property BOOL scrollsPastEnd;
@property VimModeHelper *helper;

- (NSRect)contentRect;

@end
