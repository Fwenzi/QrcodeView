//
//  QrcodeView.m
//  QrcodeView
//
//  Created by Fangjw on 2017/12/13.
//  Copyright © 2017年 Fangjw. All rights reserved.
//

#import "QrcodeView.h"
#import <AVFoundation/AVFoundation.h>
#import <Masonry/Masonry.h>
#import "UILabel+Masonry.h"

#define HEIGHTOFSCREEN [[UIScreen mainScreen] bounds].size.height
#define WIDTHOFSCREEN [[UIScreen mainScreen] bounds].size.width
#define WIDTHRADIUS (WIDTHOFSCREEN/375.0)

#define TOPDIS  (WIDTHOFSCREEN-235*WIDTHRADIUS)/2
#define LEFTDIS (HEIGHTOFSCREEN-235*WIDTHRADIUS)/2

#define CENTERRECT CGRectMake(TOPDIS, LEFTDIS, 235*WIDTHRADIUS, 235*WIDTHRADIUS)

@interface QrcodeView()<AVCaptureMetadataOutputObjectsDelegate>{
    NSTimer *timer;
    CGFloat moveDis;
    BOOL ifDown;
}

@property (strong,nonatomic)AVCaptureDevice * device;
@property (strong,nonatomic)AVCaptureDeviceInput * input;
@property (strong,nonatomic)AVCaptureMetadataOutput * output;
@property (strong,nonatomic)AVCaptureSession * session;
@property (strong,nonatomic)AVCaptureVideoPreviewLayer * preview;

@property (nonatomic, strong) UIImageView *line;
@property (nonatomic, strong) UIImageView *scanImgV;
@property (nonatomic, strong) UILabel *topLabel;

@property (nonatomic, strong) UIImage *scanImg;
@property (nonatomic, strong) UIImage *lineImg;

@end

@implementation QrcodeView

#pragma mark ❀_❀ LifeCycle

- (instancetype)initWithFrame:(CGRect)frame scanImg:(UIImage *)scanImg lineImg:(UIImage *)lineImg {
    self = [super initWithFrame:frame];
    if (self) {
        self.frame=frame;
        self.backgroundColor=[UIColor whiteColor];
        self.scanImg=scanImg;
        self.lineImg=lineImg;
        [self createBackView];
        // cgrect时用这个，不然画的网格被覆盖了
//        [self setupCamera];
        [self performSelector:@selector(setupCamera) withObject:nil afterDelay:0.2];
    }
    return self;
}

#pragma mark @_@ AVCaptureMetadataOutputObjectsDelegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    NSString *stringValue;
    
    if ([metadataObjects count] >0)
    {
        //停止扫描
        [_session stopRunning];
        [timer setFireDate:[NSDate distantFuture]];
        
        AVMetadataMachineReadableCodeObject * metadataObject = [metadataObjects objectAtIndex:0];
        stringValue = metadataObject.stringValue;
        NSLog(@"扫描结果：%@",stringValue);
        
        NSArray *arry = metadataObject.corners;
        for (id temp in arry) {
            NSLog(@"%@",temp);
        }
        if (_qrcodeViewDelegate && [_qrcodeViewDelegate respondsToSelector:@selector(QrcodeViewBackStr:ifSuccess:)]) {
            [_qrcodeViewDelegate QrcodeViewBackStr:stringValue ifSuccess:YES];
        }
        
    } else {
        if (_qrcodeViewDelegate && [_qrcodeViewDelegate respondsToSelector:@selector(QrcodeViewBackStr:ifSuccess:)]) {
            [_qrcodeViewDelegate QrcodeViewBackStr:@"无扫描信息" ifSuccess:NO];
        }
        return;
    }
}

#pragma mark ➶_➴ Event Response

- (void)lineAnim {
    if (ifDown) {
        moveDis++;
        _line.frame=CGRectMake(TOPDIS, LEFTDIS+moveDis, 235*WIDTHRADIUS, 1);
        if (moveDis>235*WIDTHRADIUS) {
            ifDown=!ifDown;
        }
    }else{
        moveDis--;
        _line.frame=CGRectMake(TOPDIS, LEFTDIS+moveDis, 235*WIDTHRADIUS, 1);
        if (moveDis<=0) {
            ifDown=!ifDown;
        }
    }
}

- (void)backBtnClick {
    if (self.backBlock) {
        self.backBlock();
    }
}

