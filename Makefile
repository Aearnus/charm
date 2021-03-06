LIB_OBJECT_FILES = Runner.o Stack.o PredefinedFunctions.o FunctionAnalyzer.o FFI.o Parser.o Lexer.o
OBJECT_FILES = main.o Prelude.charm.o $(LIB_OBJECT_FILES)
EMSCRIPTEN_OBJECT_FILES = CInterpretationCapsule.o Runner.o Stack.o PredefinedFunctions.o FunctionAnalyzer.o FFI.o Parser.o Prelude.charm.o

OUT_FILE ?= charm

LDLIBS += -ldl -lgmp

USE_READLINE ?= true
ifeq ($(USE_READLINE),true)
LDLIBS += -lreadline -lhistory
else
endif


ifeq ($(GUI),)
LDLIBS += -lreadline -lhistory
else
LDLIBS += -lreadline -lhistory -ltermcap -lncurses
CPPFLAGS += -DCHARM_GUI=1
OBJECT_FILES += gui.o
endif

# Include directories and library search paths
INCLUDEDIR ?=
LIBDIR ?=

# Compilation flags
DEBUG ?= false
OPTIMIZE_INLINE ?= true

DEFAULT_EXECUTABLE_LINE = $(CXX) -Wall -O3 --std=c++1z -DDEBUGMODE=$(DEBUG) -DOPTIMIZE_INLINE=$(OPTIMIZE_INLINE) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDEDIR) $(LIBDIR) $(LDFLAGS) -o $(OUT_FILE) $(LDLIBS)
DEFAULT_OBJECT_LINE = $(CXX) -c -Wall -O3 --std=c++1z -DDEBUGMODE=$(DEBUG) -DUSE_READLINE=$(USE_READLINE) -DOPTIMIZE_INLINE=$(OPTIMIZE_INLINE) $(CPPFLAGS) $(CXXFLAGS) $(INCLUDEDIR) $(LIBDIR) $(LDFLAGS)

release: $(OBJECT_FILES)
	$(DEFAULT_EXECUTABLE_LINE) $(OBJECT_FILES) $(LDLIBS)
emscripten-release: $(EMSCRIPTEN_OBJECT_FILES)
	$(DEFAULT_EXECUTABLE_LINE) $(EMSCRIPTEN_OBJECT_FILES) $(LDLIBS)
build-objects: $(OBJECT_FILES)
install:
	chmod +x charm
	cp charm /usr/local/bin/charm

ffi-lib: clean
	make ffi-build-objects CPPFLAGS=-fPIC
	ar rvs libcharmffi.a $(LIB_OBJECT_FILES)
ffi-build-objects: $(LIB_OBJECT_FILES)
install-lib:
	cp libcharmffi.a /usr/lib/
	-mkdir /usr/include/charm
	cp ParserTypes.h /usr/include/charm/
	cp Runner.h /usr/include/charm/
	cp Stack.h /usr/include/charm/
	cp PredefinedFunctions.h /usr/include/charm/
	cp FunctionAnalyzer.h /usr/include/charm/
	cp FFI.h /usr/include/charm/
	cp CharmFFI.hpp /usr/include/charm/

main.o: main.cpp
	$(DEFAULT_OBJECT_LINE) main.cpp
Parser.o: Parser.cpp
	$(DEFAULT_OBJECT_LINE) Parser.cpp
Runner.o: Runner.cpp
	$(DEFAULT_OBJECT_LINE) Runner.cpp
Stack.o: Stack.cpp
	$(DEFAULT_OBJECT_LINE) Stack.cpp
PredefinedFunctions.o: PredefinedFunctions.cpp
	$(DEFAULT_OBJECT_LINE) PredefinedFunctions.cpp
FunctionAnalyzer.o: FunctionAnalyzer.cpp
	$(DEFAULT_OBJECT_LINE) FunctionAnalyzer.cpp
Prelude.charm.o: Prelude.charm.cpp
	$(CXX) -c -Wall -O3 --std=c++1z Prelude.charm.cpp
gui.o: gui.cpp
	$(DEFAULT_OBJECT_LINE) gui.cpp
FFI.o: FFI.cpp
	$(DEFAULT_OBJECT_LINE) FFI.cpp
CInterpretationCapsule.o: CInterpretationCapsule.cpp
	$(DEFAULT_OBJECT_LINE) CInterpretationCapsule.cpp
Lexer.o: Lexer.cpp
	$(DEFAULT_OBJECT_LINE) Lexer.cpp

clean:
	-rm $(OBJECT_FILES)
	-rm CInterpretationCapsule.o
	-rm gui.o
	-rm libcharmffi.a
	-rm charm
	-rm charm-release
	-rm libhistory.o
	-rm libreadline.o
	-rm libtermcap.o
	-rm libtermcap.o
	-rm charm.html*
	-rm charm.js

reload-prelude:
	rm Prelude.charm.o
	make

.PHONY: release install ffi-lib install-lib clean reload-prelude ffi-build-objects
