# scatter_gather_aes_cuda
A High-Performance Side-Channel-Resistant AES on GPUs, paper published in GPGPU'19.

https://people.engr.ncsu.edu/hzhou/aes_gpgpu19.pdf


# to generate size-fixed file  in *./text_generator*


```
head -c 100M </dev/urandom > ./text_generator/pt_100MB.txt
```