#pragma mark ◎_◎ Private Method

- (void)createBackView {
    CAShapeLayer *layer=[[CAShapeLayer alloc]init];
    CGMutablePathRef path=CGPathCreateMutable();
    CGPathAddRect(path, nil, CENTERRECT);
    CGPathAddRect(path, nil, CGRectMake(0, 0, WIDTHOFSCREEN, HEIGHTOFSCREEN));
    
    [layer setFillRule:kCAFillRuleEvenOdd];
    [layer setPath:path];
    [layer setFillColor:[UIColor blackColor].CGColor];
    [layer setOpacity:0.6];
    
    [layer setNeedsDisplay];
    [self.layer addSublayer:layer];
    
    self.scanImgV=[[UIImageView alloc]initWithImage:self.scanImg];
    self.scanImgV.frame=CENTERRECT;
    [self addSubview:self.scanImgV];
    
    _line=[[UIImageView alloc]initWithImage:self.lineImg];
    _line.frame=CGRectMake(TOPDIS, LEFTDIS, 235*WIDTHRADIUS, 1);
    [self addSubview:_line];
    
    ifDown=YES;
    moveDis=0;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:.01 target:self selector:@selector(lineAnim) userInfo:nil repeats:YES];
}

- (void)setupCamera {
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (device==nil) {
        if (_qrcodeViewDelegate && [_qrcodeViewDelegate respondsToSelector:@selector(QrcodeViewBackStr:ifSuccess:)]) {
            [_qrcodeViewDelegate QrcodeViewBackStr:@"设备没有摄像头" ifSuccess:NO];
        }
        return;
    }
    // Device
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    
    // Input
    _input = [AVCaptureDeviceInput deviceInputWithDevice:self.device error:nil];
    
    // Output
    _output = [[AVCaptureMetadataOutput alloc]init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    
    //设置扫描区域
    ///x 与 y 互换  width 与 height 互换
    [_output setRectOfInterest:CGRectMake(CENTERRECT.origin.y/HEIGHTOFSCREEN, CENTERRECT.origin.x/WIDTHOFSCREEN, CENTERRECT.size.height/HEIGHTOFSCREEN, CENTERRECT.size.width/WIDTHOFSCREEN)];
    
    // Session
    _session = [[AVCaptureSession alloc]init];
    [_session setSessionPreset:AVCaptureSessionPresetHigh];
    if ([_session canAddInput:self.input])
    {
        [_session addInput:self.input];
    }
    
    if ([_session canAddOutput:self.output])
    {
        [_session addOutput:self.output];
    }
    
    // 条码类型 AVMetadataObjectTypeQRCode
    [_output setMetadataObjectTypes:[NSArray arrayWithObjects:AVMetadataObjectTypeQRCode, nil]];
    
    // Preview
    _preview =[AVCaptureVideoPreviewLayer layerWithSession:_session];
    _preview.videoGravity = AVLayerVideoGravityResizeAspectFill;
    _preview.frame =self.layer.bounds;
    [self.layer insertSublayer:_preview atIndex:0];
    
    // Start
    [_session startRunning];
}

#pragma mark $_$ Public Method

- (void)createTopView:(NSString *)TopStr backImg:(UIImage *)backImg {
    UIView *backview=[UIView new];
    backview.backgroundColor=[UIColor blackColor];
    [self addSubview:backview];
    
    self.topLabel=[UILabel labelWithFont:[UIFont systemFontOfSize:18 weight:UIFontWeightMedium] textClolr:[UIColor whiteColor] superView:self];
    self.topLabel.text=TopStr;
    self.topLabel.textAlignment=NSTextAlignmentCenter;
    [self addSubview:self.topLabel];
    
    UIButton *backBtn=[UIButton new];
    [backBtn setImage:backImg forState:UIControlStateNormal];
    [backBtn setImage:backImg forState:UIControlStateHighlighted];
    [backBtn addTarget:self action:@selector(backBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:backBtn];
    
    [backview mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@64);
    }];
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(backview.mas_bottom);
        make.left.right.equalTo(self);
        make.height.equalTo(@44);
    }];
    [backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(backview.mas_bottom);
        make.left.equalTo(backview).offset(10);
        make.height.width.equalTo(@44);
    }];
}

