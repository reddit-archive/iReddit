//
//  LoginViewController.h
//  Reddit2
//
//  Created by Ross Boucher on 6/15/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Three20/Three20.h>

@protocol LoginViewControllerDelegate

- (void)loginViewController:(id)v didFinishWithContext:(id)c;

@end

@interface LoginViewController : TTTableViewController
{
	id <LoginViewControllerDelegate>delegate;
	id context;
	
	UITextField *usernameField;
	UITextField *passwordField;
	
	UIButton *loginButton;
	UILabel *statusLabel;
}

@property (nonatomic, retain) id <LoginViewControllerDelegate>delegate;
@property (nonatomic, retain) id context;
@property (nonatomic, retain) UITextField *usernameField;
@property (nonatomic, retain) UITextField *passwordField;

+ (void)presentWithDelegate:(id <LoginViewControllerDelegate>)aDelegate context:(id)aContext;

- (void)dismiss:(id)sender;

@end
