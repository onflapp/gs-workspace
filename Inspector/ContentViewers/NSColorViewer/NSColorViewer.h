/* NSColorViewer.h
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

#ifndef NSCOLORVIEWER_H
#define NSCOLORVIEWER_H

#include <Foundation/Foundation.h>
#include <AppKit/NSView.h>
#include "ContentViewersProtocol.h"

@class NSImage;
@class NSTextField;
@class ColorsView;

@protocol ContentInspectorProtocol

- (void)dataContentsReadyForType:(NSString *)typeDescr
                         useIcon:(NSImage *)icon;

@end 

@interface NSColorViewer : NSView <ContentViewersProtocol>
{
	BOOL valid;
  NSString *typeDescriprion;
  NSImage *icon;
  
  ColorsView *colorsView;
  NSTextField *redField;
  NSTextField *greenField;
  NSTextField *blueField;
  NSTextField *alphaField;
  NSTextField *errLabel;
    
  id <ContentInspectorProtocol>inspector;
}

- (void)setContextHelp;

@end


@interface ColorsView : NSView 
{
  float hue;
  float saturation;
  float brightness;
  BOOL isColor;
}

- (void)setHue:(float)h saturation:(float)s brightness:(float)b;

@end

#endif // NSCOLORVIEWER_H
