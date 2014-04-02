//
//  PMRMyScene.m
//  CenterBall
//
//  Created by Pruthvikar Reddy on 30/03/2014.
//  Copyright (c) 2014 Pruthvikar Reddy. All rights reserved.
//


static const uint32_t ballCategory     =  0x1 << 0;
static const uint32_t barCategory        =  0x1 << 1;
static const uint32_t wallCategory        =  0x1 << 2;

#import "PMRMyScene.h"
#import <CoreMotion/CoreMotion.h>
@interface PMRMyScene ()<UIAccelerometerDelegate,SKPhysicsContactDelegate>
@property (nonatomic,strong) SKSpriteNode* bar;
@property (nonatomic,strong) SKSpriteNode* ball;
@property (nonatomic,strong) SKNode* center;
@property (nonatomic,strong) CMMotionManager * manager;
@property (nonatomic) double prevYaw;
@property (nonatomic) NSTimeInterval lastUpdateTimeInterval;
@end

@implementation PMRMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:0.15 green:0.15 blue:0.3 alpha:1.0];

        _manager = [[CMMotionManager alloc] init];
        [self addBarAndBall];

        [_manager startDeviceMotionUpdates];
        _prevYaw=0;
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        self.physicsWorld.gravity=CGVectorMake(0.0,0.0);
        self.physicsWorld.contactDelegate=self;
        self.physicsBody.categoryBitMask=wallCategory;
        self.physicsBody.restitution=1.0;
    }
    return self;
}
- (void)update:(NSTimeInterval)currentTime {
    // Handle time delta.
    // If we drop below 60fps, we still want everything to move the same distance.
    CFTimeInterval timeSinceLast = currentTime - self.lastUpdateTimeInterval;
    self.lastUpdateTimeInterval = currentTime;
    if (timeSinceLast > 1) { // more than a second since last update
        timeSinceLast = 1.0 / 60.0;
        self.lastUpdateTimeInterval = currentTime;
    }
    
    [self updateWithTimeSinceLastUpdate:timeSinceLast];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    

}

CGFloat SDistanceBetweenPoints(CGPoint first, CGPoint second) {
    return hypotf(second.x - first.x, second.y - first.y);
}

-(void)updateWithTimeSinceLastUpdate:(NSTimeInterval)time
{

    NSLog(@"%f %f %f",((_manager.deviceMotion.attitude.pitch-M_PI_2)/M_PI)*180.0,(_manager.deviceMotion.attitude.yaw/M_PI)*180.0,(_manager.deviceMotion.attitude.roll/M_PI)*180.0);
//rotate around line left to right, rotate around line above phone to below phone, rotate around top of phone to bottom
    double yaw;
//    if (_manager.deviceMotion.attitude.pitch<M_PI_4 && _manager.deviceMotion.attitude.pitch>-M_PI_4) {
    
    
    yaw=_manager.deviceMotion.attitude.yaw;
//    }
//    else{
//    if (_manager.deviceMotion.attitude) {
//        <#statements#>
//    }
//    yaw=(_manager.deviceMotion.attitude.pitch)-M_PI_2;
//    }
    double moveTo=_prevYaw-yaw;
    SKAction *rotation = [SKAction rotateByAngle:moveTo duration:0];
    SKAction *translation= [SKAction moveTo:CGPointMake(-100*sinf(yaw), -200*cosf(yaw)) duration:0];
    SKAction* group=[SKAction group:@[rotation,translation]];
    //and just run the action

    [_bar runAction:group];
    _prevYaw=yaw;

    [_ball.physicsBody applyForce:CGVectorMake(-60*sinf(yaw), -60*cosf(yaw))];
}

-(void)addBarAndBall{
    _bar = [SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
    _ball = [SKSpriteNode spriteNodeWithImageNamed:@"Ball"];

    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    _center=[[SKNode alloc]init];
    _center.position=CGPointMake(screenWidth/2, screenHeight/2);
    
    _bar.position = CGPointMake(0,200);
    _ball.position=_center.position;
    
    _bar.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:_bar.size];
    _bar.physicsBody.dynamic = NO;
    
    _ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:_ball.size.width/2];
    _ball.physicsBody.dynamic = YES;
    

    
    _ball.physicsBody.mass=1.5;
    _ball.physicsBody.mass=5.0;
    
    _bar.physicsBody.restitution=1.5;
    _bar.physicsBody.mass=0.5;
    
    _ball.physicsBody.categoryBitMask = ballCategory;
    _ball.physicsBody.collisionBitMask = barCategory | wallCategory;
    _ball.physicsBody.contactTestBitMask = barCategory ;
    
    _bar.physicsBody.categoryBitMask = barCategory;
    _bar.physicsBody.collisionBitMask = ballCategory;
    _bar.physicsBody.contactTestBitMask = ballCategory;


    _ball.physicsBody.velocity=CGVectorMake(0, -250.0);
    
    [self addChild:_center];
    [_center addChild:_bar];
    [self addChild:_ball];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *ball, *bar;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        ball = contact.bodyA;
        bar = contact.bodyB;
    }
    else
    {
        ball = contact.bodyB;
        bar = contact.bodyA;
    }
//    ball.velocity=CGVectorMake(ball.velocity.dx*-1, ball.velocity.dy*-1);
}



@end
