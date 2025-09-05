#---------------------------------------------------------------------------------
# Nintendo Switch 模块构建系统
#---------------------------------------------------------------------------------

# 检查DEVKITPRO环境变量
ifeq ($(strip $(DEVKITPRO)),)
$(error "请设置DEVKITPRO环境变量。请参考README.md中的安装说明。")
endif

# 确保使用正确的工具链
DEVKITARM := $(DEVKITPRO)/devkitARM
DEVKITPPC := $(DEVKITPRO)/devkitPPC

# 设置工具链前缀
aarch64-none-elf-gcc := $(DEVKITPRO)/devkitA64/bin/aarch64-none-elf-gcc
aarch64-none-elf-g++ := $(DEVKITPRO)/devkitA64/bin/aarch64-none-elf-g++
aarch64-none-elf-ld := $(DEVKITPRO)/devkitA64/bin/aarch64-none-elf-ld
aarch64-none-elf-nm := $(DEVKITPRO)/devkitA64/bin/aarch64-none-elf-nm

# 显式设置编译工具变量
CC := $(aarch64-none-elf-gcc)
CXX := $(aarch64-none-elf-g++)
LD := $(aarch64-none-elf-ld)
NM := $(aarch64-none-elf-nm)

# 包含switch开发环境规则
include $(DEVKITPRO)/libnx/switch_rules

# 项目配置
PROJ_NAME     := $(notdir $(CURDIR))
BUILD_DIR     := build
OUTPUT_DIR    := atmosphere/contents/0100000000000799/exefs
OUTPUT_FILE   := main

# 源文件路径
SOURCES       := src
INCLUDES      := src

# 编译选项
# 编译器特定选项
COMPILER_FLAGS := -march=armv8-a+crc+crypto -mtune=cortex-a57 -fPIE -mtp=soft
# 链接器可识别的选项
LINKER_FLAGS   := -march=armv8-a+crc+crypto -fPIE

CFLAGS        := -g -Wall -O2 -ffunction-sections \
                 $(COMPILER_FLAGS) -D__SWITCH__
CXXFLAGS      := $(CFLAGS) -fno-rtti -fno-exceptions
ASFLAGS       := -g $(COMPILER_FLAGS)
LDFLAGS       := -specs=$(DEVKITPRO)/libnx/switch.specs -g $(LINKER_FLAGS) -Wl,-Map,$(notdir $(PROJ_NAME)).map

# 库文件
LIBS          := -lnx

# 查找所有源文件
CFILES        := $(wildcard $(SOURCES)/*.c)
CPPFILES      := $(wildcard $(SOURCES)/*.cpp)
SFILES        := $(wildcard $(SOURCES)/*.s)

# 生成目标文件列表
OFILES        := $(addsuffix .o,$(basename $(CFILES)))
OFILES        += $(addsuffix .o,$(basename $(CPPFILES)))
OFILES        += $(addsuffix .o,$(basename $(SFILES)))

# 生成构建目录中的目标文件路径
BUILD_OFILES  := $(addprefix $(BUILD_DIR)/,$(notdir $(OFILES)))

# 头文件包含路径
INCLUDE       := $(foreach dir,$(INCLUDES),-I$(CURDIR)/$(dir)) \
                 -I$(DEVKITPRO)/libnx/include

# 伪目标
.PHONY: all clean

# 主目标
all: $(OUTPUT_DIR)/$(OUTPUT_FILE)
	@echo "构建完成！输出文件位于: $(OUTPUT_DIR)/$(OUTPUT_FILE)"
	@mkdir -p atmosphere/contents/0100000000000799/flags
	@touch atmosphere/contents/0100000000000799/flags/boot2.flag
	@echo "已创建boot2.flag文件"

# 链接生成NSO文件
$(OUTPUT_DIR)/$(OUTPUT_FILE): $(BUILD_DIR)/$(PROJ_NAME).nso
	@mkdir -p $(OUTPUT_DIR)
	@cp $< $@

# 编译生成NSO文件
$(BUILD_DIR)/$(PROJ_NAME).nso: $(BUILD_DIR)/$(PROJ_NAME).elf
	@echo "创建 $@"
	$(NXLINK) $(NXFLAGS) $< -o $@

# 链接生成ELF文件
$(BUILD_DIR)/$(PROJ_NAME).elf: $(BUILD_OFILES)
	@echo "链接 $@"
	$(LD) $(LDFLAGS) $^ $(LIBS) -o $@
	$(NM) -CSn $@ > $(BUILD_DIR)/$(notdir $@).lst

# 编译C文件
$(BUILD_DIR)/%.o: $(SOURCES)/%.c
	@mkdir -p $(BUILD_DIR)
	@echo "编译 $<"
	$(CC) $(CFLAGS) $(INCLUDE) -c $< -o $@

# 编译C++文件
$(BUILD_DIR)/%.o: $(SOURCES)/%.cpp
	@mkdir -p $(BUILD_DIR)
	@echo "编译 $<"
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c $< -o $@

# 汇编S文件
$(BUILD_DIR)/%.o: $(SOURCES)/%.s
	@mkdir -p $(BUILD_DIR)
	@echo "汇编 $<"
	$(AS) $(ASFLAGS) -c $< -o $@

# 清理构建文件
clean:
	@echo "清理构建文件..."
	@rm -rf $(BUILD_DIR) $(OUTPUT_DIR)/$(OUTPUT_FILE)
	@echo "清理完成！"