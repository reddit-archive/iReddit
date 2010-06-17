//
//  Heartbeat.m
//  Heartbeat
//
//  Created by Shaun Harrison on 2/2/09.
//  Copyright 2009 enormego. All rights reserved.
//

#import "Heartbeat.h"
#import <SystemConfiguration/SCNetworkReachability.h>

#if HEARTBEAT_ENABLE_CRASH_REPORTS
#import <CrashReporter/CrashReporter.h>
#endif HEARTBEAT_ENABLE_CRASH_REPORTS

#import <CFNetwork/CFNetwork.h>

#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#include <netdb.h>

typedef enum {
    HBNetworkStatusOff = 0,
    HBNetworkStatusCellular,
    HBNetworkStatusWiFi
} HBNetworkStatus;

@interface Heartbeat (Private)
- (void)postToHeartbeatWithDictionary:(NSDictionary*)postDictionary url:(NSURL*)url;
- (HBNetworkStatus)connectionStatus;
- (NSString*)stackTraceForReport:(PLCrashReport*)report;
@end


@implementation Heartbeat

+ (void)initialize {
#if HEARTBEAT_ENABLE_CRASH_REPORTS
	NSError* error;
    if (![[PLCrashReporter sharedReporter] enableCrashReporterAndReturnError: &error]) {
        NSLog(@"Could not enable crash reporter: %@", error);
    }
#endif
}

+ (void)postHitNotification {
	Heartbeat* instance = [[Heartbeat alloc] init];
	[NSThread detachNewThreadSelector:@selector(postHitNotification) toTarget:instance withObject:nil];
	[instance release];
}

- (void)postHitNotification {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	HBNetworkStatus networkStatus = [self connectionStatus];
	
	if(networkStatus != HBNetworkStatusOff) {
		NSMutableDictionary* postDictionary = [[NSMutableDictionary alloc] init];
		[postDictionary setObject:HEARTBEAT_API_KEY forKey:@"key"];
		[postDictionary setObject:HEARTBEAT_APP_ID forKey:@"application"];
		[postDictionary setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
		[postDictionary setObject:[[NSDate date] description] forKey:@"timestamp"];
		[postDictionary setObject:[UIDevice currentDevice].model forKey:@"model"];
		[postDictionary setObject:[UIDevice currentDevice].systemName forKey:@"system_name"];
		[postDictionary setObject:[UIDevice currentDevice].systemVersion forKey:@"system_version"];
		[postDictionary setObject:(NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),kCFBundleVersionKey) forKey:@"app_version"];
		[postDictionary setObject:networkStatus == HBNetworkStatusCellular ? @"cellular" : @"wifi" forKey:@"network"];
#if HEARTBEAT_CHECK_PIRACY
		[postDictionary setObject:[[self class] isCracked] ? @"1" : @"0" forKey:@"pirated"];
#endif
		[self postToHeartbeatWithDictionary:postDictionary url:[NSURL URLWithString:@"http://"HEARTBEAT_DOMAIN@"/api/hit"]];
		[postDictionary release];
	}
	
	[pool release];
}

#if HEARTBEAT_ENABLE_CRASH_REPORTS
+ (void)handleCrashReportIfPending {
	if([[self class] crashReportPending]) {
		[[self class] handleCrashReport];
	}
}

+ (BOOL)crashReportPending {
	return [[PLCrashReporter sharedReporter] hasPendingCrashReport];
}

+ (void)handleCrashReport {
	Heartbeat* instance = [[Heartbeat alloc] init];
	[NSThread detachNewThreadSelector:@selector(handleCrashReport) toTarget:instance withObject:nil];
	[instance release];
}

