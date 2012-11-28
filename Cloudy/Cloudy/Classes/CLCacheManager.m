//
//  CLCacheManager.m
//  Cloudy
//
//  Created by Parag Dulam on 24/10/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import "CLCacheManager.h"

@implementation CLCacheManager


#pragma mark - Get Folder Paths


+(NSString *) getAppCacheFolderPath
{
    return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getDocumentsDirectory],CACHE_FOLDER_NAME];
}


+(NSString *) getDropboxCacheFolderPath
{
    return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],DROPBOX_STRING];
}


+(NSString *) getUploadsFolderPath
{
    return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],UPLOAD_STRING];
}


+(NSString *) getSkyDriveCacheFolderPath
{
    return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],SKYDRIVE_STRING];
}


+(NSString *) getFileStructurePath:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getDropboxCacheFolderPath],FILE_STRUCTURE_PLIST];
            break;
        case SKYDRIVE:
            return [NSString stringWithFormat:@"%@/%@",[CLCacheManager getSkyDriveCacheFolderPath],FILE_STRUCTURE_PLIST];
            break;
        default:
            break;
    }
    return nil;
}



+(NSString *) getLibraryDirectory
{
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}


+(NSString *) getTemporaryDirectory
{
    return NSTemporaryDirectory();
}


+(NSString *) getDocumentsDirectory
{
    NSArray *dirPaths;
    NSString *docsDir;
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                   NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}


#pragma mark - Helper Methods


+(void) deleteAllContentsOfFolderAtPath:(NSString *) path
{
    NSArray *contents = [CLCacheManager contentsOfDirectoryAtPath:path];
    for (NSString *fileName in contents) {
        [CLCacheManager deleteFileAtPath:[path stringByAppendingPathComponent:fileName]];
    }
}

+(NSString *) pathFiedForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return @"path";
            break;
        case SKYDRIVE:
            return @"id";
            break;
            
        default:
            break;
    }
return nil;
}

+(BOOL) deleteFileAtPath:(NSString *) path
{
    return [[NSFileManager defaultManager] removeItemAtPath:path
                                                      error:nil];
}

+(BOOL) fileExistsAtPath:(NSString *) path
{
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+(NSArray *) contentsOfDirectoryAtPath:(NSString *) path
{
    return [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path
                                                               error:nil];
}

+(NSMutableArray *) removeEmptyStringsForArray:(NSMutableArray *) array
{
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    for (NSString *string in array) {
        if ([string length]) {
            [retVal addObject:string];
        }
    }
    return [retVal autorelease];
}


#pragma mark - Accounts


+(NSArray *) accounts
{
    NSDictionary *accountsDictionary = [NSDictionary dictionaryWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],ACCOUNTS_PLIST]];
    return [accountsDictionary objectForKey:ACCOUNTS];
}



+(BOOL) updateAccount:(NSDictionary *) account
{
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[CLCacheManager accounts]];
    int index;
//    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSDictionary *objDict = (NSDictionary *)obj;
//        if ([[objDict objectForKey:ACCOUNT_TYPE] integerValue] == [[account objectForKey:ACCOUNT_TYPE] integerValue]) {
//            index = idx;
//        }
//    }];
    for (NSDictionary *anAccount in accounts) {
        if ([[anAccount objectForKey:ACCOUNT_TYPE] integerValue] == [[account objectForKey:ACCOUNT_TYPE] integerValue]) {
            index = [accounts indexOfObject:anAccount];
            break;
        }
    }

    [accounts replaceObjectAtIndex:index withObject:account];

    NSDictionary *accountsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:accounts,ACCOUNTS, nil];
    return [accountsDictionary writeToFile:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],ACCOUNTS_PLIST] atomically:YES];
}


+(BOOL) storeAccount:(NSDictionary *) account
{
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[CLCacheManager accounts]];
    BOOL retVal = YES;
