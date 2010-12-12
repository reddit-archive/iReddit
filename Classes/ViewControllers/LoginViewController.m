//
//  LoginViewController.m
//  Reddit2
//
//  Created by Ross Boucher on 6/15/09.
//  Copyright 2009 280 North. All rights reserved.
//

#import "LoginViewController.h"
#import "LoginController.h"
#import "iRedditAppDelegate.h"
#import "Constants.h"
#import "Three20Extensions.h"

@implementation LoginViewController

@synthesize delegate, context, usernameField, passwordField;

+ (void)presentWithDelegate:(id <LoginViewControllerDelegate>)aDelegate context:(id)aContext
{
	LoginViewController *controller = [[[self alloc] init] autorelease];
	
	controller.delegate = aDelegate;
	controller.context = aContext;
	
	[[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(loginDidStart:) name:RedditDidBeginLoggingInNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:controller selector:@selector(loginDidEnd:) name:RedditDidFinishLoggingInNotification object:nil];
	
	[[iRedditAppDelegate sharedAppDelegate].navController presentModalViewController:controller animated:YES];
}

- (void)dealloc
{
	self.delegate = nil;
	self.context = nil;
	self.usernameField = nil;
	self.passwordField = nil;

	[[NSNotificationCenter defaultCenter] removeObserver:self];

	[super dealloc];
}

- (void)loadView
{
	[super loadView];
	
	self.title = @"Login";	
	self.navigationBarTintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	self.navigationController.navigationBar.tintColor = [iRedditAppDelegate redditNavigationBarTintColor];
	
	self.tableView = [[[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped] autorelease];
	self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	self.tableView.backgroundColor = [UIColor colorWithRed:229.0/255.0 green:238.0/255.0 blue:1 alpha:1];

	UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
	cancelButton.frame = CGRectMake(10.0, 184.0, (TTApplicationFrame().size.width - 30.0) / 2.0, 40.0);
	[cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
	[cancelButton addTarget:self action:@selector(cancel:) forControlEvents:UIControlEventTouchUpInside];
	
	[self.tableView addSubview:cancelButton];
	
	loginButton = [[UIButton buttonWithType:UIButtonTypeRoundedRect] retain];
	loginButton.frame = CGRectMake(CGRectGetMaxX(cancelButton.frame) + 10.0, 184.0, (TTApplicationFrame().size.width - 30.0) / 2.0, 40.0);
	[loginButton setTitle:@"Login" forState:UIControlStateNormal];
	[loginButton addTarget:self action:@selector(login:) forControlEvents:UIControlEventTouchUpInside];
	
	statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(10.0, 145.0, CGRectGetWidth(self.view.frame) - 20.0, 24.0)];
	
	statusLabel.textAlignment = UITextAlignmentCenter;
	statusLabel.opaque = NO;
	statusLabel.backgroundColor = [UIColor clearColor];
	statusLabel.textColor = [UIColor darkTextColor];
	statusLabel.shadowColor = [UIColor whiteColor];
	statusLabel.shadowOffset = CGSizeMake(0, 1);
	
	[self.tableView addSubview:statusLabel];
	
	[self.tableView addSubview:loginButton];
	
	[self.view addSubview:self.tableView];
	
	[self performSelector:@selector(focus) withObject:nil afterDelay:0.5];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTTableViewController

- (void)cancel:(id)sender
{
	[self dismiss:sender];
}

- (void)dismiss:(id)sender
{
	if ([(id)self.delegate respondsToSelector:@selector(loginViewController:didFinishWithContext:)])
		[self.delegate loginViewController:self didFinishWithContext:self.context];

	[[iRedditAppDelegate sharedAppDelegate].navController dismissModalViewControllerAnimated:YES];
}

-(void)createModel 
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	
	UITextField *textField = [[[UITextField alloc] init] autorelease];
	TTTableControlItem *usernameItem = [[[TTTableControlItem alloc] init] autorelease];
	
	usernameItem.caption = @"Username";
	usernameItem.control = textField;
	
	textField.placeholder = @"splashy";
	textField.text = [defaults stringForKey:redditUsernameKey];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.enablesReturnKeyAutomatically = YES;
	textField.returnKeyType = UIReturnKeyNext;
	textField.delegate = (id <UITextFieldDelegate>)self;
	
	self.usernameField = textField;

	TTTableControlItem *passwordItem = [[[TTTableControlItem alloc] init] autorelease];
	textField = [[[UITextField alloc] init] autorelease];

	textField.placeholder = @"••••••";
	textField.text = [defaults stringForKey:redditPasswordKey];
	textField.autocorrectionType = UITextAutocorrectionTypeNo;
	textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
	textField.returnKeyType = UIReturnKeyGo;
	textField.enablesReturnKeyAutomatically = YES;
	textField.secureTextEntry = YES;
	textField.delegate = (id <UITextFieldDelegate>)self;

	passwordItem.caption = @"Password";
	passwordItem.control = textField;

	self.passwordField = textField;

	self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
			@"reddit Account Information", usernameItem, passwordItem, nil];
}

- (void)login:(id)sender
{
	[[LoginController sharedLoginController] loginWithUsername:usernameField.text password:passwordField.text];
}

- (void)loginDidStart:(NSNotification *)note
{
	[loginButton setEnabled:NO];
	statusLabel.text = @"Logging in...";
}

- (void)loginDidEnd:(NSNotification *)note
{
	[loginButton setEnabled:YES];

	if ([[LoginController sharedLoginController] isLoggedIn])
	{
		statusLabel.text = [NSString stringWithFormat:@"Logged in as %@", usernameField.text];
		[self performSelector:@selector(dismiss:) withObject:self afterDelay:1.5];

		[[NSUserDefaults standardUserDefaults] setObject:usernameField.text forKey:redditUsernameKey];
		[[NSUserDefaults standardUserDefaults] setObject:passwordField.text forKey:redditPasswordKey];
	}
	else
	{
		statusLabel.text = @"Unable to Login";
	}
}

- (void)textFieldShouldReturn:(UITextField *)aField
{
	if (aField == self.usernameField)
	{
		[self.passwordField becomeFirstResponder];
	}
	else
	{
		[self login:self];
	}
}

- (void)focus
{
	[self.usernameField becomeFirstResponder];
}

@end
