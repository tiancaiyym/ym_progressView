//
//  ym_progressView.m
//  ym_progressView
//
//  Created by 熊雯婷 on 2017/8/3.
//  Copyright © 2017年 rionsoft. All rights reserved.
//

#import "ym_progressView.h"
#define ym_waveTopColor [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:1.0f] //前波浪颜色
#define ym_waveBottomColor [UIColor colorWithRed:0/255.0 green:191/255.0 blue:255/255.0 alpha:0.4f] //后波浪颜色
#define ym_wave_xSpeed 4
#define ym_wave_ySpeed 4.0
IB_DESIGNABLE


@interface ym_progressView(){
    CGFloat _wave_amplitude;   //振幅a
    CGFloat _wave_cycle; //振动周期
//    CGFloat _wave_scale;//水波速率
//    CGFloat _wave_move_width;//移动的距离，配合速率设置
    CGFloat _wave_offsetx; //x轴偏移
    CGFloat _wave_h_distance; //两波之间距离
    CADisplayLink *_displayLink;
}
typedef NS_ENUM(NSInteger,progressStyle){
    lineProgressStyle = 1,
    roundProgressStyle,
    waveProgressStyle
};
@property (nonatomic, weak) NSTimer *timer;
@property (nonatomic, assign) CGFloat process;
@property (nonatomic, weak) CALayer *lineProLayer;
@property (nonatomic, weak) CAShapeLayer *roundProLayer;
@property (nonatomic, weak) CATextLayer *textLayer;
@property (nonatomic, weak) CAShapeLayer *topWaveLayer;
@property (nonatomic, weak) CAShapeLayer *bottomWaveLayer;
@property (weak, nonatomic) IBOutlet UIView *waveBgView;
@property (nonatomic, assign) IBInspectable NSInteger style;
@property (nonatomic, strong) IBInspectable UIColor *tintColor;
@property (nonatomic, strong) IBInspectable UIColor *progressBackgroundColor;
@end


@implementation ym_progressView

//// Only override drawRect: if you perform custom drawing.
//// An empty implementation adversely affects performance during animation.
//- (void)drawRect:(CGRect)rect {
//    // Drawing code
//}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        UIView *progressView = [[[NSBundle mainBundle]loadNibNamed:@"ym_progressView" owner:self options:nil]firstObject];
        progressView.frame = self.bounds;
        [self addSubview:progressView];
    }
    return self;
}

- (void)awakeFromNib{
    if (self.style == lineProgressStyle) {
        CALayer *lineLayer = [self creatLayerWithPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) andBounds:CGRectMake(0, 0, self.frame.size.width-10, 4) andBackgroundColor:self.progressBackgroundColor];
        [self.layer addSublayer:lineLayer];

        CALayer *proLayer = [self creatLayerWithPosition:CGPointMake(5, self.frame.size.height/2) andBounds:CGRectMake(0, 0, (self.frame.size.width-10)/100, 4) andBackgroundColor:self.tintColor];
        proLayer.anchorPoint = CGPointMake(0, 0.5);
        proLayer.cornerRadius = 1.0;
        [self.layer addSublayer:proLayer];
        self.lineProLayer = proLayer;
        
        CATextLayer *textLayer = [self creatTextLayerWithStr:[NSString stringWithFormat:@"%.2f%%",self.progress] andPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2-20) andBounds:CGRectMake(0, 0, self.frame.size.width-10, 30) andColor:self.tintColor];
        [self.layer addSublayer:textLayer];
        self.textLayer = textLayer;
    }else if (self.style == roundProgressStyle){
        UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) radius:50 startAngle:-M_PI_2 endAngle:3*M_PI_2 clockwise:true];
        CAShapeLayer *roundLayer = [self creatShapeLayerWithPath:path andFillColor:[UIColor clearColor] andStrokeColor:self.progressBackgroundColor];
        roundLayer.lineWidth = 10.0;
        roundLayer.strokeStart = 0;
        roundLayer.strokeEnd = 1;
        [self.layer addSublayer:roundLayer];
        
        CAShapeLayer *proLayer = [self creatShapeLayerWithPath:path andFillColor:[UIColor clearColor] andStrokeColor:self.tintColor];
        proLayer.cornerRadius = 2.0;
        proLayer.lineWidth = 10.0;
        proLayer.strokeStart = 0;
        proLayer.strokeEnd = 0;
        proLayer.lineCap = @"round";
        [self.layer addSublayer:proLayer];
        self.roundProLayer = proLayer;
    
        CATextLayer *textLayer = [self creatTextLayerWithStr:[NSString stringWithFormat:@"%.2f%%",self.progress] andPosition:CGPointMake(self.frame.size.width/2, self.frame.size.height/2+5) andBounds:CGRectMake(0, 0, 100, 30) andColor:self.tintColor];
        [self.layer addSublayer:textLayer];
        self.textLayer = textLayer;
    }else if (self.style == waveProgressStyle){
        self.waveBgView.hidden = NO;
        UIBezierPath *wavePath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(50, 50) radius:50 startAngle:M_PI_2 - self.progress*M_PI/100.0 endAngle:M_PI_2 + self.progress*M_PI/100.0 clockwise:true];
        CAShapeLayer *waveLayer = [self creatShapeLayerWithPath:wavePath andFillColor:ym_waveTopColor andStrokeColor:[UIColor clearColor]];
        CAShapeLayer *waveLayer1 = [self creatShapeLayerWithPath:wavePath andFillColor:ym_waveBottomColor andStrokeColor:[UIColor clearColor]];
        [self.waveBgView.layer addSublayer:waveLayer1];
        [self.waveBgView.layer addSublayer:waveLayer];
        self.topWaveLayer = waveLayer;
        self.bottomWaveLayer = waveLayer1;
        CATextLayer *textLayer = [self creatTextLayerWithStr:[NSString stringWithFormat:@"%.2f%%",self.progress] andPosition:CGPointMake(50, 55) andBounds:CGRectMake(0, 0, 60, 30) andColor:self.tintColor];
        [self.waveBgView.layer addSublayer:textLayer];
        self.textLayer = textLayer;
    }
    [super awakeFromNib];
}

