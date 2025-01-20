# pikul_two

PROJ=msdf-atlas-gen

include config.mk

#echo $@ : $(@F) : $< : $^
define cc-bin-command
	$(CC) -std=c2x -c -o $@ -DNDEBUG -O0 $(CFLAGS) $(INCS) $< -Imsdfgen
endef
define cc-dbg-command
	$(CC) -std=c2x -c -o $@ -DDEBUG -g -O0 $(CFLAGS) $(INCS) $< -Imsdfgen
endef
define cxx-bin-command
	$(CXX) -std=c++23 -c -o $@ -DNDEBUG -O0 $(CXXFLAGS) $(INCS) $< -Imsdfgen
endef
define cxx-dbg-command
	$(CXX) -std=c++23 -c -o $@ -DDEBUG -g -O0 $(CXXFLAGS) $(INCS) $< -Imsdfgen
endef

DIR_OBJ=obj
DIR_BIN=bin
DIR_DBG=dbg

SRC = \
	msdf-atlas-gen/Charset.cpp \
	msdf-atlas-gen/FontGeometry.cpp \
	msdf-atlas-gen/GlyphGeometry.cpp \
	msdf-atlas-gen/GridAtlasPacker.cpp \
	msdf-atlas-gen/Padding.cpp \
	msdf-atlas-gen/RectanglePacker.cpp \
	msdf-atlas-gen/TightAtlasPacker.cpp \
	msdf-atlas-gen/Workload.cpp \
	msdf-atlas-gen/bitmap-blit.cpp \
	msdf-atlas-gen/charset-parser.cpp \
	msdf-atlas-gen/glyph-generators.cpp \
	msdf-atlas-gen/image-encode.cpp \
	msdf-atlas-gen/shadron-preview-generator.cpp \
	msdf-atlas-gen/size-selectors.cpp \
	msdf-atlas-gen/utf8.cpp \

#	msdf-atlas-gen/csv-export.cpp \
#	msdf-atlas-gen/json-export.cpp \
#	msdf-atlas-gen/artery-font-export.cpp \
#	msdf-atlas-gen/main.cpp \

SRC_C           = $(filter %.c,$(SRC))
SRC_CXX         = $(filter %.cpp,$(SRC))
OBJ             = $(SRC_C:%.c=%.o)
SOBJ            = $(SRC_C:%.c=%.so)
CXXOBJ          = $(SRC_CXX:%.cpp=%.o)
CXXSOBJ         = $(SRC_CXX:%.cpp=%.so)
TMP_OUT_OBJ     = $(notdir $(OBJ))
TMP_OUT_SOBJ    = $(notdir $(SOBJ))
TMP_OUT_CXXOBJ  = $(notdir $(CXXOBJ))
TMP_OUT_CXXSOBJ = $(notdir $(CXXSOBJ))
OUT_OBJ         = $(TMP_OUT_OBJ:%.o=$(DIR_OBJ)/%.o)
OUT_SOBJ        = $(TMP_OUT_SOBJ:%.so=$(DIR_OBJ)/%.so)
OUT_CXXOBJ      = $(TMP_OUT_CXXOBJ:%.o=$(DIR_OBJ)/%.o)
OUT_CXXSOBJ     = $(TMP_OUT_CXXSOBJ:%.so=$(DIR_OBJ)/%.so)

.PHONY: default
default: options $(DIR_BIN)/msdf-atlas-gen.a ;

.PHONY: default-dbg
default-dbg: options $(DIR_DBG)/msdf-atlas-gen.a ;

.PHONY: prepare
prepare:
	mkdir -p $(DIR_BIN) $(DIR_DBG) $(DIR_OBJ)

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

$(SRC_C): config.h config.mk
$(SRC_CXX): config.h config.mk

$(DIR_OBJ)/%.o : msdf-atlas-gen/%.c
	$(cc-bin-command)
$(DIR_OBJ)/%.so : msdf-atlas-gen/%.c
	$(cc-dbg-command)

$(DIR_OBJ)/%.o : msdf-atlas-gen/%.cpp
	$(cxx-bin-command)
$(DIR_OBJ)/%.so : msdf-atlas-gen/%.cpp
	$(cxx-dbg-command)

$(DIR_BIN)/msdf-atlas-gen.a: prepare .WAIT $(OUT_OBJ) $(OUT_CXXOBJ)
$(DIR_BIN)/msdf-atlas-gen.a:
	ar rc $@ $(filter %.o,$^)
	ranlib $@

$(DIR_DBG)/msdf-atlas-gen.a: prepare .WAIT $(OUT_SOBJ) $(OUT_CXXSOBJ)
$(DIR_DBG)/msdf-atlas-gen.a:
	ar rc $@ $(filter %.so,$^)
	ranlib $@

.PHONY: print
print:
	@echo $(DST_SHADERS)

.PHONY: clean
clean:
	rm -rf .cache
	rm -f *.o *.so *.plist config.h
	rm -rf $(DIR_BIN) $(DIR_OBJ) $(DIR_DBG)
