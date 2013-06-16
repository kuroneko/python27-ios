//
//  Python27Tests.m
//  Python27Tests
//
//  Created by Chris Collins on 13/06/13.
//  Copyright (c) 2013 Chris Collins. All rights reserved.
//

#import "Python27Tests.h"

#include "Python.h"

@implementation Python27Tests

- (void)setUp
{
    [super setUp];
    
    Py_Initialize();
}

- (void)tearDown
{
    Py_Finalize();

    [super tearDown];
}

- (void)testInterpreter
{
    PyRun_SimpleString("from time import time,ctime\n"
                       "print 'Today is',ctime(time())\n");
    
}

@end
