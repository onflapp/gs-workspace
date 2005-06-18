/* PrefController.m
 *  
 * Copyright (C) 2003 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: August 2001
 *
 * This file is part of the GNUstep GWRemote application
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA 02111 USA.
 */


#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include "PrefController.h"
#include "GWSDServerPref.h"
#include "GWRemote.h"
#include "Functions.h"
#include "GNUstep.h"

static NSString *nibName = @"PrefWindow";

@implementation PrefController

- (void)dealloc
{
  RELEASE (preferences);
  RELEASE (win);
  [super dealloc];
}

- (id)init
{
  self = [super init];
    
  if(self) {
		if ([NSBundle loadNibNamed: nibName owner: self] == NO) {
      NSLog(@"Preferences: failed to load %@!", nibName);
    } 
  }
  
  return self;
}

- (void)awakeFromNib
{
#define ADD_PREF_VIEW(c) \
currentPref = (id<PreferencesProtocol>)[[c alloc] init]; \
[popUp addItemWithTitle: [c prefName]]; \
[preferences addObject: currentPref]; \
RELEASE (currentPref)

  if ([win setFrameUsingName: @"preferencesWin"] == NO) {
    [win setFrame: NSMakeRect(100, 100, 396, 310) display: NO];
  }
  [win setDelegate: self];  

  preferences = [[NSMutableArray alloc] initWithCapacity: 1];

  while ([[popUp itemArray] count] > 0) {
    [popUp removeItemAtIndex: 0];
  }

  ADD_PREF_VIEW ([GWSDServerPref class]);
//  ADD_PREF_VIEW ([XTermPref class]);

  currentPref = nil;
  
  [popUp selectItemAtIndex: 0];
  [self activatePrefView: popUp];
}

- (void)activate
{
  [win makeKeyAndOrderFront: nil];
}

- (void)addPreference:(id <PreferencesProtocol>)anobject
{
  [preferences addObject: anobject]; 
  [popUp addItemWithTitle: [anobject prefName]];
}

- (void)removePreference:(id <PreferencesProtocol>)anobject
{
  NSString *prefName = [anobject prefName];
  int i = 0;
  
  for (i = 0; i < [preferences count]; i++) {
    id pref = [preferences objectAtIndex: i];
  
    if ([[pref prefName] isEqual: prefName]) {
      [preferences removeObject: pref];
      break;
    }
  }
  
  [popUp removeItemWithTitle: prefName];
}

- (IBAction)activatePrefView:(id)sender
{
  NSString *prefName = [sender titleOfSelectedItem];
  int i;
	
  if(currentPref != nil) {
    if([[currentPref prefName] isEqualToString: prefName]) {
      return;
    }
    [[currentPref prefView] removeFromSuperview];
  }
	
  for (i = 0; i < [preferences count]; i++) {
    id <PreferencesProtocol>pref = [preferences objectAtIndex: i];		
    if([[pref prefName] isEqualToString: prefName]) {
      currentPref = pref;
      break;
    }
  }

  [viewsBox addSubview: [currentPref prefView]];  
}

- (void)activateServerPref
{
  [popUp selectItemWithTitle: [[GWSDServerPref class] prefName]];
  [self activatePrefView: popUp];
}

- (void)updateDefaults
{
  [win saveFrameUsingName: @"preferencesWin"];
}

- (id)myWin
{
  return win;
}

- (BOOL)windowShouldClose:(id)sender
{
  [self updateDefaults];
	return YES;
}

@end
