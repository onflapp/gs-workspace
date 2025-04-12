/* Resizer.m
h
 *  
 * Copyright (C) 2005-2020 Free Software Foundation, Inc.
 *
 * Authors: Enrico Sersale <enrico@imago.ro>
 *          Riccardo Mottola <rm@gnu.org>
 * Date: May 2016
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

#import "ContentViewersProtocol.h"

@interface ImageResizer : NSObject
{
  id <ImageViewerProtocol> imageViewerProxy;
}

- (void)setProxy:(id <ImageViewerProtocol>)ivp;

- (void)readImageAtPath:(NSString *)path
                setSize:(NSSize)imsize;

@end
