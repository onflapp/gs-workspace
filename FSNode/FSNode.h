/* FSNode.h
 *  
 * Copyright (C) 2004 Free Software Foundation, Inc.
 *
 * Author: Enrico Sersale <enrico@imago.ro>
 * Date: March 2004
 *
 * This file is part of the GNUstep FSNode framework
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

#ifndef FSNODE_H
#define FSNODE_H

#include <Foundation/Foundation.h>

@class NSImage;
@class NSBezierPath;

@interface FSNode : NSObject 
{
  FSNode *parent;
  NSString *path;
  NSString *relativePath;
  NSString *name;
  NSDictionary *attributes;
  NSString *fileType;
  NSString *typeDescription;
  
  NSString *pathSeparator;  
  
  unsigned long long filesize;
  NSDate *crDate;
  NSString *crDateDescription;
  NSDate *modDate;
  NSString *modDateDescription;
  unsigned long permissions;
  NSString *owner;
  NSNumber *ownerId;
  NSString *group;
  NSNumber *groupId;
  
  struct nodeFlags {
    unsigned readable;
    unsigned writable;
    unsigned executable;
    unsigned deletable;
    unsigned plain;
    unsigned directory;
    unsigned link;
    unsigned socket;
    unsigned charspecial;
    unsigned blockspecial;
    unsigned mountpoint;
    unsigned application;
    unsigned package;
    unsigned unknown;
  } flags;

  NSNotificationCenter *nc;
  NSFileManager *fm;
  id ws;
}

+ (FSNode *)nodeWithRelativePath:(NSString *)rpath
                          parent:(FSNode *)aparent;

- (id)initWithRelativePath:(NSString *)rpath
                    parent:(FSNode *)aparent;

- (BOOL)isEqualToNode:(FSNode *)anode;

- (NSArray *)subNodes;

+ (NSArray *)nodeComponentsToNode:(FSNode *)anode;

+ (NSArray *)pathComponentsToNode:(FSNode *)anode;

+ (NSArray *)nodeComponentsFromNode:(FSNode *)firstNode 
                             toNode:(FSNode *)secondNode;

+ (NSArray *)pathComponentsFromNode:(FSNode *)firstNode 
                             toNode:(FSNode *)secondNode;

+ (unsigned int)indexOfNode:(FSNode *)anode 
               inComponents:(NSArray *)nodes;

+ (unsigned int)indexOfNodeWithPath:(NSString *)apath 
                       inComponents:(NSArray *)nodes;

+ (FSNode *)subnodeWithName:(NSString *)aname 
                 inSubnodes:(NSArray *)subnodes;

+ (FSNode *)subnodeWithPath:(NSString *)apath 
                 inSubnodes:(NSArray *)subnodes;

- (FSNode *)parent;

- (NSString *)parentPath;

- (BOOL)isSubnodeOfNode:(FSNode *)anode;

- (BOOL)isSubnodeOfPath:(NSString *)apath;

- (BOOL)isParentOfNode:(FSNode *)anode;

- (BOOL)isParentOfPath:(NSString *)apath;

- (NSString *)path;

- (NSString *)relativePath;

- (NSString *)name;

- (NSString *)fileType;

- (void)setTypeFlags;

- (void)setFlagsForSymLink:(NSDictionary *)attrs;

- (NSString *)typeDescription;

- (NSDate *)creationDate;

- (NSString *)crDateDescription;

- (NSDate *)modificationDate;

- (NSString *)modDateDescription;

- (unsigned long long)fileSize;

- (NSString *)sizeDescription;

- (NSString *)owner;

- (NSNumber *)ownerId;

- (NSString *)group;

- (NSNumber *)groupId;

- (unsigned long)permissions;

- (BOOL)isPlain;

- (BOOL)isDirectory;

- (BOOL)isLink;

- (BOOL)isSocket;

- (BOOL)isCharspecial;

- (BOOL)isBlockspecial;

- (BOOL)isMountPoint;

- (void)setMountPoint:(BOOL)value;

- (BOOL)isApplication;

- (BOOL)isPackage;

- (BOOL)isReadable;

- (BOOL)isWritable;

- (BOOL)isExecutable;

- (BOOL)isDeletable;

- (BOOL)isLocked;

- (BOOL)isValid;

- (BOOL)willBeValidAfterFileOperation:(NSDictionary *)opinfo;

- (BOOL)involvedByFileOperation:(NSDictionary *)opinfo;

@end


@interface FSNode (Comparing)

- (int)compareAccordingToName:(FSNode *)aNode;

- (int)compareAccordingToParent:(FSNode *)aNode;

- (int)compareAccordingToKind:(FSNode *)aNode;

- (int)compareAccordingToDate:(FSNode *)aNode;

- (int)compareAccordingToSize:(FSNode *)aNode;

- (int)compareAccordingToOwner:(FSNode *)aNode;

- (int)compareAccordingToGroup:(FSNode *)aNode;

@end

#endif // FSNODE_H