//    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
//        NSDictionary *objDict = (NSDictionary *)obj;
//        if ([[objDict objectForKey:ACCOUNT_TYPE] integerValue] == [[account objectForKey:ACCOUNT_TYPE] integerValue]) {
//            retVal = NO;
//        }
//    }];
    for (NSDictionary *anAccount in accounts) {
        if ([[anAccount objectForKey:ACCOUNT_TYPE] integerValue] == [[account objectForKey:ACCOUNT_TYPE] integerValue]) {
            retVal = NO;
            break;
        }
    }
    if (!retVal) {
        return retVal;
    } else {
        [accounts addObject:account];
    }
    NSDictionary *accountsDictionary = [NSDictionary dictionaryWithObjectsAndKeys:accounts,ACCOUNTS, nil];
    return [accountsDictionary writeToFile:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],ACCOUNTS_PLIST] atomically:YES];
}


+(BOOL) deleteAccount:(NSDictionary *) account
{
    NSMutableArray *accounts = [NSMutableArray arrayWithArray:[CLCacheManager accounts]];
    [accounts removeObject:account];
    NSDictionary *accountsDictionary = [[[NSDictionary alloc] initWithObjectsAndKeys:accounts,ACCOUNTS, nil] autorelease];
    if (![accounts count])
    {
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],ACCOUNTS_PLIST]
                                                   error:nil];
        return NO;
    }
    return [accountsDictionary writeToFile:[NSString stringWithFormat:@"%@/%@",[CLCacheManager getAppCacheFolderPath],ACCOUNTS_PLIST] atomically:YES];
}


+(NSDictionary *) getAccountForType:(VIEW_TYPE) type
{
    __block NSDictionary *retVal = nil;
    NSArray *accounts = [CLCacheManager accounts];
    [accounts enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSDictionary *objDict = (NSDictionary *)obj;
        if ([[objDict objectForKey:ACCOUNT_TYPE] integerValue] == type) {
            retVal = [objDict retain];
        }
    }];
    return retVal ? [retVal autorelease] : retVal;
}

+(NSString *) getSkyDriveAccountId
{
    NSDictionary *skyDriveAccount = [CLCacheManager getAccountForType:SKYDRIVE];
    return [skyDriveAccount objectForKey:@"id"];
}

#pragma mark - Initial Setup


