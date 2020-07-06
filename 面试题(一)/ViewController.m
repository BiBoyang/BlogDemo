//
//  ViewController.m
//  TaggedPointer
//
//  Created by 毕博洋 on 2018/10/7.
//  Copyright © 2018 毕博洋. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) NSString *target;

//@property (atomic, strong) NSString *target;//使用atomic方法

//@property (nonatomic, strong) NSString *target;//使用weak方法

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    
    dispatch_queue_t queue = dispatch_queue_create("parallel", DISPATCH_QUEUE_CONCURRENT);
//    dispatch_queue_t queue = dispatch_queue_create("parallel", DISPATCH_QUEUE_SERIAL);//使用串行队列方法

    for (int i = 0; i < 10000 ; i++)
    {
        //后台线程执行
        dispatch_async(queue, ^{
            self.target = [NSString stringWithFormat:@"abcdefghijk%d",i];
            //使用Tagged Pointer解决
//            self.target = [NSString stringWithFormat:@"aa%d",i];
        });
    }

    

    
    

    
}


@end
