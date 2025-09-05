#---------------------------------------------------------------------------------
# 基本设置
#---------------------------------------------------------------------------------
.SUFFIXES:
#---------------------------------------------------------------------------------

ifeq ($(strip $(DEVKITPRO)),)
$(error "请设置DEVKITPRO环境变量")
endif

PROJDIR     := $(CURDIR)
SOURCES     := $(PROJDIR)/src
INCLUDES    := $(PROJDIR)/include
DATA        := $(PROJDIR)/data
OUTDIR      := $(PROJDIR)/output

#---------------------------------------------------------------------------------
# 目标设置
#---------------------------------------------------------------------------------
TARGET      := $(notdir $(CURDIR))
BUILD       := build
OUTPUT_DIR  := atmosphere/contents/0100000000000799/exefs
OUTPUT_FILE := main

#---------------------------------------------------------------------------------
# 源文件、目标文件和库文件
#---------------------------------------------------------------------------------
SOURCES     := $(SOURCES)
INCLUDES    := $(INCLUDES)

#---------------------------------------------------------------------------------
# 选项
#---------------------------------------------------------------------------------
ARCH    := -march=armv8-a+crc+crypto -mtune=cortex-a57 -mtp=soft -fPIE

CFLAGS  := -g -Wall -O2 -ffunction-sections \
           $(ARCH) $(DEFINES)

CFLAGS  += $(INCLUDE) -D__SWITCH__

CXXFLAGS    := $(CFLAGS) -fno-rtti -fno-exceptions

ASFLAGS     := -g $(ARCH)
LDFLAGS     := -specs=$(DEVKITPRO)/libnx/switch.specs -g $(ARCH) -Wl,-Map,$(notdir $*.map)

LIBS    := -lnx

#---------------------------------------------------------------------------------
# 列出所有源文件
#---------------------------------------------------------------------------------
INCLUDE := $(foreach dir,$(INCLUDES),-I$(dir)) \
           $(foreach dir,$(LIBNX),-I$(dir)/include) \
           -I$(CURDIR)/$(BUILD)

CPPFILES    := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.cpp)))
CFILES      := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.c)))
SFILES      := $(foreach dir,$(SOURCES),$(notdir $(wildcard $(dir)/*.s)))

#---------------------------------------------------------------------------------
# 使用CXX编译C++文件，使用CC编译C文件
#---------------------------------------------------------------------------------
export OFILES_BIN := $(addsuffix .o,$(BINFILES))
export OFILES_SRC := $(CPPFILES:.cpp=.o) $(CFILES:.c=.o) $(SFILES:.s=.o)
export OFILES     := $(OFILES_BIN) $(OFILES_SRC)
export HFILES_BIN := $(addsuffix .h,$(subst .,_,$(BINFILES)))

export INCLUDE    := $(foreach dir,$(INCLUDES),-I$(dir)) \
                   $(foreach dir,$(LIBNX),-I$(dir)/include) \
                   -I$(CURDIR)/$(BUILD)

.PHONY: $(BUILD) clean all

#---------------------------------------------------------------------------------
all: $(BUILD)

$(BUILD):
	@[ -d $@ ] || mkdir -p $@
	@[ -d $(OUTDIR) ] || mkdir -p $(OUTDIR)
	@[ -d $(OUTDIR)/$(OUTPUT_DIR) ] || mkdir -p $(OUTDIR)/$(OUTPUT_DIR)
	@$(MAKE) --no-print-directory -C $(BUILD) -f $(CURDIR)/Makefile
	@cp $(BUILD)/$(TARGET).nso $(OUTDIR)/$(OUTPUT_DIR)/$(OUTPUT_FILE)
	@mkdir -p atmosphere/contents/0100000000000799/flags

#---------------------------------------------------------------------------------
clean:
	@echo 清理 $(TARGET)
	@rm -fr $(BUILD) $(OUTDIR)

#---------------------------------------------------------------------------------
else

EXPORT_DIR := $(CURDIR)/$(OUTDIR)
include $(DEVKITPRO)/libnx/switch_rules

#---------------------------------------------------------------------------------
# 主目标
#---------------------------------------------------------------------------------
main: $(OUTPUT).nso

#---------------------------------------------------------------------------------
# 导入源文件
#---------------------------------------------------------------------------------
#---------------------------------------------------------------------------------
%_bin.h %.bin.o: %.bin
#---------------------------------------------------------------------------------
	@echo $(notdir $<)
	@$(bin2o)

-include $(DEPSDIR)/*.d

#---------------------------------------------------------------------------------
# 编译规则
#---------------------------------------------------------------------------------
%.nso: %.elf
	@echo 创建 $@
	$(SILENTCMD)$(NXLINK) $(NXFLAGS) $< $(NXLINK_OPTIONS)

%.nro: %.elf
	@echo 创建 $@
	$(SILENTCMD)$(NXLINK) $(NXFLAGS) $< $(NXLINK_OPTIONS)

%.elf:
	@echo 链接 $@
	$(SILENTCMD)$(LD) $(LDFLAGS) $(OFILES) $(LIBPATHS) $(LIBS) -o $@
	$(SILENTCMD)$(NM) -CSn $@ > $(notdir $*.lst)

endif