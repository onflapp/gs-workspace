/* FolderViewer.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: January 2004
 *
 * This file is part of the GNUstep Inspector application
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

#ifndef FOLDERVIEWER_H
#define FOLDERVIEWER_H

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>
#include "ContentViewersProtocol.h"

@class NSMatrix;
@class NSBox;
@class NSTextField;
@class NSButton;

@protocol ContentInspectorProtocol

- (void)contentsReadyAt:(NSString *)path;

@end 

@interface FolderViewer : NSView <ContentViewersProtocol>
{
  NSString *currentPath;
  BOOL valid;	
	int sortType;
  
	NSBox *sortBox;
	NSMatrix *matrix;
  NSButton *okButt;
  
  id <ContentInspectorProtocol>inspector;
  NSFileManager *fm;
  NSWorkspace *ws;  
}

- (int)sortTypeForPath:(NSString *)path;

- (void)setNewSortType:(id)sender;

- (void)setContextHelp;

@end

#endif // FOLDERVIEWER_H