- (void)handleCrashReport {
	NSAutoreleasePool* pool = [[NSAutoreleasePool alloc] init];
	PLCrashReporter* crashReporter = [PLCrashReporter sharedReporter];
	NSData* crashData;
	NSError* error;
	
	// Try loading the crash report
	crashData = [crashReporter loadPendingCrashReportDataAndReturnError: &error];
	if (crashData == nil) {
		NSLog(@"Could not load crash report: %@", error);
		goto finish;
	}
	
	// We could send the report from here, but we'll just print out
	// some debugging info instead
	PLCrashReport* report = [[[PLCrashReport alloc] initWithData: crashData error: &error] autorelease];
	
	if (report == nil) {
		NSLog(@"Could not parse crash report");
		goto finish;
	}
	
	NSString* systemName;
    switch (report.systemInfo.operatingSystem) {
        case PLCrashReportOperatingSystemMacOSX:
            systemName = @"Mac OS X";
            break;
        case PLCrashReportOperatingSystemiPhoneOS:
            systemName = @"iPhone OS";
            break;
        case PLCrashReportOperatingSystemiPhoneSimulator:
            systemName = @"Mac OS X";
            break;
        default:
			systemName = @"Unknown";
    }
	
	NSString* codeType;
    switch (report.systemInfo.architecture) {
        case PLCrashReportArchitectureARM:
            codeType = @"ARM (Native)";
            break;
        case PLCrashReportArchitectureX86_32:
            codeType = @"X86";
            break;
        case PLCrashReportArchitectureX86_64:
            codeType = @"X86-64";
            break;
        default:
            codeType = @"Unknown";
            break;
    }
	
	
	NSMutableDictionary* postDictionary = [[NSMutableDictionary alloc] init];
	[postDictionary setObject:HEARTBEAT_API_KEY forKey:@"key"];
	[postDictionary setObject:HEARTBEAT_APP_ID forKey:@"application"];
	[postDictionary setObject:[[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString*)kCFBundleVersionKey] forKey:@"app_version"];
	[postDictionary setObject:[UIDevice currentDevice].uniqueIdentifier forKey:@"udid"];
	[postDictionary setObject:report.signalInfo.code forKey:@"exception_code"];
	[postDictionary setObject:report.signalInfo.name forKey:@"exception_name"];
	[postDictionary setObject:[NSString stringWithFormat:@"0x%" PRIx64 "", report.signalInfo.address] forKey:@"exception_address"];
	[postDictionary setObject:[NSString stringWithFormat:@"%@ %@", systemName, report.systemInfo.operatingSystemVersion] forKey:@"os"];
	[postDictionary setObject:codeType forKey:@"code_type"];
	[postDictionary setObject:[self stackTraceForReport:report] forKey:@"stacktrace"];
	[postDictionary setObject:[report.systemInfo.timestamp description] forKey:@"timestamp"];
	[self postToHeartbeatWithDictionary:postDictionary url:[NSURL URLWithString:@"http://"HEARTBEAT_DOMAIN@"/api/crash"]];
	[postDictionary release];
	
	// Purge the report
finish:
	[crashReporter purgePendingCrashReport];
	[pool release];
}

+ (void)clearCrashReports {
	if([[self class] crashReportPending]) {
		[[PLCrashReporter sharedReporter] purgePendingCrashReport];
	}
}

/*
 This method was based off of the code used in plcrashutil
 @see http://plcrashreporter.googlecode.com/svn/trunk/Source/plcrashutil/main.m
 */