+(void) initialSetup
{
    NSError *error = nil;
    NSString *dropBoxFolderCachePath = [CLCacheManager getDropboxCacheFolderPath];
    BOOL aBool = YES;
    BOOL isDropboxFolderAlreadyPresent = [[NSFileManager defaultManager] fileExistsAtPath:dropBoxFolderCachePath isDirectory:&aBool];
    if (!isDropboxFolderAlreadyPresent) {
        [[NSFileManager defaultManager] createDirectoryAtPath:dropBoxFolderCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    if (error) {
        NSLog(@"error creating Dropbox Folder %@",error);
    }
    
    NSString *skyDriveFolderCachePath = [CLCacheManager getSkyDriveCacheFolderPath];
    BOOL anBool = YES;
    BOOL isSkyDriveFolderAlreadyPresent = [[NSFileManager defaultManager] fileExistsAtPath:skyDriveFolderCachePath isDirectory:&anBool];
    
    if (!isSkyDriveFolderAlreadyPresent) {
        [[NSFileManager defaultManager] createDirectoryAtPath:skyDriveFolderCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
        
    }
    if (error) {
        NSLog(@"error creating SkyDrive Folder %@",error);
    }
    
    NSString *uploadsFolderCachePath = [CLCacheManager getUploadsFolderPath];
    aBool = YES;
    BOOL isUploadsFolderAlreadyPresent = [[NSFileManager defaultManager] fileExistsAtPath:uploadsFolderCachePath isDirectory:&aBool];
    if (!isUploadsFolderAlreadyPresent) {
        [[NSFileManager defaultManager] createDirectoryAtPath:uploadsFolderCachePath
                                  withIntermediateDirectories:YES
                                                   attributes:nil
                                                        error:&error];
    }
    if (error) {
        NSLog(@"error creating Uploads Folder %@",error);
    }

    
}



#pragma mark - File Structure Operations (Needs Refactoring)


+(NSDictionary *) readFileStructureForViewType:(VIEW_TYPE) type
{
    return [NSDictionary dictionaryWithContentsOfFile:[CLCacheManager getFileStructurePath:type]];
}


+(BOOL) writeFileStructure:(NSDictionary *) dictionary
               ForViewType:(VIEW_TYPE) type
{
    return [dictionary writeToFile:[CLCacheManager getFileStructurePath:type]
                        atomically:YES];
}



+(NSMutableDictionary *) makeFileStructureMutableForViewType:(VIEW_TYPE) type
{
    NSMutableDictionary *mutableFileStructure = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)[CLCacheManager readFileStructureForViewType:type], kCFPropertyListMutableContainers);
    NSMutableDictionary *retVal = nil;
    if (mutableFileStructure) {
        retVal = [NSMutableDictionary dictionaryWithDictionary:mutableFileStructure];
        CFRelease(mutableFileStructure);
    }
    return retVal;

}


+(BOOL) isString:(NSString *) aString subStringOf:(NSString *)bString
{
    NSRange range =     [bString rangeOfString:aString
                                       options:NSCaseInsensitiveSearch];
    return range.length > 0;
}


+(NSString *) fileIdForSkyDriveFile:(NSDictionary *) file
{
    NSString *idString = [file objectForKey:@"id"];
    if (![idString length]) {
        NSArray *contents = [CLCacheManager filesWihinFolder:[NSMutableDictionary dictionaryWithDictionary:file]
                                                 ForViewType:SKYDRIVE];
        if ([contents count]) {
            NSDictionary *content = [contents objectAtIndex:0];
            idString = [content objectForKey:@"parent_id"];
        }
    }
    return idString;
}

+(int)     doesArray:(NSArray *) array
ContainsFileWithPath:(NSString *) filePath
         ForViewType:(VIEW_TYPE) type //Iterative Method for Loop
{
    int retVal = -1;
    switch (type) {
        case DROPBOX:
            for (NSDictionary *data in array) {
                if ([[data objectForKey:@"path"] isEqualToString:filePath]) {
                    retVal = [array indexOfObject:data];
                    break;
                }
            }
            break;
        case SKYDRIVE:
        {
            for (NSDictionary *data in array) {
//                NSString *folderId = [CLCacheManager fileIdForSkyDriveFile:data];
                NSString *folderId = [data objectForKey:@"id"];
                if ([folderId isEqualToString:filePath]) {
                    retVal = [array indexOfObject:data];
                    break;
                }
            }
        }
            break;
        default:
            break;
    }
    return retVal;
}


+(BOOL) isFolder:(NSDictionary *)folder
    parentOfFile:(NSDictionary *) file
     ForViewType:(VIEW_TYPE) type
{
    BOOL retVal = NO;
    switch (type) {
        case DROPBOX:
        {
            NSString *path = [CLCacheManager pathOfFile:file
                                            ForViewType:type];

            NSString *folderPath = [folder objectForKey:@"path"];
            NSMutableArray *components = [NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]];
            [components removeObjectAtIndex:0];
            [components removeLastObject];
            NSMutableString *verifierString = [[NSMutableString alloc] init];
            int count = [components count];
            if (!count) { //root path
                [verifierString appendFormat:@"/"];
            } else {
                for (NSString *component in components) {
                    [verifierString appendFormat:@"/%@",component];
                }
            }
            NSLog(@"verifierString %@ folderPath %@",verifierString,folderPath);
            retVal = [verifierString isEqualToString:folderPath];
            [verifierString release];
        }
            break;
        case SKYDRIVE:
        {
            NSString *folderId = [CLCacheManager fileIdForSkyDriveFile:folder];
            retVal = [folderId isEqualToString:[file objectForKey:@"parent_id"]];
        }
            break;
        default:
            break;
    }
    return retVal;
}

+(int) doesArray:(NSArray *) array
     ContainsFile:(NSDictionary *) file
      ForViewType:(VIEW_TYPE) type
{
    NSString *path = [CLCacheManager pathOfFile:file
                                    ForViewType:type];
    return [CLCacheManager doesArray:array
                ContainsFileWithPath:path
                         ForViewType:type];
}

+(NSMutableArray *) filesWihinFolder:(NSMutableDictionary *) folder
                         ForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return [folder objectForKey:@"contents"];
            break;
        case SKYDRIVE:
            return [folder objectForKey:@"data"];
            break;
        default:
            return nil;
            break;
    }
}

