/* GWDesktopWindow.m
 *  
 * Copyright (C) 2005-2012 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale
 *         Riccardo Mottola
 * Date: January 2005
 *
 * This file is part of the GNUstep GWorkspace application
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

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

#import "GWDesktopWindow.h"

@implementation GWDesktopWindow

- (void)dealloc
{
  [super dealloc];
}

- (id)init
{	
  self = [super initWithContentRect: [[NSScreen mainScreen] frame]
                          styleMask: NSBorderlessWindowMask
			    backing: NSBackingStoreBuffered
                              defer: NO];
  if (self)
    {
      [self setReleasedWhenClosed: NO];
      [self setExcludedFromWindowsMenu: YES];
      [self setAcceptsMouseMovedEvents: YES];
      [self setCanHide: NO];
    }

  return self;
}

- (void)activate
{
  [self orderFront: nil];
}

- (void)deactivate
{
  [self orderOut: self];
}

- (id)desktopView
{
  return [self contentView];
}

- (void)openSelection:(id)sender
{
  [delegate openSelectionInNewViewer: NO];
}

- (void)openSelectionAsFolder:(id)sender
{
  [delegate openSelectionAsFolder];
}

- (void)openWith:(id)sender
{
  [delegate openSelectionWith];
}

- (void)newFolder:(id)sender
{
  [delegate newFolder];
}

- (void)newFile:(id)sender
{
  [delegate newFile];
}

- (void)duplicateFiles:(id)sender
{
  [delegate duplicateFiles];
}

- (void)recycleFiles:(id)sender
{
  [delegate recycleFiles];
}

- (void)deleteFiles:(id)sender
{
  [delegate deleteFiles];
}

- (void)setShownType:(id)sender
{
  [delegate setShownType: sender];
}

- (void)setExtendedShownType:(id)sender
{
  [delegate setExtendedShownType: sender];
}

- (void)setIconsSize:(id)sender
{
  [delegate setIconsSize: sender];
}

- (void)setIconsPosition:(id)sender
{
  [delegate setIconsPosition: sender];
}

- (void)setLabelSize:(id)sender
{
  [delegate setLabelSize: sender];
}

- (void)chooseLabelColor:(id)sender
{
  [delegate chooseLabelColor: sender];
}

- (void)chooseBackColor:(id)sender
{
  [delegate chooseBackColor: sender];
}

- (void)selectAllInViewer:(id)sender
{
  [delegate selectAllInViewer];
}

- (void)showTerminal:(id)sender
{
  [delegate showTerminal];
}

- (void)keyDown:(NSEvent *)theEvent 
{	
  [super keyDown: theEvent];
}

- (void)setDelegate:(id)adelegate
{
  delegate = adelegate;
  [super setDelegate: adelegate];
}

- (BOOL)validateMenuItem:(id <NSMenuItem>)menuItem
{	
  return [delegate validateItem: menuItem];
}

- (void)print:(id)sender
{
  [super print: sender];
}

- (void)orderWindow:(NSWindowOrderingMode)place 
         relativeTo:(NSInteger)otherWin
{
  [super orderWindow: place relativeTo: otherWin];
  [self setLevel: NSDesktopWindowLevel];
}

- (BOOL)canBecomeKeyWindow
{
  return YES;
}

- (BOOL)canBecomeMainWindow
{
  return YES;
}

@end