- (NSString*)stackTraceForReport:(PLCrashReport*)report {
	NSMutableString* stackTrace = [[NSMutableString alloc] init];
	
	for (PLCrashReportThreadInfo *thread in report.threads) {
		if (thread.crashed) {
			[stackTrace appendFormat:@"Crashed Thread:  %d\n", thread.threadNumber];
			break;
		}
	}
	
	[stackTrace appendFormat:@"\n"];
	
	/* Threads */
	for (PLCrashReportThreadInfo *thread in report.threads) {
		if (thread.crashed)
			[stackTrace appendFormat:@"Thread %d Crashed:\n", thread.threadNumber];
		else
			[stackTrace appendFormat:@"Thread %d:\n", thread.threadNumber];
		for (NSUInteger frame_idx = 0; frame_idx < [thread.stackFrames count]; frame_idx++) {
			PLCrashReportStackFrameInfo *frameInfo = [thread.stackFrames objectAtIndex: frame_idx];
			PLCrashReportBinaryImageInfo *imageInfo;
			
			/* Base image address containing instrumention pointer, offset of the IP from that base
			 * address, and the associated image name */
			uint64_t baseAddress = 0x0;
			uint64_t pcOffset = 0x0;
			const char *imageName = "\?\?\?";
			
			imageInfo = [report imageForAddress: frameInfo.instructionPointer];
			if (imageInfo != nil) {
				imageName = [[imageInfo.imageName lastPathComponent] UTF8String];
				baseAddress = imageInfo.imageBaseAddress;
				pcOffset = frameInfo.instructionPointer - imageInfo.imageBaseAddress;
			}
			
			[stackTrace appendFormat:@"%-4d%-36s0x%08" PRIx64 " 0x%" PRIx64 " + %" PRId64 "\n", frame_idx, imageName, frameInfo.instructionPointer, baseAddress, pcOffset];
		}
		[stackTrace appendFormat:@"\n"];
	}
	
	/* Images */
	[stackTrace appendFormat:@"Binary Images:\n"];
	NSMutableDictionary* imageDumps = [[NSMutableDictionary alloc] init];
	for (PLCrashReportBinaryImageInfo *imageInfo in report.images) {
		NSString *uuid;
		/* Fetch the UUID if it exists */
		if (imageInfo.hasImageUUID)
			uuid = imageInfo.imageUUID;
		else
			uuid = @"???";
		
		/* base_address - terminating_address file_name identifier (<version>) <uuid> file_path */
		NSString* line = [NSString stringWithFormat:@"0x%" PRIx64 " - 0x%" PRIx64 "  %s \?\?\? (\?\?\?) <%s> %s\n",
						  imageInfo.imageBaseAddress,
						  imageInfo.imageBaseAddress + imageInfo.imageSize,
						  [[imageInfo.imageName lastPathComponent] UTF8String],
						  [uuid UTF8String],
						  [imageInfo.imageName UTF8String]];
		[imageDumps setObject:line forKey:[NSNumber numberWithUnsignedInt:imageInfo.imageBaseAddress]];
	}
	
	NSArray* sortedArray = [[imageDumps allKeys] sortedArrayUsingSelector:@selector(compare:)];
	for(NSNumber* key in sortedArray) {
		[stackTrace appendString:[imageDumps objectForKey:key]];
	}
	
	[imageDumps release];
	
	return [stackTrace autorelease];
}
#endif

