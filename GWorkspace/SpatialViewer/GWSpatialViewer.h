/* GWSpatialViewer.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: June 2004
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
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
 */

#ifndef GW_SPATIAL_VIEWER_H
#define GW_SPATIAL_VIEWER_H

#include <Foundation/Foundation.h>

@class GWViewersManager;
@class GWSVIconsView;
@class GWSVPathsPopUp;
@class FSNode;

@interface GWSpatialViewer : NSObject
{
  IBOutlet id win;
  IBOutlet id topBox;
  IBOutlet id elementsLabel;
  IBOutlet id spaceLabel;
  IBOutlet id popUpBox;
  GWSVPathsPopUp *pathsPopUp;
  IBOutlet id scroll;
  
  GWSVIconsView *iconsView;
  
  int resizeIncrement;

}

- (id)initForNode:(FSNode *)node;

- (void)activate;

- (void)popUpAction:(id)sender;

- (FSNode *)shownNode;

- (void)updateDefaults;

@end

#endif // GW_SPATIAL_VIEWER_H
