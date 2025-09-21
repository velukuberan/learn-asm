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
NASM_RELEASE_FLAGS := -f elf64 -O2

# GCC flags for assembly
GCC_DEBUG_FLAGS := -g -gdwarf-4 -c
GCC_RELEASE_FLAGS := -O2 -c

# Linker flags
LD_DEBUG_FLAGS := -g
LD_RELEASE_FLAGS := -s --strip-all

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
	@echo "Single file compilation:"
	@echo "  compile-nasm-debug FILE=filename    - Compile specific NASM file (debug)"
	@echo "  compile-nasm-release FILE=filename  - Compile specific NASM file (release)"
	@echo "  compile-gcc-debug FILE=filename     - Compile specific GCC file (debug)"
	@echo "  compile-gcc-release FILE=filename   - Compile specific GCC file (release)"
	@echo ""
	@echo "Convenient shortcuts:"
	@echo "  make nasm FILE=filename [MODE=debug|release]  - Compile NASM file"
	@echo "  make gcc FILE=filename [MODE=debug|release]   - Compile GCC file"
	@echo "  make debug FILE=filename    - Auto-detect and compile in debug"
	@echo "  make release FILE=filename  - Auto-detect and compile in release"
	@echo "  make single FILE=path/file.asm [MODE=debug|release] - Full path"
	@echo ""
	@echo "File naming conventions:"
	@echo "  src/nasm/*.asm files  - NASM assembly source files"
	@echo "  src/gcc/*.s files     - GCC assembly source files"
	@echo ""
	@echo "Examples:"
	@echo "  make nasm-debug                    # Compile all NASM files"
	@echo "  make gcc-release                   # Compile all GCC files"
	@echo "  make all-debug                     # Compile everything"
	@echo ""
	@echo "Single file examples:"
	@echo "  make compile-nasm-debug FILE=hello_nasm"
	@echo "  make nasm FILE=hello_nasm MODE=release"
	@echo "  make debug FILE=calculator_nasm"
	@echo "  make single FILE=src/nasm/hello.asm"

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
.PHONY: nasm gcc debug release single

# Single file compilation with FILE parameter
compile-nasm-debug:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-nasm-debug FILE=filename"; echo "  (without .asm extension)"; exit 1; fi
	@if [ ! -f "$(NASM_SRC_DIR)/$(FILE).asm" ]; then echo "Error: $(NASM_SRC_DIR)/$(FILE).asm not found"; exit 1; fi
	@make dirs
	@make $(NASM_DEBUG_DIR)/$(FILE)
	@echo "Compiled: $(NASM_DEBUG_DIR)/$(FILE)"

compile-nasm-release:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-nasm-release FILE=filename"; echo "  (without .asm extension)"; exit 1; fi
	@if [ ! -f "$(NASM_SRC_DIR)/$(FILE).asm" ]; then echo "Error: $(NASM_SRC_DIR)/$(FILE).asm not found"; exit 1; fi
	@make dirs
	@make $(NASM_RELEASE_DIR)/$(FILE)
	@echo "Compiled: $(NASM_RELEASE_DIR)/$(FILE)"

compile-gcc-debug:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-gcc-debug FILE=filename"; echo "  (without .s extension)"; exit 1; fi
	@if [ ! -f "$(GCC_SRC_DIR)/$(FILE).s" ]; then echo "Error: $(GCC_SRC_DIR)/$(FILE).s not found"; exit 1; fi
	@make dirs
	@make $(GCC_DEBUG_DIR)/$(FILE)
	@echo "Compiled: $(GCC_DEBUG_DIR)/$(FILE)"

compile-gcc-release:
	@if [ -z "$(FILE)" ]; then echo "Usage: make compile-gcc-release FILE=filename"; echo "  (without .s extension)"; exit 1; fi
	@if [ ! -f "$(GCC_SRC_DIR)/$(FILE).s" ]; then echo "Error: $(GCC_SRC_DIR)/$(FILE).s not found"; exit 1; fi
	@make dirs
	@make $(GCC_RELEASE_DIR)/$(FILE)
	@echo "Compiled: $(GCC_RELEASE_DIR)/$(FILE)"