+(NSString *) pathOfFile:(NSDictionary *) file ForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return [file objectForKey:@"path"];
            break;
        case SKYDRIVE:
            return [CLCacheManager fileIdForSkyDriveFile:file];
            break;
        default:
            break;
    }
}


+(BOOL) isRootPath:(NSString *) filePath WithinViewType:(VIEW_TYPE) type
{
    BOOL retVal = NO;
    switch (type) {
        case DROPBOX:
        {
            retVal = [filePath isEqualToString:ROOT_DROPBOX_PATH];
        }
            break;
        case SKYDRIVE:
        {
            retVal = [filePath isEqualToString:ROOT_SKYDRIVE_PATH] ||
                     [filePath isEqualToString:ROOT_SKYDRIVE_FOLDER_ID];
        }
            break;
        default:
            break;
    }
    return retVal;
}

+(BOOL) isRootPathForFile:(NSDictionary *) file WithinViewType:(VIEW_TYPE) type
{
    NSString *path = [CLCacheManager pathOfFile:file
                                    ForViewType:type];
    return [CLCacheManager isRootPath:path
                       WithinViewType:type];
}


+(NSDictionary *) fileAtIndex:(int) index
                  WithinArray:(NSArray *) array
                  ForViewType:(VIEW_TYPE) type
{
    NSDictionary *retVal = nil;
    switch (type) {
        case DROPBOX:
            retVal = [array objectAtIndex:index];
            break;
        case SKYDRIVE:
            retVal = [array objectAtIndex:index];
            break;
        default:
            break;
    }
    return retVal;
}




+(NSDictionary *) metaDataForPath:(NSString *)path
           whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
              WithinFileStructure:(NSMutableDictionary *)fileStructure
                          ForView:(VIEW_TYPE)type
{
    if (!traversingDictionary) {
        traversingDictionary = fileStructure;
    }
    if ([CLCacheManager isRootPath:path
                    WithinViewType:type]) {
        return traversingDictionary;
    }
    NSMutableArray *contents = [CLCacheManager filesWihinFolder:traversingDictionary ForViewType:type];
    int index =     [CLCacheManager doesArray:contents
                         ContainsFileWithPath:path
                                  ForViewType:type]; //Iterative Method For loop
    if (index > -1) {
        return [CLCacheManager fileAtIndex:index
                               WithinArray:contents
                               ForViewType:type];
    } else {
        for (NSMutableDictionary *data in contents) {
            traversingDictionary = data;
            if ([CLCacheManager filesWihinFolder:traversingDictionary
                                     ForViewType:type]) {
                NSDictionary *result = [CLCacheManager metaDataForPath:path
                                                whereTraversingPointer:traversingDictionary
                                                   WithinFileStructure:fileStructure
                                                               ForView:type];
                if (result) {
                    return result;
                }
            }
        }
    }
    return nil;
}




+(BOOL)     deleteFile:(NSDictionary *) file
whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
       inFileStructure:(NSMutableDictionary *)fileStructure
           ForViewType:(VIEW_TYPE) type
{
    BOOL retVal = NO;
    if (!traversingDictionary) {
        traversingDictionary = fileStructure;
    }
    NSMutableArray *contents = [CLCacheManager filesWihinFolder:traversingDictionary
                                                    ForViewType:type];
    int index = [CLCacheManager doesArray:contents
                             ContainsFile:file
                              ForViewType:type];
    if (index > -1)
    {
        [contents removeObjectAtIndex:index];
        retVal = [fileStructure writeToFile:[CLCacheManager getFileStructurePath:type]
                                 atomically:YES];
    } else {
        for (NSMutableDictionary *data in contents) {
            traversingDictionary = data;
            if ([[CLCacheManager filesWihinFolder:traversingDictionary
                                      ForViewType:type] count])
            {
                BOOL result = [CLCacheManager deleteFile:file
                                  whereTraversingPointer:traversingDictionary
                                         inFileStructure:fileStructure
                                             ForViewType:type];
                if (result) {
                    return result;
                }
            }
        }
    }
    return retVal;
}


+(NSString *) sortDescriptorKeyForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            return DROPBOX_SORTDESCRIPTOR_KEY;
            break;
        case SKYDRIVE:
            return SKYDRIVE_SORTDESCRIPTOR_KEY;
            break;
        default:
            break;
    }
}


