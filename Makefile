TOOLCHAIN := riscv64-unknown-elf-
#TOOLCHAIN := 
CXX := $(TOOLCHAIN)g++
CC := $(TOOLCHAIN)gcc
AR := $(TOOLCHAIN)ar

TENSORFLOW_ROOT :=
RELATIVE_MAKEFILE_DIR := tensorflow/lite/micro/tools/make
MAKEFILE_DIR := $(TENSORFLOW_ROOT)$(RELATIVE_MAKEFILE_DIR)

DOWNLOADS_DIR := $(MAKEFILE_DIR)/downloads

BENCH_COMMON = $(TENSORFLOW_ROOT)/riscv-tests/benchmarks/common

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

LIBS := \
	-lm \
       	-lstdperiph \
       	-lusbdevcore  \
       	-lusbcore   \
       	-lusbdevmidi

MICROLITE_LIBS := -lm


GENDIR := riscv/

ifeq ($(TOOLCHAIN), )
  GENDIR := test/
endif

CORE_OBJDIR := $(GENDIR)obj/core/
KERNEL_OBJDIR := $(GENDIR)obj/kernels/
THIRD_PARTY_KERNEL_OBJDIR := $(GENDIR)obj/third_party_kernels/
THIRD_PARTY_OBJDIR := $(GENDIR)obj/third_party/
GENERATED_SRCS_DIR := $(GENDIR)genfiles/
BINDIR := $(GENDIR)bin/
LIBDIR := $(GENDIR)lib/
PRJDIR := $(GENDIR)prj/

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


ifeq ($(TOOLCHAIN), gcc)
  ifneq ($(TARGET), osx)
    # GCC on MacOS uses an LLVM backend so we avoid the additional linker flags
    # that are unsupported with LLVM.
    LDFLAGS += \
      -Wl,--fatal-warnings \
      -Wl,--gc-sections
  endif
endif

INCLUDES := \
-I/opt/riscv/lib/gcc/riscv64-unknown-elf/9.2.0/include/ \
-I.$(TENSORFLOW_ROOT)\
-I. \
-I$(DOWNLOADS_DIR)/gemmlowp \
-I$(DOWNLOADS_DIR)/flatbuffers/include \
-I$(DOWNLOADS_DIR)/ruy


ifneq ($(TENSORFLOW_ROOT),)
  INCLUDES += -I$(TENSORFLOW_ROOT)
endif

ifneq ($(EXTERNAL_DIR),)
  INCLUDES += -I$(EXTERNAL_DIR)
endif