# Convenient aliases for single file compilation
# Usage: make nasm FILE=hello_nasm [MODE=debug|release]
# Usage: make gcc FILE=hello_gcc [MODE=debug|release]
nasm:
	@if [ -z "$(FILE)" ]; then echo "Usage: make nasm FILE=filename [MODE=debug|release]"; echo "  Default MODE is debug"; exit 1; fi
	@MODE=${MODE:-debug}; \
	if [ "$MODE" = "debug" ]; then \
		make compile-nasm-debug FILE=$(FILE); \
	elif [ "$MODE" = "release" ]; then \
		make compile-nasm-release FILE=$(FILE); \
	else \
		echo "Error: MODE must be 'debug' or 'release'"; exit 1; \
	fi

gcc:
	@if [ -z "$(FILE)" ]; then echo "Usage: make gcc FILE=filename [MODE=debug|release]"; echo "  Default MODE is debug"; exit 1; fi
	@MODE=${MODE:-debug}; \
	if [ "$MODE" = "debug" ]; then \
		make compile-gcc-debug FILE=$(FILE); \
	elif [ "$MODE" = "release" ]; then \
		make compile-gcc-release FILE=$(FILE); \
	else \
		echo "Error: MODE must be 'debug' or 'release'"; exit 1; \
	fi

# Single file compilation with automatic detection
# Usage: make debug FILE=filename (auto-detects if it's .asm or .s)
# Usage: make release FILE=filename (auto-detects if it's .asm or .s)
debug:
	@if [ -z "$(FILE)" ]; then echo "Usage: make debug FILE=filename"; echo "  (will auto-detect .asm or .s extension)"; exit 1; fi
	@if [ -f "$(NASM_SRC_DIR)/$(FILE).asm" ]; then \
		make compile-nasm-debug FILE=$(FILE); \
	elif [ -f "$(GCC_SRC_DIR)/$(FILE).s" ]; then \
		make compile-gcc-debug FILE=$(FILE); \
	else \
		echo "Error: Neither $(NASM_SRC_DIR)/$(FILE).asm nor $(GCC_SRC_DIR)/$(FILE).s found"; \
		exit 1; \
	fi

release:
	@if [ -z "$(FILE)" ]; then echo "Usage: make release FILE=filename"; echo "  (will auto-detect .asm or .s extension)"; exit 1; fi
	@if [ -f "$(NASM_SRC_DIR)/$(FILE).asm" ]; then \
		make compile-nasm-release FILE=$(FILE); \
	elif [ -f "$(GCC_SRC_DIR)/$(FILE).s" ]; then \
		make compile-gcc-release FILE=$(FILE); \
	else \
		echo "Error: Neither $(NASM_SRC_DIR)/$(FILE).asm nor $(GCC_SRC_DIR)/$(FILE).s found"; \
		exit 1; \
	fi

# Single file compilation with full path specification
# Usage: make single FILE=src/nasm/hello.asm [MODE=debug|release]
single:
	@if [ -z "$(FILE)" ]; then echo "Usage: make single FILE=path/to/file.asm|.s [MODE=debug|release]"; echo "  Default MODE is debug"; exit 1; fi
	@MODE=${MODE:-debug}; \
	BASENAME=$(basename $(FILE)); \
	FILENAME=${BASENAME%.*}; \
	EXT=${BASENAME##*.}; \
	if [ "$EXT" = "asm" ]; then \
		if [ "$MODE" = "debug" ]; then \
			make compile-nasm-debug FILE=$FILENAME; \
		else \
			make compile-nasm-release FILE=$FILENAME; \
		fi; \
	elif [ "$EXT" = "s" ]; then \
		if [ "$MODE" = "debug" ]; then \
			make compile-gcc-debug FILE=$FILENAME; \
		else \
			make compile-gcc-release FILE=$FILENAME; \
		fi; \
	else \
		echo "Error: File must have .asm or .s extension"; exit 1; \
	fi

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
