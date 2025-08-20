# msdf-atlas-gen

PROJ=msdf-atlas-gen

# Automatically set BUILD_MODE if target path hints at it
ifeq (,$(BUILD_MODE))
 ifneq (,$(findstring .sa,$(MAKECMDGOALS)))
  BUILD_MODE := debug
 else ifneq (,$(findstring .rsa,$(MAKECMDGOALS)))
  BUILD_MODE := release-debug
 else ifneq (,$(findstring .a,$(MAKECMDGOALS)))
  BUILD_MODE := release
 endif
endif

include config.mk

DIR_OBJ               := obj
BUILD_MODE            ?= release

ifeq ($(BUILD_MODE),release)
 OBJ_EXT        := o
 LIB_EXT        := a
 OPT_FLAGS      ?= -O3 -s
else ifeq ($(BUILD_MODE),release-debug)
 OBJ_EXT        := rso
 LIB_EXT        := rsa
 OPT_FLAGS      ?= -O2 -g
else ifeq ($(BUILD_MODE),debug)
 OBJ_EXT        := so
 LIB_EXT        := sa
 OPT_FLAGS      ?= -O0 -g
else
 $(error Unknown build mode: $(BUILD_MODE))
endif

define cc-command
	$(CC) -std=c2x -c -o $@ -DNDEBUG $(OPT_FLAGS) $(CFLAGS) $(INCS) $< -Imsdfgen
endef
define cxx-command
	$(CXX) -std=c++23 -c -o $@ -DDEBUG $(OPT_FLAGS) $(CXXFLAGS) $(INCS) $< -Imsdfgen
endef

.PHONY: default
default: options $(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT) ;

.PHONY: prepare
prepare: config.mk
prepare:
	mkdir -p $(DIR_OBJ)

.PHONY: options
options: prepare .WAIT
	@echo "$(PROJ)" build options:
	@echo "CFLAGS   = $(CFLAGS)"
	@echo "CXXFLAGS = $(CXXFLAGS)"
	@echo "LDFLAGS  = $(LDFLAGS)"
	@echo "CC       = $(CC)"
	@echo "CXX      = $(CXX)"

config.h:
	cp config.def.h $@

%.h: ;

$(DIR_OBJ)/%.$(OBJ_EXT) : msdf-atlas-gen/%.c | prepare
	$(cc-command)

$(DIR_OBJ)/%.$(OBJ_EXT) : msdf-atlas-gen/%.cpp | prepare
	$(cxx-command)

#	msdf-atlas-gen/csv-export.cpp \
#	msdf-atlas-gen/json-export.cpp \
#	msdf-atlas-gen/artery-font-export.cpp \
#	msdf-atlas-gen/main.cpp \

$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/Charset.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/FontGeometry.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/GlyphGeometry.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/GridAtlasPacker.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/Padding.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/RectanglePacker.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/TightAtlasPacker.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/Workload.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/bitmap-blit.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/charset-parser.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/glyph-generators.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/image-encode.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/shadron-preview-generator.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/size-selectors.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT): $(DIR_OBJ)/utf8.$(OBJ_EXT)
$(DIR_OBJ)/libmsdf-atlas-gen.$(LIB_EXT):
	ar rc $@ $(filter %.$(OBJ_EXT),$^)
	ranlib $@

.PHONY: clean
clean:
	rm -rf .cache
	rm -f *.o *.so *.plist config.h
	rm -rf $(DIR_OBJ)
