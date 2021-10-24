# Learn Python Asyncio from C++
## Introduction of asyncio
Asyncio is a library used to develop high performance IO-intensive programs. Compared to traditional event-loop based IO program, asyncio allow us to program a async program in sync way.

## Eventloop
Classic code structure of traditional event-loop based IO program is like follow(Epoll for example)
```
epoll_fd = epoll_create();  # create epoll
epoll_ctl(epoll_fd, EPOLL_CTL_ADD, event_struct)  # add fd to epoll and start listening for events
while(true){        # start event loop
    result = epoll_wait(...);   # get event from epoll
    for i in result{    # Iterate result fd
        if (i.event | READ) # If fd readable
            do_something();
        if (i.event | WRITE) # If fd writable
            do_something();
        if (i.event | ERROR) # If fd error
            do_something();
    }
}
```
In the code above, you create a epoll, which is an event
