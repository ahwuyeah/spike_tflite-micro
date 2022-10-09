# SPIKE with tflite micro
I just modify original Makefile at  
`tensorflow/lite/micro/tools/make/`
Before you start making your own project, you should make third party downloads.
```
make -f tensorflow/lite/micro/tools/make/Makefile third_party_downloads
```
After that, you can put your project in
```
tensorflow/lite/micro/examples/
```
and modify `Makefile`at the root of spike_tflite-micro
find`PROJ_NAME` and modify to your own project folder name, than `save`&`make`.

Notice:
1. You should have toolchains and build with riscv 64 bits.
2. You need to modify `riscv-newlib/newlib/libm/common/math_errf.c` with command `sed -i '/__OBSOLETE_MATH/d' riscv-newlib/newlib/libm/common/math_errf.c` and `make & make install` of riscv-toolchain.
3. If you make successfully, you might find binary file in `riscv/bin/`
4. If you want to simulate your binary file in Spike, run command in the root of `spike_tflite-micro` => `spike pk riscv/bin/{YOUR_PROJ_NAME}`
