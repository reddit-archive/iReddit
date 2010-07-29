//
//  Three20Extensions.h
//  iReddit
//
//  Created by Ross Boucher on 6/18/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@interface SettingsControlItem : TTTableControlItem
{
	NSString *key;
}

@property (nonatomic, retain) NSString *key;

+ (id)textFieldControlWithTitle:(NSString *)aTitle text:(NSString *)aText placeholder:(NSString *)aPlaceholder key:(NSString *)aURL secure:(BOOL)isSecure;
+ (id)switchControlWithTitle:(NSString *)aTitle on:(BOOL)isOn key:(NSString *)aURL;

@end


@interface CheckGroupTableItem : TTTableTextItem
{
	NSString *group;
	BOOL	 on;
}

@property (nonatomic, copy) NSString *group;
@property (nonatomic, assign) BOOL on;

+ (id)itemWithText:(NSString *)aText on:(BOOL)isOn URL:(NSString *)aURL group:(NSString *)aGroup;

@end

@interface TTSectionedDataSource (Reddit)

- (NSArray *)sectionsCopy;

- (NSMutableArray *)itemsInSection:(unsigned int)aSection;

@end
