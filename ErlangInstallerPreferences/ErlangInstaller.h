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

- (void) updateReleases;  // Update the list of releases in the menu

@end