MICROLITE_CC_KERNEL_SRCS := \
$(wildcard tensorflow/lite/micro/kernels/*.cc) 

TFL_CC_SRCS := \
$(shell find tensorflow/lite -type d \( -path tensorflow/lite/experimental -o -path tensorflow/lite/micro \) -prune -false -o -name "*.cc" -o -name "*.c")

TFL_CC_HDRS := \
$(shell find tensorflow/lite -type d \( -path tensorflow/lite/experimental -o -path tensorflow/lite/micro \) -prune -false -o -name "*.h")

MICROLITE_CC_BASE_SRCS := \
$(wildcard tensorflow/lite/micro/*.cc) \
$(wildcard tensorflow/lite/micro/arena_allocator/*.cc) \
$(wildcard tensorflow/lite/micro/memory_planner/*.cc) \
$(TFL_CC_SRCS)


MICROLITE_CC_HDRS := \
-I.  \
-Itensorflow/lite/micro/ \
-Itensorflow/lite/micro/*.h \
-Itensorflow/lite/micro/benchmarks/\
-Itensorflow/lite/micro/kernels/*.h \
-Itensorflow/lite/micro/arena_allocator/  \
-Itensorflow/lite/micro/memory_planner/ \
-Itensorflow/lite/kernels/internal/ \
-Ithird_party/flatbuffers/include/flatbuffers/*.h \
-Ithird_party/flatbuffers/  \
-Ithird_party/gemmlowp/  \
-Ithird_party/ruy/ruy/profiler/*.h  \
-Ithird_party/kissfft/*.h  \
-Ithird_party/gemmlowp/fixedpoint/*.h  \
-Iusr/include/  \
-Iusr/include/x86_64-linux-gnu/c++/9/bits/  \
-Iusr/include/x86_64-linux-gnu/bits/  \
-Iusr/include/c++/9/  \
-Itensorflow/lite/micro/models/*.h \

THIRD_PARTY_CC_HDRS := \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/allocator.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/array.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/base.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/buffer.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/buffer_ref.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/default_allocator.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/detached_buffer.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flatbuffer_builder.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flatbuffers.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/flexbuffers.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/stl_emulation.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/string.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/struct.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/table.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/vector.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/vector_downward.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/verifier.h \
$(DOWNLOADS_DIR)/flatbuffers/include/flatbuffers/util.h \
$(DOWNLOADS_DIR)/flatbuffers/LICENSE.txt \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint.h \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint_neon.h \
$(DOWNLOADS_DIR)/gemmlowp/fixedpoint/fixedpoint_sse.h \
$(DOWNLOADS_DIR)/gemmlowp/internal/detect_platform.h \
$(DOWNLOADS_DIR)/gemmlowp/LICENSE \
$(DOWNLOADS_DIR)/kissfft/COPYING \
$(DOWNLOADS_DIR)/kissfft/kiss_fft.c \
$(DOWNLOADS_DIR)/kissfft/kiss_fft.h \
$(DOWNLOADS_DIR)/kissfft/_kiss_fft_guts.h \
$(DOWNLOADS_DIR)/kissfft/tools/kiss_fftr.c \
$(DOWNLOADS_DIR)/kissfft/tools/kiss_fftr.h \
$(DOWNLOADS_DIR)/ruy/ruy/profiler/instrumentation.h


MICROLITE_BENCHMARK_SRCS := \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/benchmarks/*benchmark.cc)

MICROLITE_TEST := \
$(wildcard $(TENSORFLOW_ROOT)tensorflow/lite/micro/kernels/*_test.cc)

MICROLITE_TEST_SRCS := \
$(wildcard tensorflow/lite/tools/make/downloads/flatbuffers/src/util.cpp)\
$(TENSORFLOW_ROOT)tensorflow/lite/micro/fake_micro_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/flatbuffer_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_arena_threshold_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_allocation_info_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_context_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_log_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_interpreter_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_mutable_op_resolver_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_resource_variable_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_string_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_time_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/micro_utils_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/recording_micro_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/non_persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/persistent_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/recording_single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/arena_allocator/single_arena_buffer_allocator_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/testing_helpers_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/greedy_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/linear_memory_planner_test.cc \
$(TENSORFLOW_ROOT)tensorflow/lite/micro/memory_planner/non_persistent_buffer_planner_shim_test.cc




ALL_SRCS := \
  $(MICROLITE_CC_SRCS) \
  $(MICROLITE_CC_KERNEL_SRCS) 


INCLUDES += $(MICROLITE_CC_HDRS)

MICROLITE_CC_SRCS := $(filter-out $(MICROLITE_TEST_SRCS), $(MICROLITE_CC_BASE_SRCS))
MICROLITE_CC_SRCS := $(filter-out $(MICROLITE_BENCHMARK_SRCS), $(MICROLITE_CC_SRCS))
MICROLITE_CC_KERNEL_SRCS := $(filter-out $(MICROLITE_TEST), $(MICROLITE_CC_KERNEL_SRCS))

MICROLITE_LIB_NAME := libtensorflow-microlite.a

MICROLITE_LIB_PATH := $(LIBDIR)$(MICROLITE_LIB_NAME)

all : target

MICROLITE_LIB_OBJS := $(addprefix $(CORE_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(patsubst %.cpp,%.o,$(MICROLITE_CC_SRCS))))))

MICROLITE_KERNEL_OBJS := $(addprefix $(KERNEL_OBJDIR), \
$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(MICROLITE_CC_KERNEL_SRCS)))))

$(CORE_OBJDIR)%.o: %.cpp $(MICROLITE_CC_SRCS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@


$(CORE_OBJDIR)%.o: %.cc $(MICROLITE_CC_SRCS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) -c $< -o $@


$(CORE_OBJDIR)%.o: %.c $(MICROLITE_CC_SRCS)
	@mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) $(INCLUDES)  -c $< -o $@

$(KERNEL_OBJDIR)%.o: %.cc $(MICROLITE_CC_KERNEL_SRCS)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES)  -c $< -o $@

$(KERNEL_OBJDIR)%.o: %.c $(MICROLITE_CC_KERNEL_SRCS)
	@mkdir -p $(dir $@)
	$(CC) $(CCFLAGS) $(INCLUDES)  -c $< -o $@


PROJ_NAME = hello_world

PROJ_ROOT := tensorflow/lite/micro/examples/$(PROJ_NAME)

ALL_SRCS += \
$(wildcard $(PROJ_ROOT)/*.cc)



PROJ_CC := $(wildcard $(PROJ_ROOT)/*.cc)

INCLUDES += -I$(PROJ_ROOT)/

PROJ_OBJ := $(addprefix $(CORE_OBJDIR),$(patsubst %.S,%.o,$(patsubst %.cc,%.o,$(patsubst %.c,%.o,$(PROJ_CC)))))

PROJ_BINARY := $(BINDIR)$(PROJ_NAME)

$(PROJ_NAME)_BINARY : $(PROJ_BINARY)

$(CORE_OBJDIR)%.o: %.cc $(PROJ_CC)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES)  -c $< -o $@

$(MICROLITE_LIB_PATH): $(MICROLITE_LIB_OBJS) $(MICROLITE_KERNEL_OBJS) $(PROJ_OBJ)
	@mkdir -p $(dir $@)
	$(AR) $(ARFLAGS) $(MICROLITE_LIB_PATH) $(MICROLITE_LIB_OBJS) $(MICROLITE_KERNEL_OBJS) $(PROJ_OBJ)



$(PROJ_BINARY): $(PROJ_OBJ) $(MICROLITE_LIB_PATH)
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) $(INCLUDES) \
		-o $(PROJ_BINARY) $(PROJ_OBJ) \
		$(MICROLITE_LIB_PATH) $(LDFLAGS) $(MICROLITE_LIBS)

target:$(MICROLITE_LIB_PATH) $(PROJ_BINARY)



$(DEPDIR)/%.d: ;
.PRECIOUS: $(DEPDIR)/%.d
.PRECIOUS: $(BINDIR)%_test

-include $(patsubst %,$(DEPDIR)/%.d,$(basename $(ALL_SRCS)))

.PHONY: clean

clean:
	rm -r $(GENDIR)obj/core/tensorflow/lite/micro/examples/
	rm -r $(BINDIR)
	