- (void)setStyle:(NSInteger)style{
    _style = style;
}

- (void)configWaveInfo{
    //振幅
    _wave_amplitude = 100 / 25;
    //周期
    _wave_cycle = 2 * M_PI / (100 * 0.8);
    //两波之间距离
    _wave_h_distance = 2 * M_PI / _wave_cycle * 0.6;
    [self addDisplayLinkAction];
}

- (void)addDisplayLinkAction
{
    if (_displayLink) {
        [self removeDisplayLinkAction];
    }
    _displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displayLinkAction)];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}

- (void)displayLinkAction
{
    //完成
    if (_progress*ym_wave_ySpeed > _process){
        _process ++;
    }
    _wave_offsetx += ym_wave_xSpeed;
    UIBezierPath *wavePath = [self creatWavePathWithOffsetX:0];
    UIBezierPath *wavePath1 = [self creatWavePathWithOffsetX:_wave_h_distance];
    self.topWaveLayer.path = wavePath.CGPath;
    self.bottomWaveLayer.path = wavePath1.CGPath;
}

- (void)removeDisplayLinkAction
{
    self.process = 0;
    [_displayLink invalidate];
    _displayLink = nil;
}

#pragma mark - 共用方法
- (CAShapeLayer *)creatShapeLayerWithPath:(UIBezierPath *)path andFillColor:(UIColor *)fillcolor andStrokeColor:(UIColor *)strokeColor{
    CAShapeLayer *layer = [CAShapeLayer layer];
    layer.path = path.CGPath;
    layer.fillColor = fillcolor.CGColor;
    layer.strokeColor = strokeColor.CGColor;
    return layer;
}

- (CALayer *)creatLayerWithPosition:(CGPoint)position andBounds:(CGRect)bounds andBackgroundColor:(UIColor *)color{
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = bounds;
    layer.backgroundColor = color.CGColor;
    return layer;
}

- (CABasicAnimation *)creatAniWithKeyPath:(NSString *)keyPath andToValue:(id)toValue andDuration:(NSTimeInterval)duration{
    CABasicAnimation *ani = [CABasicAnimation animationWithKeyPath:keyPath];
    ani.toValue = toValue;
    ani.duration = duration;
    ani.fillMode = kCAFillModeBoth;
    ani.removedOnCompletion = NO;
    return ani;
}

- (CATextLayer *)creatTextLayerWithStr:(NSString *)str andPosition:(CGPoint)position andBounds:(CGRect)bounds andColor:(UIColor *)color{
    CATextLayer *layer = [CATextLayer layer];
    layer.string = str;
    layer.position = position;
    layer.bounds = bounds;
    layer.fontSize = 16.f;
    layer.wrapped = YES;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.contentsScale = [UIScreen mainScreen].scale;
    layer.foregroundColor = color.CGColor;
    return layer;
}

- (UIBezierPath *)creatWavePathWithOffsetX:(CGFloat)offsetX{
    UIBezierPath *wavePath = [UIBezierPath bezierPath];
    for (float next_x = 0.f; next_x <= 100; next_x ++) {
        //正弦函数，绘制波形
        CGFloat next_y = _wave_amplitude * sin(_wave_cycle * next_x + (_wave_offsetx+offsetX) / 100 * 2 * M_PI) + (100 - _process/ym_wave_ySpeed) ;
        if (next_x == 0) {
            [wavePath moveToPoint:CGPointMake(next_x, next_y - _wave_amplitude)];
        }else {
            [wavePath addLineToPoint:CGPointMake(next_x, next_y - _wave_amplitude)];
        }
    }
    [wavePath addLineToPoint:CGPointMake(100, 100)];
    [wavePath addLineToPoint:CGPointMake(0, 100)];
    [wavePath closePath];
    return wavePath;
}

- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    if (self.style == lineProgressStyle || self.style == roundProgressStyle) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(running) userInfo:nil repeats:MAXFLOAT];
    }else{
        [self configWaveInfo];
    }
    self.textLayer.string = [NSString stringWithFormat:@"%.2f%%",progress];
    _process = 0;
    if(self.timer){
        [self.timer invalidate];
    }
}

- (void)running{
    self.process += 1;
    if (self.progress >= self.process) {
        if (self.style == lineProgressStyle) {
            CABasicAnimation *lineAni = [self creatAniWithKeyPath:@"transform.scale.x" andToValue:[NSNumber numberWithFloat:self.process] andDuration:0.1];
            [self.lineProLayer addAnimation:lineAni forKey:nil];
        }else if (self.style == roundProgressStyle){
            self.roundProLayer.strokeEnd = self.process/100.0;
        }
    }else{
        self.process = 0;
        [self.timer invalidate];
    }
}

@end
