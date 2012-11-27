//
//  CLCacheManager.h
//  Cloudy
//
//  Created by Parag Dulam on 24/10/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLConstants.h"

@interface CLCacheManager : NSObject


+(BOOL) storeAccount:(NSDictionary *) account;
+(NSArray *) accounts;
+(BOOL) deleteAccount:(NSDictionary *) account;
+(NSString *) getDocumentsDirectory;
+(void) initialSetup;
+(NSString *) getLibraryDirectory;
+(NSString *) getUploadsFolderPath;
+(NSString *) getFileStructurePath:(VIEW_TYPE) type;
+(NSDictionary *) metaDataDictionaryForPath:(NSString *) path ForView:(VIEW_TYPE) type;
+(BOOL) updateFolderStructure:(NSDictionary *) metaDataDict ForView:(VIEW_TYPE) type;
+(BOOL) deleteFileStructureForView:(VIEW_TYPE) type;
+(NSString *) getTemporaryDirectory;
+(NSDictionary *) getAccountForType:(VIEW_TYPE) type;
+(BOOL) updateAccount:(NSDictionary *) account;

+(NSDictionary *) metaDataForPath:(NSString *)path
           whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
              WithinFileStructure:(NSMutableDictionary *)fileStructure
                          ForView:(VIEW_TYPE)type;
+(NSMutableDictionary *) makeFileStructureMutableForViewType:(VIEW_TYPE) type;
+(NSString *) getSkyDriveAccountId;

+(BOOL) deleteFile:(NSDictionary *) file whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
   inFileStructure:(NSMutableDictionary *)fileStructure
       ForViewType:(VIEW_TYPE) type;

+(BOOL) isString:(NSString *) aString subStringOf:(NSString *)bString;

+(BOOL)     insertFile:(NSDictionary *) file
whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
       inFileStructure:(NSMutableDictionary *)fileStructure
           ForViewType:(VIEW_TYPE) type;

+(BOOL)     updateFile:(NSDictionary *) file
whereTraversingPointer:(NSMutableDictionary *)traversingDictionary
       inFileStructure:(NSMutableDictionary *)fileStructure
           ForViewType:(VIEW_TYPE) type;
+(NSString *) fileIdForSkyDriveFile:(NSDictionary *) file;
+(void) updateFile:(NSDictionary *) file
       WithInArray:(NSMutableArray *) array
           AtIndex:(int) index
       ForViewType:(VIEW_TYPE) type;
+(NSDictionary *) fileAtIndex:(int) index
                  WithinArray:(NSArray *) array
                  ForViewType:(VIEW_TYPE) type;
+(NSArray *) contentsOfDirectoryAtPath:(NSString *) path;
+(BOOL) fileExistsAtPath:(NSString *) path;
+(BOOL) deleteFileAtPath:(NSString *) path;
+(NSString *) getDropboxCacheFolderPath;
+(NSString *) getSkyDriveCacheFolderPath;
+(NSString *) pathFiedForViewType:(VIEW_TYPE) type;
+(void) arrangeFilesAndFolders:(NSMutableArray *)contents
                   ForViewType:(VIEW_TYPE) type;


@end
