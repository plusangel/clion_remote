# Development environment with the most recent CMake and Boost Asio

In Clion, we can use remote host to support the development. 
To setup the environment follow this tutorial. Recently, studying Josh's Lospinoso
"C++ crash course", I needed to have the most recent boost libraries version instead
of default 1.65.1 that comes with Ubuntu 18.04. 

I used as reference dockerfile, the [one provided](https://github.com/JetBrains/clion-remote) by JetBrains and I modified to install
from source, the most recent CMake and Boost Libraries.

## Steps
Build and run:
```
docker build -t clion/remote-cpp-env:1.0 -f Dockerfile .
docker run -d --cap-add sys_ptrace -p127.0.0.1:2222:22 --name clion_remote_env clion/remote-cpp-env:1.0
ssh-keygen -f "$HOME/.ssh/known_hosts" -R "[localhost]:2222"
```
stop:
```
docker stop clion_remote_env
```