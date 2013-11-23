//
//  TrackerInterface.m
//  Popup
//
//  Created by lahwran on 8/25/12.
//

#import "TrackerInterface.h"
#import "MenubarController.h"
#import "PanelController.h"
#import "GCDAsyncSocket.h"

#define ENCODING NSUTF8StringEncoding

@implementation TrackerInterface

@synthesize prompt = _prompt;
@synthesize status = _status;
@synthesize input = _input;
@synthesize messages = _messages;
@synthesize context = _context;
@synthesize suggestions = _suggestions;

@synthesize panel = _panel;
@synthesize menu = _menu;
@synthesize socket = _socket;

@synthesize delay = _delay;

- (TrackerInterface*)initWithMenuBar:(MenubarController*)menu withPanel:(PanelController*)panel {
    self = [super init];
    
    self.menu = menu;
    self.panel = panel;
    [self.panel setTrackerInterface:self];
    
    self.status = @"not connected";
    self.prompt = nil;
    self.delay = 0.1;
        
    return self;
}

- (void)connectionBegan:(GCDAsyncSocket*)socket {
    self.socket = socket;
    self.status = @"connecting";
    [self waitForNext];
}

- (void)socket:(GCDAsyncSocket*)socket didConnectToHost:(NSString *)host port:(uint16_t)port {
    self.status = @"connected";
    self.delay = 0.1;
}

- (void)attemptReconnect {
    self.prompt = nil;
    NSError *err = nil;
    if (![self.socket connectToHost:@"127.0.0.1" onPort:18081 error:&err])
    {
        // If there was an error, it's likely something like "already connected" or "no delegate set"
        NSLog(@"I goofed: %@", err);
        self.status = @"error connecting";
    } else {
        [self connectionBegan:self.socket];
    }
}

- (void)socketDidDisconnect:(GCDAsyncSocket*)socket withError:(NSError *)err{
    NSLog(@"connection error: %@", err);
    self.status = [NSString stringWithFormat:@"disconnected (retry in %.01f)", self.delay];
    [self performSelector:@selector(attemptReconnect) withObject:nil afterDelay:self.delay];
    if (self.delay < 5.0) {
        self.delay = self.delay + 0.1;
    }
}

// ------------------------

- (void)waitForNext {
    [self.socket readDataToData:[@"\n" dataUsingEncoding:ENCODING] withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket*)socket didReadData:(NSData*)data withTag:(long)tag {
    NSString *text = [[NSString alloc] initWithData:data encoding:ENCODING];
    text = [text stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n"]];
    if (TD_DEBUG) {
        NSLog(@"received text: %@", text);
    }
    NSError *jsonerror = nil;
    NSDictionary *to_update = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonerror];
    if (jsonerror) {
        NSLog(@"json error: %@", jsonerror);
    } else {
        NSArray *new_prompt = [to_update objectForKey:@"prompt"];
        if (new_prompt != nil) {
            self.prompt = new_prompt;
        }
        NSArray *new_messages = [to_update objectForKey:@"messages"];
        if (new_messages != nil) {
            self.messages = new_messages;
        }
        NSArray *new_suggestions = [to_update objectForKey:@"suggestions"];
        if (new_suggestions != nil) {
            self.suggestions = new_suggestions;
        }
        NSArray *new_context = [to_update objectForKey:@"context"];
        if (new_context != nil) {
            self.context = new_context;
        }
        NSString *new_input = [to_update objectForKey:@"input"];
        if (new_input != nil) {
            [self.panel setInput:new_input];
            _input = new_input;
        }
        NSNumber *new_displayed = [to_update objectForKey:@"display"];
        if (new_displayed != nil) {
            [self.panel setHasActivePanel:[new_displayed boolValue]];
        }
        NSNumber *new_max_width = [to_update objectForKey:@"max_width"];
        if (new_max_width != nil) {
            self.menu.max_width = [new_max_width intValue];
        }
        NSNumber *should_quit = [to_update objectForKey:@"should_quit"];
        if (should_quit != nil && [should_quit boolValue]) {
            [NSApp terminate: nil];
        }
    }
    [self waitForNext];
}

// ------------------------

- (void)setStatus:(NSString *)new_status {
    if (TD_DEBUG) {
        NSLog(@"setting status: %@", new_status);
    }
    _status = new_status;
    [self updateMenuBar];
}

- (void)setPrompt:(NSArray *)new_prompt {
    _prompt = new_prompt;
    if (TD_DEBUG) {
        NSLog(@"setting prompt: %@", self.prompt);
    }
    [self updateMenuBar];
}

- (void)updateMenuBar {
    if (TD_DEBUG) {
        NSLog(@"updating menu bar");
    }
    if (self.prompt == nil) {
        [self.menu setText:[NSArray arrayWithObjects:self.status, @"todo tracker", nil]];
    } else {
        [self.menu setText:self.prompt];
    }
}

- (void)setMessages:(NSArray *)new_messages {
    _messages = new_messages;
    [self updatePanel];
}

- (void)setContext:(NSArray *)new_context {
    _context = new_context;
    [self updatePanel];
}

- (void)setSuggestions:(NSArray *)new_suggestions {
    _suggestions = new_suggestions;
    [self updatePanel];
}

- (void)updatePanel {
    NSArray *line_array = [NSArray array];
    line_array = [line_array arrayByAddingObjectsFromArray:self.suggestions];
    line_array = [line_array arrayByAddingObjectsFromArray:self.context];
    line_array = [line_array arrayByAddingObject:@""];
    line_array = [line_array arrayByAddingObjectsFromArray:self.messages];
    [self.panel setContentsText:line_array];
}

- (void)sendJson:(NSDictionary*)json {
    NSError *err = nil;
    NSData *jsondata = [NSJSONSerialization dataWithJSONObject:json options:0 error:&err];
    NSMutableData *messagedata = [NSMutableData dataWithData:jsondata];
    [messagedata appendData:[@"\n" dataUsingEncoding:ENCODING]];
    
    if (err) {
        NSLog(@"json error: %@", err);
    } else {
        [self.socket writeData:messagedata withTimeout:-1 tag:0];
    }
}

- (void)setInput:(NSString *)input {
    _input = input;
    NSDictionary *dict = [NSDictionary dictionaryWithObject:input forKey:@"input"];
    [self sendJson:dict];
}

- (void)doCommand {
    if (_input != nil && ![_input isEqualToString:@""]) {
        NSDictionary *dict = [NSDictionary dictionaryWithObject:_input forKey:@"command"];
        [self sendJson:dict];
        _input = @"";
        [self.panel setInput:_input];
    }
}

- (void)navigateHistory:(NSString*)direction {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:direction forKey:@"navigate"];
    [self sendJson:dict];
}

- (void)indicateDisplay:(BOOL)displayed {
    NSDictionary *dict = [NSDictionary dictionaryWithObject:[NSNumber numberWithBool:displayed] forKey:@"display"];
    [self sendJson:dict];
}

@end
