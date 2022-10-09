TARGET_ARCH := spike_riscv64
TARGET_TOOLCHAIN_PREFIX := riscv64-unknown-elf-

PLATFORM_FLAGS = \
  -DPREALLOCATE=1 \
  -DMULTITHREAD=1 \
  -mcmodel=medany \
  -funsigned-char \
  -fno-delete-null-pointer-checks \
  -fomit-frame-pointer \
  -fno-builtin-printf \
  -DTF_LITE_MCU_DEBUG_LOG \
  -DTF_LITE_USE_GLOBAL_CMATH_FUNCTIONS \
  -ffast-math \
  -fno-common \
  -fno-builtin-printf \
  -march=rv64gc \
#   -march=rv64gcxhwacha \
#   -I$(TENSORFLOW_ROOT)/riscv-tests \
#   -I$(TENSORFLOW_ROOT)/riscv-tests/env \
#   -I$(TENSORFLOW_ROOT) \
#   -I$(BENCH_COMMON) \


CC_WARNINGS := \
  -Wsign-compare \
  -Wdouble-promotion \
  -Wshadow \
  -Wunused-variable \
  -Wunused-function \
  -Wswitch \
  -Wvla \
  -Wall \
  -Wextra \
  -Wmissing-field-initializers \
  -Wstrict-aliasing \
  -Wno-unused-parameter

COMMON_FLAGS := \
  -fno-unwind-tables \
  -ffunction-sections \
  -fdata-sections \
  -fmessage-length=0 \
  -DTF_LITE_STATIC_MEMORY \
  -DTF_LITE_DISABLE_X86_NEON \
  -DTF_LITE_USE_CTIME \
  -O2 \
  $(CC_WARNINGS) 
  



CXXFLAGS := \
  -std=c++11 \
  -fno-rtti \
  -fno-exceptions \
  -fno-threadsafe-statics \
  $(COMMON_FLAGS)

CCFLAGS := \
  -Wimplicit-function-declaration \
  -std=c11 \
  $(COMMON_FLAGS)



ARFLAGS := -r

ifneq ($(TOOLCHAIN), )
  CXXFLAGS += $(PLATFORM_FLAGS) \
  -fpermissive \
  -fno-use-cxa-atexit \
  -DTF_LITE_USE_GLOBAL_MIN \
  -DTF_LITE_USE_GLOBAL_MAX

  CCFLAGS += $(PLATFORM_FLAGS)\
  -std=gnu99 \
  -lm \
  -lgcc \

endif
