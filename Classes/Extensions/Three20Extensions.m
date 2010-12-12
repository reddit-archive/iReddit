//
//  Three20Extensions.m
//  iReddit
//
//  Created by Ross Boucher on 6/18/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "Three20Extensions.h"

@implementation CheckGroupTableItem

@synthesize group, on;

+ (id)itemWithText:(NSString *)aText on:(BOOL)isOn URL:(NSString *)aURL group:(NSString *)aGroup;
{
	CheckGroupTableItem *item = [self itemWithText:aText  URL:aURL];
	
	item.group = aGroup;
	item.on = isOn;
	
	return item;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(group);
	[super dealloc];
}

@end

@implementation SettingsControlItem 

@synthesize key;


+ (id)textFieldControlWithTitle:(NSString *)aTitle text:(NSString *)aText placeholder:(NSString *)aPlaceholder key:(NSString *)aURL secure:(BOOL)isSecure
{
	UITextField *control = [[[UITextField alloc] init] autorelease];
	
	control.placeholder = aPlaceholder;
	control.text = aText;
	control.secureTextEntry = isSecure;
	control.autocorrectionType = UITextAutocorrectionTypeNo;
	control.autocapitalizationType = UITextAutocapitalizationTypeNone;
	control.enablesReturnKeyAutomatically = YES;
	
	SettingsControlItem *item = [self itemWithCaption:aTitle control:control];
	
	item.key = aURL;
	
	return item;
}

+ (id)switchControlWithTitle:(NSString *)aTitle on:(BOOL)isOn key:(NSString *)aURL
{
	UISwitch *control = [[[UISwitch alloc] init] autorelease];
	
	control.on = isOn;
	
	SettingsControlItem *item = [self itemWithCaption:aTitle control:control];
	
	item.key = aURL;
	
	return item;
}

- (void)dealloc
{
	TT_RELEASE_SAFELY(key);
	[super dealloc];
}

@end


@implementation TTSectionedDataSource (Reddit)

- (NSArray *)sectionsCopy
{
    return [_sections copy];
}

- (NSMutableArray *)itemsInSection:(unsigned int)aSection
{
    return [_items objectAtIndex:aSection];
}

@end
