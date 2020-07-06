//
//  ViewController.m
//  BlockBlogTest
//
//  Created by 毕博洋 on 2018/11/19.
//  Copyright © 2018 毕博洋. All rights reserved.
//

#import "ViewController.h"
#import "objc/runtime.h"
#import "fishhook.h"
#import "mach/mach.h"
#import "malloc/malloc.h"

@interface ViewController ()

@property (nonatomic, copy) NSString *string;

@property (nonatomic, copy) void (^BBY_Block)(void);

@end

@implementation ViewController



- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    void (^block)(void) = ^void() {
        NSLog(@"白日依山尽 ");
    };
    HookBlockToPrintHelloWorld(block);
    block();
    
    void (^hookBlock)(int i,NSString *str) = ^void(int i,NSString *str){
        NSLog(@"bby");
    };
    HookBlockToPrintArguments(hookBlock);
    hookBlock(1,@"biboyang");
    
    
    self.BBY_Block = ^{
        NSLog(@"biboyang");
    };

    [self blockProblem];
    
}

- (void)blockProblem {
    __block int a = 0;
    void (^block)(void) = ^{
        self.string = @"retain";
        NSLog(@"biboyang");
        NSLog(@"biboyang_blockProblemAnswer%d",a);
    };
//    block();//禁止
    
    a = 0;
    [self blockProblemAnswer0:block];

    a = 1;
    [self blockProblemAnswer1:block];

    a = 2;
    [self blockProblemAnswer2:block];

    a = 3;
    [self blockProblemAnswer3:block];

    a = 4;
    [self blockProblemAnswer4:block];

    a = 5;
    [self blockProblemAnswer5:block];

    a = 6;
    [self blockProblemAnswer6:block];
    
    
}

- (void)blockProblemAnswer0:(void(^)(void))block {
    [UIView animateWithDuration:0 animations:block];
    dispatch_async(dispatch_get_main_queue(), block);
}


- (void)blockProblemAnswer1:(void(^)(void))block {
    [[NSBlockOperation blockOperationWithBlock:block]start];
}

- (void)blockProblemAnswer2:(void(^)(void))block {
    //    //方法标签
    //    NSMethodSignature *signature = [self methodSignatureForSelector:@selector(description)];
    //    //描述方法签名
    //    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    //    invocation.target = self;
    //    invocation.selector = @selector(description);
    //    [invocation invoke];
    
        NSMethodSignature *signature = [NSMethodSignature signatureWithObjCTypes:"v@?"];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    [invocation invokeWithTarget:block];

}

- (void)blockProblemAnswer3:(void(^)(void))block {
    [block invoke];
}

- (void)blockProblemAnswer4:(void(^)(void))block {
    
    void *pBlock = (__bridge void*)block;
    
    void (*invoke)(void *,...) = *((void **)pBlock + 2);
    invoke(pBlock);
}


static void blockCleanUp(__strong void(^*block)(void)){
    (*block)();
}
- (void)blockProblemAnswer5:(void(^)(void))block {
    
    __strong void(^cleaner)(void) __attribute ((cleanup(blockCleanUp),unused)) = block;
}

- (void)blockProblemAnswer6:(void(^)(void))block {
    asm("movq -0x18(%rbp), %rdi");
    asm("callq *0x10(%rax)");
}


#pragma mark ----HookBlock_1
typedef struct __block_impl {
    void *isa;
    int Flags;
    int Reserved;
    void *FuncPtr;
}__block_impl;


void hookBlockMethod() {
    NSLog(@"黄河入海流");
}

void OriginalBlock (id Or_Block) {
    void(^block)(void) = Or_Block;
    block();
}

void HookBlockToPrintHelloWorld(id block) {
    __block_impl *ptr = (__bridge __block_impl *)block;
    OriginalBlock(block);
    ptr->FuncPtr = &hookBlockMethod;
}

#pragma mark ----HookBlock_2

static void (*orig_func)(void *v ,int i, NSString *str);

void hookFunc_2(void *v ,int i, NSString *str) {
    NSLog(@"%d,%@", i, str);
    orig_func(v,i,str);
}

void HookBlockToPrintArguments(id block) {
    __block_impl *ptr = (__bridge __block_impl *)block;
    orig_func = ptr->FuncPtr;
    ptr->FuncPtr = &hookFunc_2;
}





@end
