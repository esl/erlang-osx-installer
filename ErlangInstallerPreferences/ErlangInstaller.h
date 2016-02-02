/*
 * ErlangInstaller.h
 */

#import <AppKit/AppKit.h>
#import <ScriptingBridge/ScriptingBridge.h>


@class ErlangInstallerApplication;



/*
 * Standard Suite
 */

@interface ErlangInstallerApplication : SBApplication

- (void) update;  // Update the list of releases in the menu

- (void) checkNewReleases;  // Check new releases value changed

@end

