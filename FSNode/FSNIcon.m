/* FSNIcon.m
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

#include <Foundation/Foundation.h>
#include <AppKit/AppKit.h>
#include <math.h>
#include "FSNIcon.h"
#include "FSNTextCell.h"
#include "FSNode.h"
#include "FSNFunctions.h"
#include "GNUstep.h"

#define BRANCH_SIZE 7
#define ARROW_ORIGIN_X (BRANCH_SIZE + 4)

#define DOUBLE_CLICK_LIMIT  300
#define EDIT_CLICK_LIMIT   1000

static id <DesktopApplication> desktopApp = nil;

static NSImage *branchImage;

@implementation FSNIcon

- (void)dealloc
{
  RELEASE (node);
	TEST_RELEASE (hostname);
  TEST_RELEASE (selection);
  TEST_RELEASE (selectionTitle);
  TEST_RELEASE (extInfoType);
  RELEASE (icon);
  TEST_RELEASE (openicon);
  RELEASE (highlightPath);
  RELEASE (label);
  RELEASE (infolabel);
  [super dealloc];
}

+ (void)initialize
{
  NSBundle *bundle = [NSBundle bundleForClass: [FSNodeRep class]];
  NSString *imagepath = [bundle pathForResource: @"ArrowRight" ofType: @"tiff"];

  if (desktopApp == nil) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appName = [defaults stringForKey: @"DesktopApplicationName"];
    NSString *selName = [defaults stringForKey: @"DesktopApplicationSelName"];

    if (appName && selName) {
		  Class desktopAppClass = [[NSBundle mainBundle] classNamed: appName];
      SEL sel = NSSelectorFromString(selName);
      desktopApp = [desktopAppClass performSelector: sel];
    }
  }
    
  branchImage = [[NSImage alloc] initWithContentsOfFile: imagepath];
}

+ (NSImage *)branchImage
{
  return branchImage;
}

- (id)initForNode:(FSNode *)anode
     nodeInfoType:(FSNInfoType)type
     extendedType:(NSString *)exttype
         iconSize:(int)isize
     iconPosition:(unsigned int)ipos
        labelFont:(NSFont *)lfont
        textColor:(NSColor *)tcolor
        gridIndex:(int)gindex
        dndSource:(BOOL)dndsrc
        acceptDnd:(BOOL)dndaccept
        slideBack:(BOOL)slback
{
  self = [super init];

  if (self) {
    NSFontManager *fmanager = [NSFontManager sharedFontManager];
    NSFont *infoFont;
    NSRect r = NSZeroRect;
    
    fsnodeRep = [FSNodeRep sharedInstance];
    
    iconSize = isize;
    icnBounds = NSMakeRect(0, 0, iconSize, iconSize);
    icnPoint = NSZeroPoint;
    brImgBounds = NSMakeRect(0, 0, BRANCH_SIZE, BRANCH_SIZE);
    
    ASSIGN (node, anode);
    selection = nil;
    selectionTitle = nil;
    
    ASSIGN (icon, [fsnodeRep iconOfSize: iconSize forNode: node]);
    drawicon = icon;
    openicon = nil;
    
    dndSource = dndsrc;
    acceptDnd = dndaccept;
    slideBack = slback;
    
    selectable = YES;
    isLeaf = YES;
    
    hlightRect = NSZeroRect;
    hlightRect.size.width = iconSize / 3 * 4;
    hlightRect.size.height = hlightRect.size.width * [fsnodeRep highlightHeightFactor];
    if ((hlightRect.size.height - iconSize) < 4) {
      hlightRect.size.height = iconSize + 4;
    }
    hlightRect = NSIntegralRect(hlightRect);
    ASSIGN (highlightPath, [fsnodeRep highlightPathOfSize: hlightRect.size]);
        
		if ([[node path] isEqual: path_separator()] && ([node isMountPoint] == NO)) {
		  NSHost *host = [NSHost currentHost];
		  NSString *hname = [host name];
		  NSRange range = [hname rangeOfString: @"."];

		  if (range.length != 0) {	
			  hname = [hname substringToIndex: range.location];
		  } 			
      
		  ASSIGN (hostname, hname);
		} 
    
    label = [FSNTextCell new];
    [label setFont: lfont];
    [label setTextColor: tcolor];

    infoFont = [fmanager convertFont: lfont 
                              toSize: ([lfont pointSize] - 2)];
    infoFont = [fmanager convertFont: infoFont 
                         toHaveTrait: NSItalicFontMask];

    infolabel = [FSNTextCell new];
    [infolabel setFont: infoFont];
    [infolabel setTextColor: tcolor];

    if (exttype) {
      [self setExtendedShowType: exttype];
    } else {
      [self setNodeInfoShowType: type];  
    }
    
    labelRect = NSZeroRect;
    labelRect.size.width = [label uncuttedTitleLenght] + [fsnodeRep labelMargin];
    labelRect.size.height = [[label font] defaultLineHeightForFont];
    labelRect = NSIntegralRect(labelRect);

    infoRect = NSZeroRect;
    if ((showType != FSNInfoNameType) && [[infolabel stringValue] length]) {
      infoRect.size.width = [infolabel uncuttedTitleLenght] + [fsnodeRep labelMargin];
    } else {
      infoRect.size.width = labelRect.size.width;
    }
    infoRect.size.height = [[infolabel font] defaultLineHeightForFont];
    infoRect = NSIntegralRect(infoRect);

    icnPosition = ipos;
    gridIndex = gindex;
    
    if (icnPosition == NSImageLeft) {
      [label setAlignment: NSLeftTextAlignment];
      [infolabel setAlignment: NSLeftTextAlignment];
      
      r.size.width = hlightRect.size.width + labelRect.size.width;    
      r.size.height = hlightRect.size.height;

      if (showType != FSNInfoNameType) {
        float lbsh = labelRect.size.height + infoRect.size.height;

        if (lbsh > hlightRect.size.height) {
          r.size.height = lbsh;
        }
      } 
    
    } else if (icnPosition == NSImageAbove) {
      [label setAlignment: NSCenterTextAlignment];
      [infolabel setAlignment: NSCenterTextAlignment];
      
      if (labelRect.size.width > hlightRect.size.width) {
        r.size.width = labelRect.size.width;
      } else {
        r.size.width = hlightRect.size.width;
      }
      
      r.size.height = labelRect.size.height + hlightRect.size.height;
      
      if (showType != FSNInfoNameType) {
        r.size.height += infoRect.size.height;
      }
      
    } else if (icnPosition == NSImageOnly) {
      r.size.width = hlightRect.size.width;
      r.size.height = hlightRect.size.height;
      
    } else {
      r.size = icnBounds.size;
    }

    [self setFrame: NSIntegralRect(r)];
    
    if (acceptDnd) {
      NSArray *pbTypes = [NSArray arrayWithObjects: NSFilenamesPboardType, 
                                                    @"GWRemoteFilenamesPboardType", 
                                                    nil];
      [self registerForDraggedTypes: pbTypes];    
    }

    isLocked = [node isLocked];

    container = nil;

    isSelected = NO; 
    isOpened = NO;
    nameEdited = NO;
    editstamp = 0.0;
    
    dragdelay = 0;
    isDragTarget = NO;
    onSelf = NO;    
  }
  
  return self;
}

- (void)setSelectable:(BOOL)value
{
  if ((icnPosition == NSImageOnly) && (selectable != value)) {
    selectable = value;
    [self tile];
  }
}

- (void)select
{
  if (isSelected) {
    return;
  }
  isSelected = YES;
  
  if ([container respondsToSelector: @selector(unselectOtherReps:)]) {
    [container unselectOtherReps: self];
  }
  if ([container respondsToSelector: @selector(selectionDidChange)]) {
    [container selectionDidChange];	
  }
  
  [self setNeedsDisplay: YES]; 
}

- (void)unselect
{
  if (isSelected == NO) {
    return;
  }
	isSelected = NO;
  [self setNeedsDisplay: YES];
}

- (BOOL)isSelected
{
  return isSelected;
}

- (NSRect)iconBounds
{
  return icnBounds;
}

- (void)tile
{
  NSRect frameRect = [self frame];
  NSSize sz = [icon size];
  int lblmargin = [fsnodeRep labelMargin];
  BOOL hasinfo = ([[infolabel stringValue] length] > 0);
    
  if (icnPosition == NSImageAbove) {
    float hlx, hly;

    labelRect.size.width = [label uncuttedTitleLenght] + lblmargin;
  
    if (labelRect.size.width >= frameRect.size.width) {
      labelRect.size.width = frameRect.size.width;
      labelRect.origin.x = 0;
    } else {
      labelRect.origin.x = (frameRect.size.width - labelRect.size.width) / 2;
    }

    if (showType != FSNInfoNameType) {
      if (hasinfo) {
        infoRect.size.width = [infolabel uncuttedTitleLenght] + lblmargin;
      } else {
        infoRect.size.width = labelRect.size.width;
      }
      
      if (infoRect.size.width >= frameRect.size.width) {
        infoRect.size.width = frameRect.size.width;
        infoRect.origin.x = 0;
      } else {
        infoRect.origin.x = (frameRect.size.width - infoRect.size.width) / 2;
      }
    }

    if (showType == FSNInfoNameType) {
      labelRect.origin.y = 0;
      labelRect.origin.y += lblmargin / 2;
      labelRect = NSIntegralRect(labelRect);
      infoRect = labelRect;
      
    } else {
      infoRect.origin.y = 0;
      infoRect.origin.y += lblmargin / 2;
      infoRect = NSIntegralRect(infoRect);
    
      labelRect.origin.y = infoRect.origin.y + infoRect.size.height;
      labelRect = NSIntegralRect(labelRect);
    } 
        
    hlx = rintf((frameRect.size.width - hlightRect.size.width) / 2);
    hly = rintf(frameRect.size.height - hlightRect.size.height);

    if ((hlightRect.origin.x != hlx) || (hlightRect.origin.y != hly)) {
      NSAffineTransform *transform = [NSAffineTransform transform];

      [transform translateXBy: hlx - hlightRect.origin.x
                          yBy: hly - hlightRect.origin.y];

      [highlightPath transformUsingAffineTransform: transform];

      hlightRect.origin.x = hlx;
      hlightRect.origin.y = hly;      
    }

    icnBounds.origin.x = hlightRect.origin.x + ((hlightRect.size.width - iconSize) / 2);
    icnBounds.origin.y = hlightRect.origin.y + ((hlightRect.size.height - iconSize) / 2);
    icnBounds = NSIntegralRect(icnBounds);

    icnPoint.x = rintf(hlightRect.origin.x + ((hlightRect.size.width - sz.width) / 2));
    icnPoint.y = rintf(hlightRect.origin.y + ((hlightRect.size.height - sz.height) / 2));

  } else if (icnPosition == NSImageLeft) {
    float icnspacew = hlightRect.size.width;
    float hryorigin = 0;
    
    if (isLeaf == NO) {
      icnspacew += BRANCH_SIZE;
    }
    
    labelRect.size.width = rintf([label uncuttedTitleLenght] + lblmargin);
    
    if (labelRect.size.width >= (frameRect.size.width - icnspacew)) {
      labelRect.size.width = (frameRect.size.width - icnspacew);
    } 
    
    labelRect = NSIntegralRect(labelRect);

    if (showType != FSNInfoNameType) {
      if (hasinfo) {
        infoRect.size.width = [infolabel uncuttedTitleLenght] + lblmargin;
      } else {
        infoRect.size.width = labelRect.size.width;
      }
      
      if (infoRect.size.width >= (frameRect.size.width - icnspacew)) {
        infoRect.size.width = (frameRect.size.width - icnspacew);
      }
       
    } else {
      infoRect.size.width = labelRect.size.width;
    }
    
    infoRect = NSIntegralRect(infoRect);

    if (showType != FSNInfoNameType) {
      float lbsh = labelRect.size.height + infoRect.size.height;

      if (lbsh > hlightRect.size.height) {
        hryorigin = rintf((lbsh - hlightRect.size.height) / 2);
      }
    }

    if ((hlightRect.origin.x != 0) || (hlightRect.origin.y != hryorigin)) {
      NSAffineTransform *transform = [NSAffineTransform transform];

      [transform translateXBy: 0 - hlightRect.origin.x
                          yBy: hryorigin - hlightRect.origin.y];

      [highlightPath transformUsingAffineTransform: transform];

      hlightRect.origin.x = 0;
      hlightRect.origin.y = hryorigin;      
    }

    icnBounds.origin.x = (hlightRect.size.width - iconSize) / 2;
    icnBounds.origin.y = hlightRect.origin.y + ((hlightRect.size.height - iconSize) / 2);
    icnBounds = NSIntegralRect(icnBounds);

    icnPoint.x = rintf((hlightRect.size.width - sz.width) / 2);
    icnPoint.y = rintf(hlightRect.origin.y + ((hlightRect.size.height - sz.height) / 2));

    labelRect.origin.x = hlightRect.size.width;
    infoRect.origin.x = hlightRect.size.width;

    if (showType != FSNInfoNameType) {
      float lbsh = labelRect.size.height + infoRect.size.height;

      infoRect.origin.y = 0;
    
      if (hasinfo) {
        if (hlightRect.size.height > lbsh) {
          infoRect.origin.y = (hlightRect.size.height - lbsh) / 2;
        }

        labelRect.origin.y = infoRect.origin.y + infoRect.size.height;
        
      } else {
        if (hlightRect.size.height > lbsh) {
          labelRect.origin.y = (hlightRect.size.height - labelRect.size.height) / 2;
        } else {
          labelRect.origin.y = (lbsh - labelRect.size.height) / 2;
        }
      }
      
    } else {
      labelRect.origin.y = (hlightRect.size.height - labelRect.size.height) / 2;
    }

    infoRect = NSIntegralRect(infoRect);
    labelRect = NSIntegralRect(labelRect);

  } else if (icnPosition == NSImageOnly) {
    if (selectable) {
      float hlx = rintf((frameRect.size.width - hlightRect.size.width) / 2);
      float hly = rintf((frameRect.size.height - hlightRect.size.height) / 2);
    
      if ((hlightRect.origin.x != hlx) || (hlightRect.origin.y != hly)) {
        NSAffineTransform *transform = [NSAffineTransform transform];
    
        [transform translateXBy: hlx - hlightRect.origin.x
                            yBy: hly - hlightRect.origin.y];
    
        [highlightPath transformUsingAffineTransform: transform];
      
        hlightRect.origin.x = hlx;
        hlightRect.origin.y = hly;      
      }
    }
    
    icnBounds.origin.x = (frameRect.size.width - iconSize) / 2;
    icnBounds.origin.y = (frameRect.size.height - iconSize) / 2;
    icnBounds = NSIntegralRect(icnBounds);

    icnPoint.x = rintf((frameRect.size.width - sz.width) / 2);
    icnPoint.y = rintf((frameRect.size.height - sz.height) / 2);
  } 
    
  brImgBounds.origin.x = frameRect.size.width - ARROW_ORIGIN_X;
  brImgBounds.origin.y = rintf(icnBounds.origin.y + (icnBounds.size.height / 2) - (BRANCH_SIZE / 2));
  brImgBounds = NSIntegralRect(brImgBounds);
  
  [self setNeedsDisplay: YES]; 
}

- (NSMenu *)menuForEvent:(NSEvent *)theEvent
{
  if (([theEvent type] == NSRightMouseDown) && isSelected) {
    return [container menuForEvent: theEvent];
  }
  return [super menuForEvent: theEvent]; 
}

- (void)viewDidMoveToSuperview
{
  [super viewDidMoveToSuperview];
  container = (NSView <FSNodeRepContainer> *)[self superview];
}

- (void)mouseUp:(NSEvent *)theEvent
{
  NSPoint location = [theEvent locationInWindow];
  BOOL onself = NO;

  location = [self convertPoint: location fromView: nil];

  if (icnPosition == NSImageOnly) {
    onself = [self mouse: location inRect: icnBounds];
  } else {
    onself = ([self mouse: location inRect: icnBounds]
                        || [self mouse: location inRect: labelRect]);
  }
     
  if ([container respondsToSelector: @selector(setSelectionMask:)]) {
    [container setSelectionMask: NSSingleSelectionMask];
  }

  if (onself) {
	  if (([node isLocked] == NO) && ([theEvent clickCount] > 1)) {
      if ([container respondsToSelector: @selector(openSelectionInNewViewer:)]) {
        BOOL newv = (([theEvent modifierFlags] & NSControlKeyMask)
                        || ([theEvent modifierFlags] & NSAlternateKeyMask));

        [container openSelectionInNewViewer: newv];
      }
    }  
  } else {
    [container mouseUp: theEvent];
  }
}

- (void)mouseDown:(NSEvent *)theEvent
{
  NSPoint location = [theEvent locationInWindow];
  BOOL onself = NO;
	NSEvent *nextEvent = nil;
  BOOL startdnd = NO;

  location = [self convertPoint: location fromView: nil];

  if (icnPosition == NSImageOnly) {
    onself = [self mouse: location inRect: icnBounds];
  } else {
    onself = ([self mouse: location inRect: icnBounds]
                        || [self mouse: location inRect: labelRect]);
  }

  if (onself) {
    if (selectable == NO) {
      return;
    }
    
	  if ([theEvent clickCount] == 1) {
      if (isSelected == NO) {
        if ([container respondsToSelector: @selector(stopRepNameEditing)]) {
          [container stopRepNameEditing];
        }
      }
      
		  if ([theEvent modifierFlags] & NSShiftKeyMask) {
        if ([container respondsToSelector: @selector(setSelectionMask:)]) {
          [container setSelectionMask: FSNMultipleSelectionMask];
        }
         
			  if (isSelected) {
          if ([container selectionMask] == FSNMultipleSelectionMask) {
				    [self unselect];
            if ([container respondsToSelector: @selector(selectionDidChange)]) {
              [container selectionDidChange];	
            }
				    return;
          }
        } else {
				  [self select];
			  }
        
		  } else {
        if ([container respondsToSelector: @selector(setSelectionMask:)]) {
          [container setSelectionMask: NSSingleSelectionMask];
        }
        
        if (isSelected == NO) {
				  [self select];
          
			  } else {
          NSTimeInterval interval = ([theEvent timestamp] - editstamp);
        
          if ((interval > DOUBLE_CLICK_LIMIT) 
                            && [self mouse: location inRect: labelRect]) {
            if ([container respondsToSelector: @selector(setNameEditorForRep:)]) {
              [container setNameEditorForRep: self];
            }
          } 
        }
		  }
    
      if (dndSource) {
        while (1) {
	        nextEvent = [[self window] nextEventMatchingMask:
    							                  NSLeftMouseUpMask | NSLeftMouseDraggedMask];

          if ([nextEvent type] == NSLeftMouseUp) {
            [[self window] postEvent: nextEvent atStart: NO];
            
            if ([container respondsToSelector: @selector(repSelected:)]) {
              [container repSelected: self];
            }
            
            break;

          } else if ([nextEvent type] == NSLeftMouseDragged) {
	          if (dragdelay < 5) {
              dragdelay++;
            } else {     
              startdnd = YES;        
              break;
            }
          }
        }
      }
      
      if (startdnd == YES) {  
        if ([container respondsToSelector: @selector(stopRepNameEditing)]) {
          [container stopRepNameEditing];
        }
        [self startExternalDragOnEvent: nextEvent];    
      }
      
      editstamp = [theEvent timestamp];       
	  } 
    
  } else {
    [container mouseDown: theEvent];
  }
}

- (BOOL)acceptsFirstMouse:(NSEvent *)theEvent
{
  return YES;
}

- (void)setFrame:(NSRect)frameRect
{
  [super setFrame: frameRect];
  [self tile];
}

- (void)resizeWithOldSuperviewSize:(NSSize)oldBoundsSize
{
  [self tile];
}

- (void)drawRect:(NSRect)rect
{	 
  if (isSelected) {
    [[NSColor selectedControlColor] set];
    [highlightPath fill];
    
    if ((icnPosition != NSImageOnly) && (nameEdited == NO)) {
      NSFrameRect(labelRect);
      NSRectFill(labelRect);  
      [label drawWithFrame: labelRect inView: self];
      
      if ((showType != FSNInfoNameType) && [[infolabel stringValue] length]) {
        [infolabel drawWithFrame: infoRect inView: self];
      }
    }
  } else {
    if ((icnPosition != NSImageOnly) && (nameEdited == NO)) {
      [[container backgroundColor] set];
      NSFrameRect(labelRect);
      NSRectFill(labelRect);
      [label drawWithFrame: labelRect inView: self];
      
      if ((showType != FSNInfoNameType) && [[infolabel stringValue] length]) {
        [infolabel drawWithFrame: infoRect inView: self];
      }
    }  
  }

	if (isLocked == NO) {	
    if (isOpened == NO) {	
      [drawicon compositeToPoint: icnPoint operation: NSCompositeSourceOver];
    } else {
      [drawicon dissolveToPoint: icnPoint fraction: 0.5];
    }
	} else {						
    [drawicon dissolveToPoint: icnPoint fraction: 0.3];
	}
  
  if (isLeaf == NO) {
    [[isa branchImage] compositeToPoint: brImgBounds.origin operation: NSCompositeSourceOver];
  }
}


//
// FSNodeRep protocol
//
- (void)setNode:(FSNode *)anode
{
  DESTROY (selection);
  DESTROY (selectionTitle);
  DESTROY (hostname);
  
  ASSIGN (node, anode);
  ASSIGN (icon, [fsnodeRep iconOfSize: iconSize forNode: node]);
  drawicon = icon;
  DESTROY (openicon);
  
  if ([[node path] isEqual: path_separator()] && ([node isMountPoint] == NO)) {
    NSHost *host = [NSHost currentHost];
    NSString *hname = [host name];
    NSRange range = [hname rangeOfString: @"."];

    if (range.length != 0) {	
      hname = [hname substringToIndex: range.location];
    } 			
      
    ASSIGN (hostname, hname);
  } 
  
  if (extInfoType) {
    [self setExtendedShowType: extInfoType];
  } else {
    [self setNodeInfoShowType: showType];  
  }
  
  [self setLocked: [node isLocked]];
  [self tile];
}

- (void)setNode:(FSNode *)anode
   nodeInfoType:(FSNInfoType)type
   extendedType:(NSString *)exttype
{
  [self setNode: anode];

  if (exttype) {
    [self setExtendedShowType: exttype];
  } else {
    [self setNodeInfoShowType: type];  
  }
}

- (FSNode *)node
{
  return node;
}

- (void)showSelection:(NSArray *)selnodes
{
  int i;
    
  ASSIGN (node, [selnodes objectAtIndex: 0]);
  ASSIGN (selection, selnodes);
  ASSIGN (selectionTitle, ([NSString stringWithFormat: @"%i %@", 
                  [selection count], NSLocalizedString(@"elements", @"")]));
  ASSIGN (icon, [fsnodeRep multipleSelectionIconOfSize: iconSize]);
  drawicon = icon;
  DESTROY (openicon);
  
  [label setStringValue: selectionTitle];
  [infolabel setStringValue: @""];
  
  [self setLocked: NO];
  for (i = 0; i < [selnodes count]; i++) {
    if ([fsnodeRep isNodeLocked: [selnodes objectAtIndex: i]]) {
      [self setLocked: YES];
      break;
    }
  }

  [self tile];
}

- (BOOL)isShowingSelection
{
  return (selection != nil);
}

- (NSArray *)selection
{
  return selection;
}

- (NSArray *)pathsSelection
{
  if (selection) {
    NSMutableArray *selpaths = [NSMutableArray array];
    int i;

    for (i = 0; i < [selection count]; i++) {
      [selpaths addObject: [[selection objectAtIndex: i] path]];
    }

    return [NSArray arrayWithArray: selpaths];
  }
  
  return nil;
}

- (void)setFont:(NSFont *)fontObj
{
  NSFontManager *fmanager = [NSFontManager sharedFontManager];
  int lblmargin = [fsnodeRep labelMargin];
  NSFont *infoFont;

  [label setFont: fontObj];

  infoFont = [fmanager convertFont: fontObj 
                            toSize: ([fontObj pointSize] - 2)];
  infoFont = [fmanager convertFont: infoFont 
                       toHaveTrait: NSItalicFontMask];

  [infolabel setFont: infoFont];

  labelRect.size.width = rintf([label uncuttedTitleLenght] + lblmargin);
  labelRect.size.height = rintf([[label font] defaultLineHeightForFont]);
  labelRect = NSIntegralRect(labelRect);

  infoRect = NSZeroRect;
  if ((showType != FSNInfoNameType) && [[infolabel stringValue] length]) {
    infoRect.size.width = [infolabel uncuttedTitleLenght] + lblmargin;
  } else {
    infoRect.size.width = labelRect.size.width;
  }
  infoRect.size.height = [infoFont defaultLineHeightForFont];
  infoRect = NSIntegralRect(infoRect);

  [self tile];
}

- (NSFont *)labelFont
{
  return [label font];
}

- (void)setLabelTextColor:(NSColor *)acolor
{
  [label setTextColor: acolor];
  [infolabel setTextColor: acolor];
}

- (NSColor *)labelTextColor
{
  return [label textColor];
}

- (void)setIconSize:(int)isize
{
  iconSize = isize;
  icnBounds = NSMakeRect(0, 0, iconSize, iconSize);
  if (selection == nil) {
    ASSIGN (icon, [fsnodeRep iconOfSize: iconSize forNode: node]);
  } else {
    ASSIGN (icon, [fsnodeRep multipleSelectionIconOfSize: iconSize]);
  }
  drawicon = icon;
  DESTROY (openicon);
  hlightRect.size.width = rintf(iconSize / 3 * 4);
  hlightRect.size.height = rintf(hlightRect.size.width * [fsnodeRep highlightHeightFactor]);
  if ((hlightRect.size.height - iconSize) < 4) {
    hlightRect.size.height = iconSize + 4;
  }
  hlightRect.origin.x = 0;
  hlightRect.origin.y = 0;
  ASSIGN (highlightPath, [fsnodeRep highlightPathOfSize: hlightRect.size]); 
  [self tile];
}

- (int)iconSize
{
  return iconSize;
}

- (void)setIconPosition:(unsigned int)ipos
{
  icnPosition = ipos;

  if (icnPosition == NSImageLeft) {
    [label setAlignment: NSLeftTextAlignment];
    [infolabel setAlignment: NSLeftTextAlignment];
  } else if (icnPosition == NSImageAbove) {
    [label setAlignment: NSCenterTextAlignment];
    [infolabel setAlignment: NSCenterTextAlignment];
  } 
  
  [self tile];
}

- (int)iconPosition
{
  return icnPosition;
}

- (NSRect)labelRect
{
  return labelRect;
}

- (void)setNodeInfoShowType:(FSNInfoType)type
{
  showType = type;
  DESTROY (extInfoType);

  if (selection) {
    [label setStringValue: selectionTitle];
    [infolabel setStringValue: @""];
    return;
  }
   
  [label setStringValue: (hostname ? hostname : [node name])];
   
  switch(showType) {
    case FSNInfoNameType:
      [infolabel setStringValue: @""];
      break;
    case FSNInfoKindType:
      [infolabel setStringValue: [node typeDescription]];
      break;
    case FSNInfoDateType:
      [infolabel setStringValue: [node modDateDescription]];
      break;
    case FSNInfoSizeType:
      [infolabel setStringValue: [node sizeDescription]];
      break;
    case FSNInfoOwnerType:
      [infolabel setStringValue: [node owner]];
      break;
    default:
      [infolabel setStringValue: @""];
      break;
  }
}

- (BOOL)setExtendedShowType:(NSString *)type
{
  ASSIGN (extInfoType, type);
  showType = FSNInfoExtendedType;   

  [self setNodeInfoShowType: showType];

  if (selection == nil) {
    NSDictionary *info = [fsnodeRep extendedInfoOfType: type forNode: node];

    if (info) {
      [infolabel setStringValue: [info objectForKey: @"labelstr"]]; 
      return YES;
    }
  }
  
  return NO; 
}

- (FSNInfoType)nodeInfoShowType
{
  return showType;
}

- (NSString *)shownInfo
{
  return [label stringValue];
}

- (void)setNameEdited:(BOOL)value
{
  if (nameEdited != value) {
    nameEdited = value;
    [self setNeedsDisplay: YES];
  }
}

- (void)setLeaf:(BOOL)flag
{
  if (isLeaf != flag) {
    isLeaf = flag;
    [self tile]; 
  }
}

- (BOOL)isLeaf
{
  return isLeaf;
}

- (void)setOpened:(BOOL)value
{
  if (isOpened == value) {
    return;
  }
  isOpened = value;
  [self setNeedsDisplay: YES]; 
}

- (BOOL)isOpened
{
  return isOpened;
}

- (void)setLocked:(BOOL)value
{
	if (isLocked == value) {
		return;
	}
	isLocked = value;
	[label setTextColor: (isLocked ? [container disabledTextColor] 
                                            : [container textColor])];
	[infolabel setTextColor: (isLocked ? [container disabledTextColor] 
                                            : [container textColor])];
                                                
	[self setNeedsDisplay: YES];		
}

- (void)checkLocked
{
  if (selection == nil) {
    [self setLocked: [node isLocked]];
    
  } else {
    int i;
    
    [self setLocked: NO];
    
    for (i = 0; i < [selection count]; i++) {
      if ([[selection objectAtIndex: i] isLocked]) {
        [self setLocked: YES];
        break;
      }
    }
  }
}

- (BOOL)isLocked
{
	return isLocked;
}

- (void)setGridIndex:(int)index
{
  gridIndex = index;
}

- (int)gridIndex
{
  return gridIndex;
}

- (int)compareAccordingToName:(FSNIcon *)aIcon
{
  return [node compareAccordingToName: [aIcon node]];
}

- (int)compareAccordingToKind:(FSNIcon *)aIcon
{
  return [node compareAccordingToKind: [aIcon node]];
}

- (int)compareAccordingToDate:(FSNIcon *)aIcon
{
  return [node compareAccordingToDate: [aIcon node]];
}

- (int)compareAccordingToSize:(FSNIcon *)aIcon
{
  return [node compareAccordingToSize: [aIcon node]];
}

- (int)compareAccordingToOwner:(FSNIcon *)aIcon
{
  return [node compareAccordingToOwner: [aIcon node]];
}

- (int)compareAccordingToGroup:(FSNIcon *)aIcon
{
  return [node compareAccordingToGroup: [aIcon node]];
}

- (int)compareAccordingToIndex:(FSNIcon *)aIcon
{
  return (gridIndex <= [aIcon gridIndex]) ? NSOrderedAscending : NSOrderedDescending;
}

@end


@implementation FSNIcon (DraggingSource)

- (void)startExternalDragOnEvent:(NSEvent *)event
{
  if ([container respondsToSelector: @selector(selectedPaths)]) {
    NSArray *selectedPaths = [container selectedPaths];
    NSPasteboard *pb = [NSPasteboard pasteboardWithName: NSDragPboard];	

    [pb declareTypes: [NSArray arrayWithObject: NSFilenamesPboardType] 
               owner: nil];

    if ([pb setPropertyList: selectedPaths forType: NSFilenamesPboardType]) {
      NSImage *dragIcon;
      NSPoint dragPoint;

      if ([selectedPaths count] == 1) {
        dragIcon = icon;
      } else {
        dragIcon = [fsnodeRep multipleSelectionIconOfSize: iconSize];
      }     

      dragPoint = [event locationInWindow];      
      dragPoint = [self convertPoint: dragPoint fromView: nil];

      [self dragImage: dragIcon
                   at: dragPoint 
               offset: NSZeroSize
                event: event
           pasteboard: pb
               source: self
            slideBack: slideBack];
    }
  }
}

- (unsigned int)draggingSourceOperationMaskForLocal:(BOOL)flag
{
  return NSDragOperationAll;
}

- (void)draggedImage:(NSImage *)anImage 
						 endedAt:(NSPoint)aPoint 
					 deposited:(BOOL)flag
{
	dragdelay = 0;
  onSelf = NO;
  
  if ([container respondsToSelector: @selector(restoreLastSelection)]) {
    [container restoreLastSelection];
  }
  
  if (flag == NO) {
    if ([container respondsToSelector: @selector(removeUndepositedRep:)]) {
      [container removeUndepositedRep: self];
    }
  }
}

@end


@implementation FSNIcon (DraggingDestination)

- (unsigned int)draggingEntered:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb;
  NSDragOperation sourceDragMask;
	NSArray *sourcePaths;
	NSString *fromPath;
  NSString *nodePath;
  NSString *prePath;
	int count;

  isDragTarget = NO;
  onSelf = NO;
	
  if (selection || isLocked || ([node isDirectory] == NO) 
                    || [node isPackage] || ([node isWritable] == NO)) {
    return NSDragOperationNone;
  }
  	
	pb = [sender draggingPasteboard];

  if ([[pb types] containsObject: NSFilenamesPboardType]) {
    sourcePaths = [pb propertyListForType: NSFilenamesPboardType]; 
       
  } else if ([[pb types] containsObject: @"GWRemoteFilenamesPboardType"]) {
    NSData *pbData = [pb dataForType: @"GWRemoteFilenamesPboardType"]; 
    NSDictionary *pbDict = [NSUnarchiver unarchiveObjectWithData: pbData];
    
    sourcePaths = [pbDict objectForKey: @"paths"];
  } else {
    return NSDragOperationNone;
  }
  
	count = [sourcePaths count];
	if (count == 0) {
		return NSDragOperationNone;
  } 
  
  nodePath = [node path];
  
  if (selection) {
    if ([selection isEqual: sourcePaths]) {
      onSelf = YES;
    }  
  } else if (count == 1) {
    if ([nodePath isEqual: [sourcePaths objectAtIndex: 0]]) {
      onSelf = YES;
    }  
  }

  if (onSelf) {
    isDragTarget = YES;
    return NSDragOperationAll;  
  }

	fromPath = [[sourcePaths objectAtIndex: 0] stringByDeletingLastPathComponent];

	if ([nodePath isEqual: fromPath]) {
		return NSDragOperationNone;
  }  

  if ([sourcePaths containsObject: nodePath]) {
    return NSDragOperationNone;
  }

  prePath = [NSString stringWithString: nodePath];

  while (1) {
    if ([sourcePaths containsObject: prePath]) {
      return NSDragOperationNone;
    }
    if ([prePath isEqual: path_separator()]) {
      break;
    }            
    prePath = [prePath stringByDeletingLastPathComponent];
  }

  isDragTarget = YES;

	sourceDragMask = [sender draggingSourceOperationMask];

	if (sourceDragMask == NSDragOperationCopy) {
		return NSDragOperationCopy;
	} else if (sourceDragMask == NSDragOperationLink) {
		return NSDragOperationLink;
	} else {
		return NSDragOperationAll;
	}
    
  return NSDragOperationNone;
}

- (unsigned int)draggingUpdated:(id <NSDraggingInfo>)sender
{
  NSDragOperation sourceDragMask = [sender draggingSourceOperationMask];
  NSPoint p = [self convertPoint: [sender draggingLocation] fromView: nil];

  if ([self mouse: p inRect: icnBounds] == NO) {
    if (drawicon == openicon) {
      drawicon = icon;
      [self setNeedsDisplay: YES];
    }
    return [container draggingUpdated: sender];
    
  } else {
    if ((openicon == nil) && isDragTarget && (onSelf == NO)) {
      ASSIGN (openicon, [fsnodeRep openFolderIconOfSize: iconSize forNode: node]);
    }
  
    if ((drawicon == icon) && isDragTarget && (onSelf == NO)) {
      drawicon = openicon;
      [self setNeedsDisplay: YES];
    }
  }

  if (isDragTarget == NO) {
    return NSDragOperationNone;
  } else if (sourceDragMask == NSDragOperationCopy) {
		return NSDragOperationCopy;
	} else if (sourceDragMask == NSDragOperationLink) {
		return NSDragOperationLink;
	} else {
		return NSDragOperationAll;
	}

	return NSDragOperationNone;
}

- (void)draggingExited:(id <NSDraggingInfo>)sender
{
  isDragTarget = NO;  
  
  if (onSelf == NO) { 
    drawicon = icon;
    [container setNeedsDisplayInRect: [self frame]];   
    [self setNeedsDisplay: YES];   
  }
  
	onSelf = NO;
}

- (BOOL)prepareForDragOperation:(id <NSDraggingInfo>)sender
{
  return isLocked ? NO : isDragTarget;
}

- (BOOL)performDragOperation:(id <NSDraggingInfo>)sender
{
  return isLocked ? NO : isDragTarget;
}

- (void)concludeDragOperation:(id <NSDraggingInfo>)sender
{
	NSPasteboard *pb;
  NSDragOperation sourceDragMask;
	NSArray *sourcePaths;
  NSString *operation, *source;
  NSMutableArray *files;
	NSMutableDictionary *opDict;
	NSString *trashPath;
  int i;

	isDragTarget = NO;  

  if (isLocked) {
    return;
  }

  if (onSelf) {
		[container resizeWithOldSuperviewSize: [container frame].size]; 
    onSelf = NO;		
    return;
  }	

  drawicon = icon;
  [self setNeedsDisplay: YES];

	sourceDragMask = [sender draggingSourceOperationMask];
  pb = [sender draggingPasteboard];
    
  if ([[pb types] containsObject: @"GWRemoteFilenamesPboardType"]) {  
    NSData *pbData = [pb dataForType: @"GWRemoteFilenamesPboardType"]; 

    [desktopApp concludeRemoteFilesDragOperation: pbData
                                     atLocalPath: [node path]];
    return;
  }
    
  sourcePaths = [pb propertyListForType: NSFilenamesPboardType];

  source = [[sourcePaths objectAtIndex: 0] stringByDeletingLastPathComponent];
  
  trashPath = [desktopApp trashPath];

  if ([source isEqual: trashPath]) {
  		operation = @"GWorkspaceRecycleOutOperation";
	} else {	
		if (sourceDragMask == NSDragOperationCopy) {
			operation = NSWorkspaceCopyOperation;
		} else if (sourceDragMask == NSDragOperationLink) {
			operation = NSWorkspaceLinkOperation;
		} else {
			operation = NSWorkspaceMoveOperation;
		}
  }
  
  files = [NSMutableArray arrayWithCapacity: 1];    
  for(i = 0; i < [sourcePaths count]; i++) {    
    [files addObject: [[sourcePaths objectAtIndex: i] lastPathComponent]];
  }  

	opDict = [NSMutableDictionary dictionaryWithCapacity: 4];
	[opDict setObject: operation forKey: @"operation"];
	[opDict setObject: source forKey: @"source"];
	[opDict setObject: [node path] forKey: @"destination"];
	[opDict setObject: files forKey: @"files"];

  [desktopApp performFileOperation: opDict];
}

@end


@implementation FSNIconNameEditor

- (void)dealloc
{
  TEST_RELEASE (node);
  [super dealloc];
}

- (void)setNode:(FSNode *)anode 
    stringValue:(NSString *)str
          index:(int)idx
{
  DESTROY (node);
  if (anode) {
    ASSIGN (node, anode);
  } 
  [self setStringValue: str];
  index = idx;
}

- (FSNode *)node
{
  return node;
}

- (int)index
{
  return index;
}

- (void)mouseDown:(NSEvent*)theEvent
{
  if ([self isEditable]) {
	  [self setAlignment: NSLeftTextAlignment];
    [[self window] makeFirstResponder: self];
  }
  [super mouseDown: theEvent];
}

@end