- (void)postToHeartbeatWithDictionary:(NSDictionary*)postDictionary url:(NSURL*)url {
	NSMutableData* body = [[[NSMutableData alloc] init] autorelease];
	
	NSString* boundary = @"0xKhTmLbOuNdArY";
	
	[body appendData:[[NSString stringWithFormat:@"--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	NSData* nextItem = [[NSString stringWithFormat:@"\r\n--%@\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding];
	BOOL firstLoop = YES;
	for(NSString* key in postDictionary) {
		if(firstLoop) {
			firstLoop = NO;
		} else {
			[body appendData:nextItem];
		}
		
		[body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
		[body appendData:[[postDictionary objectForKey:key] dataUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",boundary] dataUsingEncoding:NSUTF8StringEncoding]];
	
	CFHTTPMessageRef request = CFHTTPMessageCreateRequest(NULL, CFSTR("POST"), (CFURLRef)url, kCFHTTPVersion1_1); 
	CFHTTPMessageSetBody(request, (CFDataRef)body); 
	
	CFHTTPMessageSetHeaderFieldValue(request, CFSTR("HOST"), (CFStringRef)[url host]);
	CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Content-Length"), (CFStringRef)[NSString stringWithFormat:@"%d", [body length]]);
	CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Content-Type"), (CFStringRef)[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundary]); 
	CFHTTPMessageSetHeaderFieldValue(request, CFSTR("Accept"), CFSTR("application/xml")); 
	
	CFReadStreamRef requestStream = CFReadStreamCreateForHTTPRequest(NULL, request);
	CFReadStreamOpen(requestStream); 
	CFIndex numBytesRead = 0;
	firstLoop = YES;
	NSDate* startDate = [NSDate date];
	
#if HEARTBEAT_DEBUG
	NSMutableData* rData = [[NSMutableData alloc] init];
#endif	
	while(numBytesRead > 0 || firstLoop) {
		UInt8 buf[1024];
		numBytesRead = CFReadStreamRead(requestStream, buf, sizeof(buf)); 
		firstLoop = NO;
		
#if HEARTBEAT_DEBUG
		if(numBytesRead > 0) {
			[rData appendBytes:buf length:numBytesRead];
		}
#endif	
		if([startDate timeIntervalSinceNow] >= 60) break;
	}
	
#if HEARTBEAT_DEBUG
	CFHTTPMessageRef headers = (CFHTTPMessageRef)CFReadStreamCopyProperty(requestStream, kCFStreamPropertyHTTPResponseHeader);
	if (CFHTTPMessageIsHeaderComplete(headers)) {
		NSLog(@"[Heartbeat Debug] Response Status Code: %d", CFHTTPMessageGetResponseStatusCode(headers));
		NSLog(@"[Heartbeat Debug] Response Headers: %@", (NSDictionary *)CFHTTPMessageCopyAllHeaderFields(headers));
	} else {
		NSLog(@"[Heartbeat Debug] Could not find Headers");
	}
	
	NSLog(@"[Heartbeat Debug] Response Data: %@", [[[NSString alloc] initWithData:rData encoding:NSASCIIStringEncoding] autorelease]);
	[rData release];
#endif
	
	
	CFReadStreamClose(requestStream);
	CFRelease(requestStream); 
}

- (HBNetworkStatus)connectionStatus {
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr*)&zeroAddress);
	
    SCNetworkReachabilityFlags flags;
    BOOL gotFlags = SCNetworkReachabilityGetFlags(reachabilityRef, &flags);
    if (!gotFlags) {
        return HBNetworkStatusOff;
    } else {
		BOOL reachable = flags & kSCNetworkReachabilityFlagsReachable;
		
		BOOL noConnectionRequired = !(flags & kSCNetworkReachabilityFlagsConnectionRequired);
		if ((flags & kSCNetworkReachabilityFlagsIsWWAN)) {
			noConnectionRequired = YES;
		}
		
		if (reachable && noConnectionRequired) {
			if (flags & kSCNetworkReachabilityFlagsIsDirect) {
				return HBNetworkStatusOff;
			} else if (flags & HBNetworkStatusCellular) {
				return HBNetworkStatusCellular;
			}
			
			return HBNetworkStatusWiFi;
		} else {
			return HBNetworkStatusOff;
		}
	}
}

#if HEARTBEAT_CHECK_PIRACY
+ (BOOL)isCracked {
#if TARGET_IPHONE_SIMULATOR
	return NO;
#else
	static BOOL isCracked = NO;
	static BOOL didCheck = NO;
	if(didCheck) return isCracked;
	
#if HEARTBEAT_PIRACY_THRESHOLD >= 1
	if([[[NSBundle mainBundle] infoDictionary] objectForKey:@"SignerIdentity"] != nil) {
#if HEARTBEAT_PIRACY_THRESHOLD >= 2
		NSString* infoPath = [[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"];
		if([[NSString stringWithContentsOfFile:infoPath encoding:NSUTF8StringEncoding error:NULL] rangeOfString:@"</plist>"].location != NSNotFound) {
#if HEARTBEAT_PIRACY_THRESHOLD >= 3
			NSDate* infoModifiedDate = [[[NSFileManager defaultManager] fileAttributesAtPath:infoPath traverseLink:YES] fileModificationDate];
			NSDate* pkgInfoModifiedDate = [[[NSFileManager defaultManager] fileAttributesAtPath:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"PkgInfo"] traverseLink:YES] fileModificationDate];
			if([infoModifiedDate timeIntervalSinceReferenceDate] > [pkgInfoModifiedDate timeIntervalSinceReferenceDate]) {		
#endif
#endif
				isCracked = YES;
#if HEARTBEAT_PIRACY_THRESHOLD >= 2
#if HEARTBEAT_PIRACY_THRESHOLD >= 3
			}
#endif
		}
#endif
	}	
#endif
	
	didCheck = YES;
	
	return isCracked;
#endif
}
#endif

@end
