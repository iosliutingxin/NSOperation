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
 
 GCD在ios4.0推出，主要处针对多核处理器优化并发技术，c语言
 1、将任务“block”添加到队列中，队列【窜行、并发、主队列，全局队列】，并且指定执行任务的函数【同步、异步】
 2、线程间的通讯 dispatch_get_mian_queue()
 3、提供了一些NSOperation不具备功能---一次执行、延迟执行，调度组
 
 
 
 NSOperation在ios2.0推出，推出GCD后duiNSOperation进行了重写
 1、将操作“异步执行的任务”添加到队列中【并发队列】就会立即执行
 2、mainqueue
 3、提供一些GCD实现比较困难的功能----最大并发数、队列的暂停、继续、取消所有操作、操作间的依赖关系
 
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
//----------------------最大并发数-----------------------------------------------
-(void)dome07{

    /**
     从ios8开始，无论是GCD或者nsoperation都会开启很多线程
     */
    //并发操作数量,控制线程数量，------------》线程回收
    //WiFi 5~6
    //3G 2~3
    self.queue.maxConcurrentOperationCount = 2;
    
    for (int i = 0;  i<20; i++) {
        [self.queue addOperationWithBlock:^{
            
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"线程----%@----》%d",[NSThread currentThread],i);
            
        }];
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {

    [self dome07];
}


@end
