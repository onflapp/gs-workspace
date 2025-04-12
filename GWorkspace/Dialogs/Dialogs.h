/* Dialogs.h
 *  
 * Copyright (C) 2003-2025 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: August 2001
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
 * Foundation, Inc., 31 Milk Street #960789 Boston, MA 02196 USA.
 */


#ifndef DIALOGS_H
#define DIALOGS_H

#include <AppKit/NSWindow.h>
#include <AppKit/NSView.h>

@class NSString;
@class NSTextField;
@class NSButton;

@interface GWDialogView : NSView
{
  BOOL useSwitch;
}

- (id)initWithFrame:(NSRect)frameRect useSwitch:(BOOL)aBool;

@end

@interface GWDialog : NSWindow
{
  GWDialogView *dialogView;
  NSTextField *titleField, *editField;
  NSButton *switchButt;
  NSButton *cancelButt, *okButt;
  BOOL useSwitch;
  NSModalResponse result;
}

- (id)initWithTitle:(NSString *)title 
           editText:(NSString *)eText
        switchTitle:(NSString *)swTitle;

- (NSModalResponse)runModal;

- (NSString *)getEditFieldText;

- (NSControlStateValue)switchButtonState;

- (void)buttonAction:(id)sender;

@end

#endif // DIALOGS_H
