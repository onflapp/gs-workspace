#import "GWorkspace.h"
#import "FileViewer/GWViewer.h"

@implementation GWorkspace (scripting)

- (NSArray*) viewers
{
  NSMutableSet* ls = [NSMutableSet setWithCapacity:1];

  for (NSWindow* win in [[self viewersManager] viewerWindows]) 
  {
    id del = [win delegate];
    if ([del isKindOfClass: [GWViewer class]]) 
    {
      [ls addObject:del];
    }
  }
  return [ls allObjects];
}

- (id) currentViewer 
{
  id del = [[NSApp keyWindow] delegate];
  if ([del isKindOfClass: [GWViewer class]])
    return del;
  else
    return nil;
}

- (void) inspectFile:(NSString*) path 
{
  if (!path)
    return;

  [inspector activate];
  [inspector setCurrentSelection: [NSArray arrayWithObject:path]];
}

- (void) deleteSelectedFiles 
{
  [self deleteFiles];
}

- (void) moveSelectedFilesToTrash 
{
  [self moveToTrash];
}

- (void) duplicateSelectedFiles 
{
  [self duplicateFiles];
}

- (NSArray*) selectedFiles 
{
  return [self selectedPaths];
}

@end
