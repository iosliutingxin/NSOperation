//
//  ViewController.m
//  NSOperation
//
//  Created by 李孔文 on 2018/6/1.
//  Copyright © 2018年 Sunning. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
//全局队列
@property(nonatomic,strong)NSOperationQueue *queue;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

//懒加载
-(NSOperationQueue *)queue{
    
    if (!_queue) {
        _queue = [[NSOperationQueue alloc]init];
    }
    return _queue;
}
//-------------------------------------begin-----------------------------------------------
/**
                    NSOperation的核心概念就是将“操作”添加到队列中
                    GCD 将“任务”添加到队列中
 */
//----------------------NSInvocationOperation-----------------------------------------------
-(void)dome01{
    
    //1、操作
    NSInvocationOperation * op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadImage:) object:@"invocation"];
    
    //队列
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    [q addOperation:op];
}
/**
 开启多个线程--不会顺序执行--GCD并发队列，异步执行
 nsoperation 本质上是对 GCD的封装
 */
-(void)dome02{
    
    //队列
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
    for (int i = 0;  i<10 ; i++) {
        //1、操作
        NSInvocationOperation * op = [[NSInvocationOperation alloc]initWithTarget:self selector:@selector(downloadImage:) object:@"invocation"];
        [q addOperation:op];

    }
}


-(void)downloadImage:(id)objc{
    NSLog(@"downlaod==线程==%@,对象%@",[NSThread currentThread],objc);
    
}

//----------------------NSBlockOperation-----------------------------------------------
//NSBlockOperation所有代码都写在block里面
-(void)dome03{
    
    //1、队列
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
     //2、操作
    for (int i = 0;  i<10 ; i++) {
        NSBlockOperation * op = [NSBlockOperation blockOperationWithBlock:^{
            NSLog(@"线程----%@",[NSThread currentThread]);
        }];
        [q addOperation:op];
        
    }
}
//简单写法
-(void)dome04{
    //1、队列---在实际发中使用全局队列--定义☝️全局队列
    NSOperationQueue * q = [[NSOperationQueue alloc]init];
    
    for (int i = 0; i<10; i++) {
        [q addOperationWithBlock:^{
            
            NSLog(@"线程----%@",[NSThread currentThread]);
            
        }];
    }
}


//全局队列演示----只要是Operation的子类都可以添加到队列
-(void)dome05{
  
    for (int i = 0;  i<10; i++) {
        [self.queue addOperationWithBlock:^{
            
            NSLog(@"线程----%@",[NSThread currentThread]);

        }];
    }
}
//线程间的通讯
-(void)dome06{
    
    [self.queue addOperationWithBlock:^{
        
        NSLog(@"耗时操作---线程----%@",[NSThread currentThread]);
        //更新主线程的UI
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            
            NSLog(@"更新主线程的UI---线程----%@",[NSThread currentThread]);
            
        }];
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self dome06];
}


@end
