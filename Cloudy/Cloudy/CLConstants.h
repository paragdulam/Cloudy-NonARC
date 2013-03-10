//
//  CLConstants.h
//  Cloudy
//
//  Created by Parag Dulam on 07/11/12.
//  Copyright (c) 2012 Parag Dulam. All rights reserved.
//

#ifndef Cloudy_CLConstants_h
#define Cloudy_CLConstants_h


#define DROPBOX_STRING @"Dropbox"
#define SKYDRIVE_STRING @"SkyDrive"
#define GOOGLE_DRIVE_STRING @"Google Drive"
#define BOX_STRING @"Box"
#define UPLOAD_STRING @"Uploads"



#define DROPBOX_APP_KEY @"4mk4cldk8wu2emp"
#define DROPBOX_APP_SECRET_KEY @"0sc12t7lzttseoi"

#define SKYDRIVE_CLIENT_ID @"000000004C0C6832"
#define SCOPE_ARRAY [NSArray arrayWithObjects:@"wl.signin",@"wl.basic",@"wl.skydrive",@"wl.offline_access",@"wl.skydrive_update", nil]

#define BOX_API_KEY @"ux3ux0v2rl17tppcfry7ddnuj57h3bl8"
#define BOX_CREDENTIALS @"BOX_CREDENTIALS"
#define TICKET @"ticket"
#define AUTH_TOKEN @"auth_token"


#define GOOGLE_DRIVE_KEYCHAIN_ITEM_NAME @"Drive-Box"
#define GOOGLE_DRIVE_CLIENT_ID @"1029215508929.apps.googleusercontent.com"
#define GOOGLE_DRIVE_CLIENT_SECRET @"oinsnnJl1zr7TwfBhcsQrL-E"
#define GOOGLE_DRIVE_API_KEY @"AIzaSyCi42dmunvLaXMsIm1Y8ws0KhN0R9W4Txc"


#define ACCOUNTS_PLIST @"Accounts.plist"
#define METADATA_PLIST @"Metadata.plist"

#define OFFSET 40.f

#define ACCOUNTS @"Accounts"
#define ACCOUNT_DATA @"ACCOUNT_DATA"
#define ACCOUNT_TYPE @"ACCOUNT_TYPE"
#define PDF @"pdf"
#define PATH_SEPARATOR @"/"

#define PATH @"PATH"
#define VIEW_TYPE_STRING @"VIEW_TYPE"
#define THUMBNAIL_REQUEST_CLIENT @"THUMBNAIL_REQUEST_CLIENT"
#define FILE_INFO @"FILE_INFO"
#define CACHE_FOLDER_NAME @"APP_CACHE"
#define FILE_STRUCTURE_PLIST @"FILE_STRUCTURE.plist"
#define FILE_STRUCTURE_STRING @"File_Structure"

#define NAVBAR_COLOR [UIColor colorWithRed:75.f/255.f green:144.f/255.f blue:183.f/255.f alpha:1.f]
//#define NAVBAR_COLOR [UIColor blackColor]
#define CELL_BACKGROUND_COLOR [UIColor whiteColor]
#define CELL_TEXTLABEL_COLOR [UIColor blackColor]
#define CELL_DETAILTEXTLABEL_COLOR [UIColor lightGrayColor]

#define TOOLBAR_HEIGHT 44.f


typedef enum CLOUD_PROVIDERS {
    DROPBOX = 0,
    SKYDRIVE,
    BOX
} VIEW_TYPE;




typedef enum FILE_TYPE {
    PDF_FILE,
    PPT_FILE,
    PLAIN_TEXT_FILE,
    AUDIO_FILE,
    VIDEO_FILE,
    IMAGE_FILE
} FILE_TYPE;

typedef enum FILE_FOLDER_OPERATIONS {
    MOVE,
    COPY,
    CREATE,
    DELETE,
    SHARE,
    METADATA,
    DOWNLOAD,
    UPLOAD
} FILE_FOLDER_OPERATION;





#define ROOT_DROPBOX_PATH @"/"
#define ROOT_SKYDRIVE_PATH [NSString stringWithFormat:@"%@/skydrive",[CLCacheManager getSkyDriveAccountId]]
#define ROOT_SKYDRIVE_FOLDER_ID [NSString stringWithFormat:@"folder.%@",[CLCacheManager getSkyDriveAccountId]]
#define ROOT_BOX_PATH @"0"


#define DROPBOX_SORTDESCRIPTOR_KEY @"filename"
#define SKYDRIVE_SORTDESCRIPTOR_KEY @"name"

#define AUTH_SUCCESS_DROPBOX_TAG 100000
#define AUTH_SUCCESS_SKYDRIVE_TAG 100001


#define IMAGE_EXTENTION_ARRAY [NSArray arrayWithObjects:@"tiff",@"tif",@"jpg",@"jpeg",@"gif",@"png",@"bmp",@"bmpf",@"ico",@"cur",@"xbm",nil]


#define THUMBNAIL_DATA @"THUMBNAIL_DATA"


typedef enum DATA_TYPE {
    DATA_ACCOUNT,
    DATA_METADATA,
    DATA_QUOTA,
} TYPE_DATA;


//Account Keys
#define NAME @"NAME"
#define ID @"ID"
#define USERNAME @"USERNAME"
#define EMAIL @"EMAIL"
#define USED @"USED"
#define TOTAL @"TOTAL"


//Metadata Keys
#define FILE_ID @"FILE_ID"
#define FILE_PARENT_ID @"FILE_PARENT_ID"
#define FILE_NAME @"FILE_NAME"
#define FILE_SIZE @"FILE_SIZE"
#define FILE_TYPE @"FILE_TYPE"
#define FILE_LAST_UPDATED_TIME @"FILE_LAST_UPDATED_TIME"
#define FILE_CREATED_TIME @"FILE_CREATED_TIME"
#define FILE_CONTENTS @"FILE_CONTENTS"
#define FILE_HASH @"FILE_HASH"
#define FILE_PATH @"FILE_PATH"
#define FILE_IS_DIRECTORY @"FILE_IS_DIRECTORY"
#define FILE_EXTENSION @"FILE_EXTENSION"
#define FILE_THUMBNAIL @"FILE_THUMBNAIL"
#define FILE_THUMBNAIL_URL @"FILE_THUMBNAIL_URL"


#define INVALID_INDEX -1



#endif
