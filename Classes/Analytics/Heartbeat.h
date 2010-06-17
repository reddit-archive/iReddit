//
//  Heartbeat.h
//  Heartbeat
//
//  Created by Shaun Harrison on 2/2/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HeartbeatSettings.h"


@interface Heartbeat : NSObject {
	
}

/*
 * Notify Heartbeat of a "hit".
 * This method should only be called once per launch.
 */
+ (void)postHitNotification;

#if HEARTBEAT_ENABLE_CRASH_REPORTS
/*
 * Checks if there are any crash report(s) to send, if so, send them to Heartbeat
 * Use if you wish to send crash report(s) without prompting the user
 */
+ (void)handleCrashReportIfPending;

/*
 * Checks to see if there are any check reports available.
 * This should be used with handleCrashReport to prompt the user before sending
 */
+ (BOOL)crashReportPending;

/*
 * Send available crash report(s) to Heartbeat.
 * Should be called if you want to prompt the user before sending the crash report.
 */
+ (void)handleCrashReport;

/*
 * Clears out pending crash reports.
 * Only needs to be called if the user is prompted and doesn't want to send the crash report.
 */
+ (void)clearCrashReports;
#endif

#if HEARTBEAT_CHECK_PIRACY
/*
 * Checks to see if the current running app is cracked.
 * Use with discretion.  As with any piracy detection system, there is a risk of
 * legitimate users being detected as pirated.
 *
 * You can set the HEARTBEAT_PIRACY_THRESHOLD setting in HeartbeatSettings.h to determine the
 * level of detection you want to use.
 */
+ (BOOL)isCracked;
#endif

@end
