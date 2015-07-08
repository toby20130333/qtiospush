#include "dduiiosimage.h"
#include <QtGui/QAccessibleActionInterface>
#include <QGuiApplication>
#include <QQuickWindow>

#import <UIKit/UIKit.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface IOSPhotoDelegate : NSObject <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
                                  IOSImageObject *m_iosPhoto;
NSString *imagePath;
UIButton *changeImg;
NSMutableArray *photosThumbnailLibrairy;
UICollectionView *photosCollection;

}
@end

@implementation IOSPhotoDelegate
- (id) initWithPhotoDelegate:(IOSImageObject *)iosCamera
{
    self = [super init];
    if (self) {
        m_iosPhoto = iosCamera;
    }
    return self;
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    //获取Documents文件夹目录
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentPath = [path objectAtIndex:0];
    //指定新建文件夹路径
    NSString *imageDocPath = [documentPath stringByAppendingPathComponent:@"ImageFile"];
    //创建ImageFile文件夹
    //    NSString* imagePath;
    [[NSFileManager defaultManager] createDirectoryAtPath:imageDocPath withIntermediateDirectories:YES attributes:nil error:nil];
    //保存图片的路径
    imagePath = [imageDocPath stringByAppendingPathComponent:@"image.png"];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    //根据图片路径载入图片
    UIImage *image=[UIImage imageWithContentsOfFile:imagePath];
    if (image == nil) {
        //显示默认
        [changeImg setBackgroundImage:[UIImage imageNamed:@"user_photo@2x.png"] forState:UIControlStateNormal];
    }else {
        //显示保存过的
        [changeImg setBackgroundImage:image forState:UIControlStateNormal];
    }
}

- (void)dealloc {
    [imagePath release];
    [changeImg release];
    [super dealloc];
}
//- (IBAction)changeImage:(id)sender {
//    UIActionSheet *myActionSheet = [[UIActionSheet alloc]
//                                    initWithTitle:nil
//                                    delegate:IOSPhotoDelegate
//                                    cancelButtonTitle:@"取消"
//                                    destructiveButtonTitle:nil
//                                    otherButtonTitles: @"从相册选择", @"拍照",nil];
//    [myActionSheet showInView:self.view];
//    [myActionSheet release];
//}
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    switch (buttonIndex) {
    case 0:
        //从相册选择
        [self LocalPhoto];
        break;
    case 1:
        //拍照
        [self takePhoto];
        break;
    default:
        break;
    }
}
//从相册选择
-(void)LocalPhoto{
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    //资源类型为图片库
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentModalViewController:picker animated:YES];
    [picker release];
}

- (ALAssetsLibrary *) defaultAssetLibrairy {
    static ALAssetsLibrary *assetLibrairy;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        assetLibrairy = [[ALAssetsLibrary alloc] init];
    });
    return (assetLibrairy);
}
-(void)addPhoto{

    // Create the path where we want to save the image:
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        path = [path stringByAppendingString:@"/capture.png"];
    ALAssetsLibrary *library = [self defaultAssetLibrairy];
    [library enumerateGroupsWithTypes:ALAssetsGroupSavedPhotos usingBlock:^(ALAssetsGroup *group,
                                                                            BOOL *stop) {
        [group setAssetsFilter:[ALAssetsFilter allPhotos]];
        [group enumerateAssetsWithOptions:NSEnumerationReverse usingBlock:^(ALAsset *alAsset,
                                                                            NSUInteger index, BOOL *innerStop) {
            if (alAsset) {
                UIImage *currentThumbnail = [UIImage imageWithCGImage:[alAsset thumbnail]];
                [photosThumbnailLibrairy addObject:currentThumbnail];
                [photosCollection reloadData];
                // Save image:
                [UIImagePNGRepresentation(currentThumbnail) writeToFile:path options:NSAtomicWrite error:nil];

                    // Update imagePath property to trigger QML code:
                    m_iosPhoto->m_imagePath = QStringLiteral("file:") + QString::fromNSString(path);
                    emit m_iosPhoto->imagePathChanged();
            }
        }];
    } failureBlock: ^(NSError *error) {
        m_iosPhoto->m_imagePath = "";
        NSLog(@"No groups");
        emit m_iosPhoto->imagePathChanged();
    }];

}
//拍照
-(void)takePhoto{
    //资源类型为照相机
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    //判断是否有相机
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera]){
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        //资源类型为照相机
        picker.sourceType = sourceType;
        [self presentModalViewController:picker animated:YES];
        [picker release];
    }else {
        NSLog(@"该设备无摄像头");
    }
}
#pragma Delegate method UIImagePickerControllerDelegate
//图像选取器的委托方法，选完图片后回调该方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingImage:(UIImage *)image editingInfo:(NSDictionary *)editingInfo{

    //当图片不为空时显示图片并保存图片
    if (image != nil) {
        //图片显示在界面上
        [changeImg setBackgroundImage:image forState:UIControlStateNormal];

        //以下是保存文件到沙盒路径下
        //把图片转成NSData类型的数据来保存文件
        NSData *data;
        //判断图片是不是png格式的文件
        if (UIImagePNGRepresentation(image)) {
            //返回为png图像。
            data = UIImagePNGRepresentation(image);
        }else {
            //返回为JPEG图像。
            data = UIImageJPEGRepresentation(image, 1.0);
        }
        //保存
        [[NSFileManager defaultManager] createFileAtPath:imagePath contents:data attributes:nil];

    }
    //关闭相册界面
    [picker dismissModalViewControllerAnimated:YES];
}
@end
IOSPhotoDelegate* delegatePhoto;

IOSImageObject::IOSImageObject(QQuickItem *parent) :
    QQuickItem(parent), m_delegate([[IOSPhotoDelegate alloc] initWithPhotoDelegate:this])
{
}

void IOSImageObject::open()
{
    // Get the UIView that backs our QQuickWindow:
    UIView *view = reinterpret_cast<UIView *>(window()->winId());
    UIViewController *qtController = [[view window] rootViewController];

    // Create a new image picker controller to show on top of Qt's view controller:
//    UIImagePickerController *imageController = [[[UIImagePickerController alloc] init] autorelease];
//    [imageController setSourceType:UIImagePickerControllerSourceTypeCamera];
//    [imageController setDelegate:id(m_delegate)];

    // Tell the imagecontroller to animate on top:
//    [qtController presentViewController:imageController animated:YES completion:nil];
   IOSPhotoDelegate* delegatePhoto = (IOSPhotoDelegate*)m_delegate;//[[IOSPhotoDelegate alloc] initWithPhotoDelegate:this];
   [delegatePhoto addPhoto];
}
