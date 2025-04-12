/* DDBMDStorage.h
 *  
 * Copyright (C) 2005 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: July 2005
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

#ifndef DDB_MD_STORAGE_H
#define DDB_MD_STORAGE_H

#include <Foundation/Foundation.h>
   
@interface DDBMDStorage: NSObject 
{
  NSString *basePath;

  unsigned depth;
  unsigned levcount;

  NSString *countpath;  
  int *pnum;
  NSString *formstr; 
  
  NSString *freepath;
  NSMutableArray *freeEntries;
  
  NSFileManager *fm;
}

- (id)initWithPath:(NSString *)apath
        levelCount:(unsigned)lcount
         dirsDepth:(unsigned)ddepth;

- (NSString *)nextEntry;

- (void)removeEntry:(NSString *)entry;

- (void)removePath:(NSString *)path;

- (NSString *)basePath;

@end

#endif // DDB_MD_STORAGE_H
