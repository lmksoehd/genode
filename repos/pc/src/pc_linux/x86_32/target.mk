TARGET   := x86_32_pc_linux
REQUIRES := x86_32

CUSTOM_TARGET_DEPS := kernel_build.phony

LX_DIR := $(call select_from_ports,linux)/src/linux
PWD    := $(shell pwd)

LX_MK_ARGS = ARCH=x86 CROSS_COMPILE=$(CROSS_DEV_PREFIX)

#
# Linux kernel configuration
#
# Start with 'make tinyconfig', enable/disable options via 'scripts/config',
# and resolve config dependencies via 'make olddefconfig'.
#

# define 'LX_ENABLE' and 'LX_DISABLE'
include $(REP_DIR)/src/pc_linux/target.inc

# filter for make output of kernel build system
BUILD_OUTPUT_FILTER = 2>&1 | sed "s/^/      [Linux]  /"

kernel_config.tag:
	$(MSG_CONFIG)Linux
	$(VERBOSE)$(MAKE) -C $(LX_DIR) O=$(PWD) $(LX_MK_ARGS) tinyconfig $(BUILD_OUTPUT_FILTER)
	$(VERBOSE)$(LX_DIR)/scripts/config --file $(PWD)/.config $(addprefix --enable ,$(LX_ENABLE))
	$(VERBOSE)$(LX_DIR)/scripts/config --file $(PWD)/.config $(addprefix --disable ,$(LX_DISABLE))
	$(VERBOSE)$(MAKE) $(LX_MK_ARGS) olddefconfig $(BUILD_OUTPUT_FILTER)
	$(VERBOSE)touch $@

# update Linux kernel config on makefile changes
kernel_config.tag: $(MAKEFILE_LIST)

kernel_build.phony: kernel_config.tag
	$(MSG_BUILD)Linux
	$(VERBOSE)$(MAKE) $(LX_MK_ARGS) bzImage $(BUILD_OUTPUT_FILTER)