+(void) arrangeFilesAndFolders:(NSMutableArray *)contents
                   ForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
        {
            NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:[CLCacheManager sortDescriptorKeyForViewType:type] ascending:YES];
            [contents sortUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
            [sortDescriptor release];
        }
            break;
            
        case SKYDRIVE:
        {
            [contents sortWithOptions:NSSortConcurrent
                      usingComparator:^NSComparisonResult(id obj1, id obj2) {
                          NSDictionary *objDict1 = (NSDictionary *)obj1;
                          NSDictionary *objDict2 = (NSDictionary *)obj2;
                          NSString *fileType1 = [objDict1 objectForKey:@"type"];
                          NSString *fileType2 = [objDict2 objectForKey:@"type"];
                          if ([fileType1 isEqualToString:fileType2]) {
                              return [[objDict1 objectForKey:@"name"] compare:[objDict2 objectForKey:@"name"]  options:NSCaseInsensitiveSearch];
                          } else if (([fileType1 isEqualToString:@"folder"] || [fileType1 isEqualToString:@"album"]) && ![fileType2 isEqualToString:@"folder"]) {
                              return NSOrderedAscending;
                          } else  {
                              return NSOrderedDescending;
                          }
                      }];
        }
            break;
        default:
            break;
    }
}

+(BOOL)     insertFile:(NSDictionary *) file
whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
       inFileStructure:(NSMutableDictionary *)fileStructure
           ForViewType:(VIEW_TYPE) type
{
    BOOL retVal = NO;
    if (!traversingDictionary) {
        traversingDictionary = fileStructure;
    }
    NSMutableArray *contents = [CLCacheManager filesWihinFolder:traversingDictionary
                                                    ForViewType:type];
    if ([CLCacheManager isFolder:traversingDictionary
                    parentOfFile:file
                     ForViewType:type])
    {
        [contents insertObject:file atIndex:0];
        [CLCacheManager arrangeFilesAndFolders:contents
                                   ForViewType:type];
        retVal = [fileStructure writeToFile:[CLCacheManager getFileStructurePath:type]
                                 atomically:YES];
    } else {
        for (NSMutableDictionary *data in contents) {
            traversingDictionary = data;
            if ([[CLCacheManager filesWihinFolder:traversingDictionary
                                     ForViewType:type] count])
            {
                BOOL result = [CLCacheManager insertFile:file
                                  whereTraversingPointer:traversingDictionary
                                         inFileStructure:fileStructure
                                             ForViewType:type];
                if (result) {
                    return result;
                }
            }
        }
    }
    return retVal;
}

+(void) updateFile:(NSDictionary *) file
      WithInArray:(NSMutableArray *) array
           AtIndex:(int) index
       ForViewType:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
            [array replaceObjectAtIndex:index withObject:file];
            break;
        case SKYDRIVE:
        {
            NSMutableDictionary *fileMetadata = [array objectAtIndex:index];
            
            BOOL success = [CLCacheManager updateOldFile:fileMetadata
                                             withNewFile:file
                                             forViewType:type];
            if (!success) {
                NSArray *updatedArray = [file objectForKey:@"data"];
                if ([updatedArray count]) {
                    [fileMetadata setObject:updatedArray forKey:@"data"];
                } else {
                    [array replaceObjectAtIndex:index withObject:file];
                }
            }
        }
            break;
        default:
            break;
    }
}

+(BOOL) updateOldFile:(NSMutableDictionary *)oldFile withNewFile:(NSDictionary *) newFile forViewType:(VIEW_TYPE) type
{
    NSString *contentKey = nil;
    NSString *idKey = nil;
    NSString *updationKey = nil;

    switch (type) {
        case DROPBOX:
        {
            contentKey = @"contents";
            idKey = @"path";
            updationKey = @"hash";
        }
            break;
        case SKYDRIVE:
        {
            contentKey = @"data";
            idKey = @"id";
            updationKey = @"updated_time";
        }
            break;
        default:
            break;
    }
    
    
    NSMutableArray *anArray = [oldFile objectForKey:contentKey];
    NSMutableArray *updatedArray = [newFile objectForKey:contentKey];

    NSMutableArray *finalArray = [[[NSMutableArray alloc] initWithArray:updatedArray] autorelease];
    if ([anArray count]) {
        for (NSDictionary *updatedData in updatedArray) {
            for (NSDictionary *data in anArray) {
                if ([[updatedData objectForKey:idKey] isEqualToString:[data objectForKey:idKey]]) {
                    if ([[data objectForKey:contentKey] count]) {
                        [finalArray replaceObjectAtIndex:[finalArray indexOfObject:updatedData]
                                           withObject:data];
                    }
                }
            }
        }
        [oldFile setObject:finalArray forKey:contentKey];
        return YES;
    } else {
        return NO;
    }
    
}


