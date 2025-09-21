# Assembly Project Makefile
# Supports both NASM and GCC assembly compilation with debug/release modes

# Directory structure
SRC_DIR := src
NASM_SRC_DIR := $(SRC_DIR)/nasm
GCC_SRC_DIR := $(SRC_DIR)/gcc
DEBUG_DIR := debug
RELEASE_DIR := release

# Create subdirectories
NASM_DEBUG_DIR := $(DEBUG_DIR)/nasm
NASM_RELEASE_DIR := $(RELEASE_DIR)/nasm
GCC_DEBUG_DIR := $(DEBUG_DIR)/gcc
GCC_RELEASE_DIR := $(RELEASE_DIR)/gcc

# Source files
NASM_SOURCES := $(wildcard $(NASM_SRC_DIR)/*.asm)
GAS_SOURCES := $(wildcard $(GCC_SRC_DIR)/*.s)

# Extract basenames for executables
NASM_BASENAMES := $(basename $(notdir $(NASM_SOURCES)))
GCC_BASENAMES := $(basename $(notdir $(GAS_SOURCES)))

# Object files
NASM_DEBUG_OBJS := $(addprefix $(NASM_DEBUG_DIR)/,$(addsuffix .o,$(NASM_BASENAMES)))
NASM_RELEASE_OBJS := $(addprefix $(NASM_RELEASE_DIR)/,$(addsuffix .o,$(NASM_BASENAMES)))
GCC_DEBUG_OBJS := $(addprefix $(GCC_DEBUG_DIR)/,$(addsuffix .o,$(GCC_BASENAMES)))
GCC_RELEASE_OBJS := $(addprefix $(GCC_RELEASE_DIR)/,$(addsuffix .o,$(GCC_BASENAMES)))

# Executable files
NASM_DEBUG_EXES := $(addprefix $(NASM_DEBUG_DIR)/,$(NASM_BASENAMES))
NASM_RELEASE_EXES := $(addprefix $(NASM_RELEASE_DIR)/,$(NASM_BASENAMES))
GCC_DEBUG_EXES := $(addprefix $(GCC_DEBUG_DIR)/,$(GCC_BASENAMES))
GCC_RELEASE_EXES := $(addprefix $(GCC_RELEASE_DIR)/,$(GCC_BASENAMES))

# Compiler settings
NASM := nasm
GCC := gcc
LD := ld

# NASM flags
NASM_DEBUG_FLAGS := -f elf64 -g -F dwarf
NASM_RELEASE_FLAGS := -f elf64

# GCC flags for assembly
GCC_DEBUG_FLAGS := -g -c
GCC_RELEASE_FLAGS := -c

# Linker flags
LD_DEBUG_FLAGS := -g
LD_RELEASE_FLAGS := -s

# Default target
.PHONY: all
all: help

# Help target
.PHONY: help
help:
	@echo "Assembly Project Build System"
	@echo "============================="
	@echo ""
	@echo "Available targets:"
	@echo "  nasm-debug      - Compile all NASM files in debug mode"
	@echo "  nasm-release    - Compile all NASM files in release mode"
	@echo "  gcc-debug       - Compile all GCC assembly files in debug mode"
	@echo "  gcc-release     - Compile all GCC assembly files in release mode"
	@echo "  all-debug       - Compile all files in debug mode"
	@echo "  all-release     - Compile all files in release mode"
	@echo "  clean           - Clean all build files"
	@echo "  dirs            - Create directory structure"
	@echo ""
	@echo "File naming conventions:"
	@echo "  src/nasm/*.asm files  - NASM assembly source files"
	@echo "  src/gcc/*.s files     - GCC assembly source files"
	@echo ""
	@echo "Examples:"
	@echo "  make nasm-debug"
	@echo "  make gcc-release"
	@echo "  make all-debug"

# Create directory structure
.PHONY: dirs
dirs:
	@mkdir -p $(NASM_SRC_DIR)
	@mkdir -p $(GCC_SRC_DIR)
	@mkdir -p $(NASM_DEBUG_DIR)
	@mkdir -p $(NASM_RELEASE_DIR)
	@mkdir -p $(GCC_DEBUG_DIR)
	@mkdir -p $(GCC_RELEASE_DIR)
	@echo "Directory structure created!"

# NASM targets
.PHONY: nasm-debug nasm-release
nasm-debug: dirs $(NASM_DEBUG_EXES)
nasm-release: dirs $(NASM_RELEASE_EXES)

# GCC targets
.PHONY: gcc-debug gcc-release
gcc-debug: dirs $(GCC_DEBUG_EXES)
gcc-release: dirs $(GCC_RELEASE_EXES)

# Combined targets
.PHONY: all-debug all-release
all-debug: nasm-debug gcc-debug
all-release: nasm-release gcc-release

# NASM compilation rules - compile .asm to .o
$(NASM_DEBUG_DIR)/%.o: $(NASM_SRC_DIR)/%.asm | dirs
	@echo "Compiling $< (NASM debug)..."
	$(NASM) $(NASM_DEBUG_FLAGS) -o $@ $<

$(NASM_RELEASE_DIR)/%.o: $(NASM_SRC_DIR)/%.asm | dirs
	@echo "Compiling $< (NASM release)..."
	$(NASM) $(NASM_RELEASE_FLAGS) -o $@ $<

# NASM linking rules - link .o to executable
$(NASM_DEBUG_DIR)/%: $(NASM_DEBUG_DIR)/%.o
	@echo "Linking $@ (NASM debug)..."
	$(LD) $(LD_DEBUG_FLAGS) -o $@ $<

$(NASM_RELEASE_DIR)/%: $(NASM_RELEASE_DIR)/%.o
	@echo "Linking $@ (NASM release)..."
	$(LD) $(LD_RELEASE_FLAGS) -o $@ $<

# GCC compilation rules - compile .s to .o
$(GCC_DEBUG_DIR)/%.o: $(GCC_SRC_DIR)/%.s | dirs
	@echo "Compiling $< (GCC debug)..."
	$(GCC) $(GCC_DEBUG_FLAGS) -o $@ $<

$(GCC_RELEASE_DIR)/%.o: $(GCC_SRC_DIR)/%.s | dirs
	@echo "Compiling $< (GCC release)..."
	$(GCC) $(GCC_RELEASE_FLAGS) -o $@ $<

# GCC linking rules - link .o to executable
$(GCC_DEBUG_DIR)/%: $(GCC_DEBUG_DIR)/%.o
	@echo "Linking $@ (GCC debug)..."
	$(GCC) $(LD_DEBUG_FLAGS) -o $@ $<

$(GCC_RELEASE_DIR)/%: $(GCC_RELEASE_DIR)/%.o
	@echo "Linking $@ (GCC release)..."
	$(GCC) $(LD_RELEASE_FLAGS) -o $@ $<

# Clean targets
.PHONY: clean clean-debug clean-release
clean: clean-debug clean-release
	@echo "All build files cleaned!"

clean-debug:
	@echo "Cleaning debug files..."
	@rm -rf $(DEBUG_DIR)

clean-release:
	@echo "Cleaning release files..."
	@rm -rf $(RELEASE_DIR)

# Individual file compilation (useful for testing single files)
.PHONY: compile-nasm-debug compile-nasm-release compile-gcc-debug compile-gcc-release

compile-nasm-debug:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-nasm-debug FILE=filename.asm"; exit 1; fi
	@make $(NASM_DEBUG_DIR)/$(basename $(FILE))

compile-nasm-release:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-nasm-release FILE=filename.asm"; exit 1; fi
	@make $(NASM_RELEASE_DIR)/$(basename $(FILE))

compile-gcc-debug:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-gcc-debug FILE=filename.s"; exit 1; fi
	@make $(GCC_DEBUG_DIR)/$(basename $(FILE))

compile-gcc-release:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-gcc-release FILE=filename.s"; exit 1; fi
	@make $(GCC_RELEASE_DIR)/$(basename $(FILE))

# Show project status
.PHONY: status debug-vars
status:
	@echo "Project Status:"
	@echo "==============="
	@echo "NASM source files: $(words $(NASM_SOURCES))"
	@for file in $(NASM_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "GCC assembly source files: $(words $(GAS_SOURCES))"
	@for file in $(GAS_SOURCES); do echo "  $$file"; done
	@echo ""
	@echo "NASM debug executables expected:"
	@for file in $(NASM_DEBUG_EXES); do echo "  $$file"; done
	@echo ""
	@echo "Directory structure:"
	@ls -la | grep "^d" || echo "  No directories found"

debug-vars:
	@echo "Debug Variables:"
	@echo "=================="
	@echo "NASM_SRC_DIR: $(NASM_SRC_DIR)"
	@echo "NASM_SOURCES: $(NASM_SOURCES)"
	@echo "NASM_BASENAMES: $(NASM_BASENAMES)"
	@echo "NASM_DEBUG_EXES: $(NASM_DEBUG_EXES)"
	@echo "NASM_DEBUG_OBJS: $(NASM_DEBUG_OBJS)"
