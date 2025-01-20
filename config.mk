# paths
PREFIX = /usr/local
MANPREFIX = $(PREFIX)/share/man

# exes
PKG_CONFIG = pkg-config

# includes and libs
USED_LIBS = \

INCS = `$(PKG_CONFIG) --cflags $(USED_LIBS)`

LIBS = -lm -lpthread `$(PKG_CONFIG) --libs $(USED_LIBS)`

# flags
SHARED_FLAGS = -D_DEFAULT_SOURCE \
	-D_POSIX_C_SOURCE=200809L \
	-Wall \
	-Wextra \
	-pedantic \

#	-fPIC \
#	-pthread \

CFLAGS   += $(SHARED_FLAGS)
CXXFLAGS += $(SHARED_FLAGS)
CPPFLAGS = $(SHARED_FLAGS)
LDFLAGS  = $(LIBS)

# compiler & linker
CC  = /usr/bin/gcc
CXX = /usr/bin/g++
