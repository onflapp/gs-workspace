/* MDModulesProtocol.h
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

#ifndef MD_MODULES_PROTOCOL_H
#define MD_MODULES_PROTOCOL_H

@protocol MDModulesProtocol

- (NSString *)mdtype;

- (BOOL)duplicable;

- (void)saveData:(id)mdata withBasePath:(NSString *)bpath;

- (id)dataWithBasePath:(NSString *)bpath;

@end 

#endif // MD_MODULES_PROTOCOL_H