- (void)reStartRunning {
    if (_session != nil && timer != nil) {
        [_session startRunning];
        [timer setFireDate:[NSDate date]];
    }
}

- (void)createGridView {
    CGFloat widthView = CENTERRECT.size.width;
    CGFloat heightView = CENTERRECT.size.height;
    CGFloat size = 3;
/********************1--多个CAShapeLayer********************/
//    UIBezierPath *pathLine = [UIBezierPath bezierPath];
//    void (^addLineWidthRect)(CGPoint rect,CGPoint rects) = ^(CGPoint rect,CGPoint rects) {
//        [pathLine moveToPoint:rect];
//        [pathLine addLineToPoint:rects];
//    };
//    for (int i=0; i<widthView; i+=size) {
//        addLineWidthRect(CGPointMake(i, 0),CGPointMake(i, heightView));
//    }
//    for (int i=0; i<heightView; i+=size) {
//        addLineWidthRect(CGPointMake(0, i),CGPointMake(widthView, i));
//    }
//    CAShapeLayer *layerLine= [CAShapeLayer layer];
//    layerLine.path=pathLine.CGPath;
//    layerLine.lineWidth=0.5;
//    layerLine.lineCap=kCALineCapRound;
//    layerLine.strokeColor=[UIColor blueColor].CGColor;
//    [self.scanImgV.layer addSublayer:layerLine];
 
///********************2--一个CAShapeLayer********************/
    void (^addLineWidthRect)(CGPoint rect,CGPoint rects) = ^(CGPoint rect,CGPoint rects) {
        UIBezierPath *pathLine = [UIBezierPath bezierPath];
        [pathLine moveToPoint:rect];
        [pathLine addLineToPoint:rects];

        CAShapeLayer *layerLine= [CAShapeLayer layer];
        layerLine.path=pathLine.CGPath;
        layerLine.lineWidth=0.5;
        layerLine.lineCap=kCALineCapRound;
        layerLine.strokeColor=[UIColor blueColor].CGColor;
        [self.scanImgV.layer addSublayer:layerLine];
    };

    for (int i=0; i<widthView; i+=size) {
        addLineWidthRect(CGPointMake(i, 0),CGPointMake(i, heightView));
    }
    for (int i=0; i<heightView; i+=size) {
        addLineWidthRect(CGPointMake(0, i),CGPointMake(widthView, i));
    }

/********************3-多个CALayer********************/
//        void (^addLineWidthRect)(CGRect rect) = ^(CGRect rect) {
//            CALayer *layer = [[CALayer alloc] init];
//            [self.scanImgV.layer addSublayer:layer];
//            layer.frame = rect;
//            layer.backgroundColor = [[[UIColor whiteColor]colorWithAlphaComponent:0.5] CGColor];
//        };
//        for (int i=0; i<widthView; i+=size) {
//            addLineWidthRect(CGRectMake(i, 0, 0.5, heightView));
//        }
//        for (int i=0; i<heightView; i+=size) {
//            addLineWidthRect(CGRectMake(0, i, widthView, 0.5));
//        }
}

// 4-drawRect
//- (void)drawRect:(CGRect)rect {
//    CGFloat widthView = CENTERRECT.size.width;
//    CGFloat heightView = CENTERRECT.size.height;
//    CGFloat size = 3;
//
//    CGContextRef context =UIGraphicsGetCurrentContext();
//    CGContextSetStrokeColorWithColor(context, [UIColor blueColor].CGColor);
//    CGContextSetFillColorWithColor(context,[UIColor blueColor].CGColor);
//
//    for (int i=0; i<widthView; i+=size) {
//        CGContextMoveToPoint(context,i+CENTERRECT.origin.x,+CENTERRECT.origin.y);
//        CGContextAddLineToPoint(context,i+CENTERRECT.origin.x,heightView+CENTERRECT.origin.y);
//    }
//    for (int i=0; i<heightView; i+=size) {
//        CGContextMoveToPoint(context,0+CENTERRECT.origin.x,i+CENTERRECT.origin.y);
//        CGContextAddLineToPoint(context,widthView+CENTERRECT.origin.x,i+CENTERRECT.origin.y);
//    }
//    CGContextSetLineWidth(context,1.0);
//    CGContextStrokePath(context);
//    CGContextFillPath(context);
////    CGContextRestoreGState(context);
//}

#pragma mark ⚆_⚆ Get/Set

@end