+(BOOL)     updateFile:(NSDictionary *) file
whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
       inFileStructure:(NSMutableDictionary *)fileStructure
           ForViewType:(VIEW_TYPE) type
{
    BOOL retVal = NO;
    if (!traversingDictionary) {
        traversingDictionary = fileStructure;
        if ([CLCacheManager isRootPathForFile:file
                                                        WithinViewType:type]) {
            BOOL success = [CLCacheManager updateOldFile:fileStructure
                                             withNewFile:file
                                             forViewType:type];
            if (!success) {
                fileStructure = [NSMutableDictionary dictionaryWithDictionary:file];
            }
            return [fileStructure writeToFile:[CLCacheManager getFileStructurePath:type]
                                     atomically:YES];
        } 
    }
    NSMutableArray *contents = [CLCacheManager filesWihinFolder:traversingDictionary
                                                    ForViewType:type];
    int index = [CLCacheManager doesArray:contents
                             ContainsFile:file
                              ForViewType:type];
    if (index > -1)/* || [CLCacheManager isRootPathForFile:traversingDictionary
                                         WithinViewType:type])*/
    {
        [CLCacheManager updateFile:file
                       WithInArray:contents
                           AtIndex:index
                       ForViewType:type];
        retVal = [fileStructure writeToFile:[CLCacheManager getFileStructurePath:type]
                                 atomically:YES];
        
    } else {
        for (NSMutableDictionary *data in contents) {
            traversingDictionary = data;
            if ([[CLCacheManager filesWihinFolder:traversingDictionary
                                      ForViewType:type] count])
            {
                BOOL result = [CLCacheManager updateFile:file
                                  whereTraversingPointer:traversingDictionary
                                         inFileStructure:fileStructure
                                             ForViewType:type];
                if (result) {
                    return result;
                }
            }
        }
    }
    return retVal;
}



+(BOOL) deleteFileStructureForView:(VIEW_TYPE) type
{
    NSError *error = nil;
    return [[NSFileManager defaultManager] removeItemAtPath:[CLCacheManager getFileStructurePath:type]
                                               error:&error];
}


#pragma mark - File Operations Methods


#pragma mark - Unused Methods

+(NSDictionary *) metaDataDictionaryForPath:(NSString *) path ForView:(VIEW_TYPE) type
{
    switch (type) {
        case DROPBOX:
        {
            path = !path ? @"/" : path;
            NSDictionary *fileStructure = [[[NSDictionary alloc] initWithContentsOfFile:[CLCacheManager getFileStructurePath:DROPBOX]] autorelease];
            NSMutableArray *components = [CLCacheManager removeEmptyStringsForArray:[NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]]];
            NSDictionary *traversingDict = fileStructure;
            for (int j = 0;j < [components count] ;j++) {
                NSString *component = [components objectAtIndex:j];
                NSMutableArray *contents = [traversingDict objectForKey:@"contents"];
                for (int i = 0 ; i < [contents count] ; i++) {
                    traversingDict = [contents objectAtIndex:i];
                    if ([[traversingDict objectForKey:@"filename"] isEqualToString:component]) {
                        if (j == [components count] - 1) {
                            return traversingDict;
                        }
                        break;
                    }
                }
            }
            return traversingDict;
        }
            break;
            
        case SKYDRIVE:
        {
            path = !path ? ROOT_SKYDRIVE_PATH : path;
            NSString *folderId = [[path componentsSeparatedByString:@"/"] objectAtIndex:0];
            NSDictionary *fileStructure = [[[NSDictionary alloc] initWithContentsOfFile:[CLCacheManager getFileStructurePath:SKYDRIVE]] autorelease];
            if ([folderId isEqualToString:@"me"]) {
                return fileStructure;
            }
            __block NSDictionary *retVal = nil;
            [fileStructure enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSArray class]]) {
                    NSArray *objArray = (NSArray *)obj;
                    [objArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                        NSMutableDictionary *objDict = (NSMutableDictionary *)obj;
                        if ([[objDict objectForKey:@"id"] isEqualToString:folderId]) {
                            retVal = [objDict retain];
                        }
                    }];
                }
            }];
            
            return [retVal autorelease];
        }
            break;
            
        default:
            break;
    }
    return nil;
}




