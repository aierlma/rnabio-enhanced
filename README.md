# RNAbio-Enhanced Dockerfile

This Dockerfile was developed as I explored RNA-seq tools. It closely follows the installation steps provided by the rnabio image as outlined on their [Tool Installation page](https://rnabio.org/module-00-setup/0000/10/01/Installation/), but includes slight modifications to tailor it to specific requirements.

These changes help adapt the setup to more precisely fit the needs of my projects while maintaining the integrity of the original rnabio configuration.

Feel free to explore this Dockerfile, and adapt it as needed for your research or projects!

# Installation
If you just want to use it, run
```
docker pull aierlma/rnabio_enhanced:latest
```
Then just run this 
```
docker run --user ubuntu:ubuntu -it aierlma/rnabio_enhanced:latest /bin/bash
```

I suggest that Windows users use VSCode and docker desktop to connect to the container.

If you want to mount your local dir to the container, run this 
```
docker run -v /Your/Path/to/dir:/workspace:rw --user ubuntu:ubuntu -it aierlma/rnabio_enhanced:latest /bin/bash 
```

and you'll find "/Your/Path/to/dir"(which on your PC) in the "/workspace" dir in your container
