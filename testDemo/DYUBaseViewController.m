//
//  DYUBaseViewController.m
//  DYVideoTools
//
//  Created by qiyun on 16/8/25.
//  Copyright © 2016年 qiyun. All rights reserved.
//

#import "DYUBaseViewController.h"

@interface DYUBaseViewController ()

@end

@implementation DYUBaseViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


+ (UIImage *)screenShorture{
    
    // create graphics context with screen size
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UIGraphicsBeginImageContext(screenRect.size);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    [[UIColor blackColor] set];
    CGContextFillRect(ctx, screenRect);
    // grab reference to our window
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    // transfer content into our context
    [window.layer renderInContext:ctx];
    UIImage *screengrab = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return screengrab;
}

- (void)uploadVideoOfFilePath:(NSString *)filePath videoParams:(NSDictionary *)params completedHandler:(void (^) (int result, NSString *resMessage, id data))complete{

}

- (void)editingVideoWithUrl:(NSURL *)url videoSize:(CGSize)size completedHanlder:(void (^) (int result, NSString *outPath))complete{
    

}


/* 七牛上传 */
/*
- (void)qn_uploadData:(NSData *)data
                  key:(NSString *)key
                token:(NSString *)token
     completedHanlder:(void(^)(QNResponseInfo *info, NSDictionary *resp))completed{
    
    QNUploadManager *uploadManager = [[QNUploadManager alloc] init];
    [uploadManager putPHAsset:nil key:key token:token complete:^(QNResponseInfo *info, NSString *key, NSDictionary *resp) {
        
        completed(info,resp);
        
    } option:nil];
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end


#import <objc/runtime.h>

YNSYNTH_DUMMY_CLASS(YNActionWithEventBlockTarget)

static const int block_key;

@interface YNActionWithEventBlockTarget : NSObject

@property (nonatomic,copy) void (^block) (id sender);

- (id)initWithBlock:(void (^)(id sender))block;

- (void)invoke:(id)sender;

@end

@implementation YNActionWithEventBlockTarget

- (id)initWithBlock:(void (^)(id sender))block{
    self = [super init];
    if (self) {
        _block = [block copy];
    }
    return self;
}

- (void)invoke:(id)sender {
    
    if (_block) _block(sender);
}

@end

@implementation IDYButton


- (instancetype)initWithFrame:(CGRect)frame buttonWithType:(UIButtonType)type{
    
    self = [super initWithFrame:frame];
    
    if (self) {
        
        self = [IDYButton buttonWithType:type];
        self.frame = frame;
        self.cornerRadius = YES;
    }
    return self;
}


- (void)setCornerRadius:(BOOL)cornerRadius{
    
    _cornerRadius = cornerRadius;
    
    if (cornerRadius){
        
        self.layer.cornerRadius = CGRectGetWidth(self.frame)/2;
        self.clipsToBounds = YES;
    }else{
        
        self.layer.cornerRadius = .0f;
        self.clipsToBounds = NO;
    }
}

- (void)setGraduallyHidden:(BOOL)graduallyHidden{
    
    _graduallyHidden = graduallyHidden;
    
    [UIView animateWithDuration:0.25 animations:^{
        
        self.layer.opacity = !_graduallyHidden;
        
    } completion:^(BOOL finished) {
        
        self.hidden = _graduallyHidden;
    }];
}

- (void)setNormalImageNamed:(NSString *)normalImageNamed{
    
    _normalImageNamed = normalImageNamed;
    [self setImage:DYImageNamed(_normalImageNamed) forState:UIControlStateNormal];
}

- (void)setHighLightImageNamed:(NSString *)highLightImageNamed{
    
    _highLightImageNamed = highLightImageNamed;
    [self setImage:DYImageNamed(highLightImageNamed) forState:UIControlStateNormal];
}

- (void)setDisableImageNamed:(NSString *)disableImageNamed{
    
    _disableImageNamed = disableImageNamed;
    [self setImage:DYImageNamed(disableImageNamed) forState:UIControlStateDisabled];
}


- (void)setTitleString:(NSString *)titleString{
    
    _titleString = titleString;
    if (_titleString) {
        
        [self setTitle:_titleString forState:UIControlStateNormal];
        if (self.normalImageNamed) {
            
            UIImage *image = [UIImage imageWithImage:DYImageNamed(self.normalImageNamed) scaledToSize:CGSizeMake(40, 40)];
            NSLog(@"image size = %@",NSStringFromCGSize(image.size));
            
            self.titleEdgeInsets = UIEdgeInsetsMake(image.size.height + 10, - image.size.width * 2 - 20, 0, 0);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -5, 10, 15);
            self.titleLabel.font = [UIFont systemFontOfSize:12];
            self.cornerRadius = NO;
            [self.titleLabel sizeToFit];
        }
    }
}

- (void (^)(id sender)) actionBlock {
    
    YNActionWithEventBlockTarget *target = objc_getAssociatedObject(self, &block_key);
    
    return target.block;
}


- (void)setActionBlock:(void (^)(id))actionBlock{
    
    self.userInteractionEnabled = YES;
    
    YNActionWithEventBlockTarget *target = [[YNActionWithEventBlockTarget alloc] initWithBlock:actionBlock];
    
    objc_setAssociatedObject(self, &block_key, target, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [self addTarget:target action:@selector(invoke:) forControlEvents:UIControlEventTouchUpInside];
}


@end


#pragma mark    -   UIView  category

@implementation UIView (IDYView)

- (CGFloat)left{
    
    return self.frame.origin.x;
}

- (void)setLeft:(CGFloat)left{
    
    CGRect frame = self.frame;
    frame.origin.x = left;
    self.frame = frame;
}

- (CGFloat)right{
    
    return self.frame.origin.x + self.frame.size.width;
}

- (void)setRight:(CGFloat)right{
    
    CGRect frame = self.frame;
    frame.origin.x = right - frame.size.width;
    self.frame = frame;
}

- (CGFloat)top{
    
    return self.frame.origin.y;
}

- (void)setTop:(CGFloat)top{
    
    CGRect frame = self.frame;
    frame.origin.y = top;
    self.frame = frame;
}

- (CGFloat)bottom{
    
    return self.frame.origin.y + self.frame.size.height;
}

- (void)setBottom:(CGFloat)bottom{
    
    CGRect frame = self.frame;
    frame.origin.y = bottom -frame.size.height;
    self.frame = frame;
}


- (CGFloat)width{
    
    return self.frame.size.width;
}

- (void)setWidth:(CGFloat)width{
    
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

- (CGFloat)height{
    
    return self.frame.size.height;
}

- (void)setHeight:(CGFloat)height{
    
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}


@end