+(BOOL) updateFolderStructure:(NSDictionary *) metaDataDict
                      ForView:(VIEW_TYPE) type
{
    __block BOOL retVal = NO;
    switch (type) {
        case DROPBOX:
        {
            NSString *path = [metaDataDict objectForKey:@"path"];
            NSDictionary *fileStructure = [[[NSDictionary alloc] initWithContentsOfFile:[CLCacheManager getFileStructurePath:DROPBOX]] autorelease];
            NSMutableDictionary *mutableFileStructure = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)fileStructure, kCFPropertyListMutableContainers);
            
            NSMutableDictionary *traversingDict = mutableFileStructure;
            NSMutableArray *components = [CLCacheManager removeEmptyStringsForArray:[NSMutableArray arrayWithArray:[path componentsSeparatedByString:@"/"]]];
            
            for (int j = 0;j < [components count] ;j++) {
                NSString *component = [components objectAtIndex:j];
                NSMutableArray *contents = [traversingDict objectForKey:@"contents"];
                for (int i = 0 ; i < [contents count] ; i++) {
                    traversingDict = [contents objectAtIndex:i];
                    if ([[traversingDict objectForKey:@"filename"] isEqualToString:component]) {
                        if (j == [components count] - 1) {
                            [contents replaceObjectAtIndex:i
                                                withObject:metaDataDict];
                        }
                        break;
                    }
                }
            }
            NSString *filePath = [CLCacheManager getFileStructurePath:type];
            if (!traversingDict || [path isEqualToString:@"/"]) {
                mutableFileStructure = [NSMutableDictionary dictionaryWithDictionary:metaDataDict];
            }
            retVal = [mutableFileStructure writeToFile:filePath atomically:YES];
        }
            break;
            
        case SKYDRIVE:
        {
            NSDictionary *resultDictionary = [metaDataDict objectForKey:@"RESULT_DATA"];
            NSDictionary *fileStructure = [[NSDictionary alloc] initWithContentsOfFile:[CLCacheManager getFileStructurePath:SKYDRIVE]];
            NSMutableDictionary *mutableFileStructure = CFPropertyListCreateDeepCopy(kCFAllocatorDefault, (CFDictionaryRef)fileStructure, kCFPropertyListMutableContainers);
            NSString *filePath = [CLCacheManager getFileStructurePath:type];
            
            if (!mutableFileStructure || [[metaDataDict objectForKey:PATH] isEqualToString:ROOT_SKYDRIVE_PATH]) {
                return [resultDictionary writeToFile:filePath atomically:YES];
            }
            
            NSMutableDictionary *traversingDict = mutableFileStructure;
            NSArray *dataArray = [resultDictionary objectForKey:@"data"];
            if ([dataArray count]) {
                NSDictionary *data = [dataArray objectAtIndex:0];
                [traversingDict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    if ([obj isKindOfClass:[NSMutableArray class]]) {
                        NSMutableArray *objArray = (NSMutableArray *)obj;
                        [objArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                            NSMutableDictionary *objDict = (NSMutableDictionary *)obj;
                            if ([[objDict objectForKey:@"id"] isEqualToString:[data objectForKey:@"parent_id"]]) {
                                [objDict setObject:dataArray forKey:@"data"];
                                retVal = [traversingDict writeToFile:filePath atomically:YES];
                            }
                        }];
                    }
                }];
            } else {
                return NO;
            }
        }
            break;
        default:
            break;
    }
    return retVal;
}



@end
