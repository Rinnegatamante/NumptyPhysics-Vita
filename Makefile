TARGET := NumptyPhysics
TITLE := NUMPTY001
OBJS   = src/Canvas.o \
		 src/CanvasSoft.o \
		 src/EditOverlay.o \
		 src/Game.o \
		 src/Image.o \
		 src/Levels.o \
		 src/main.o \
		 src/NextLevelOverlay.o \
		 src/Overlay.o \
		 src/Path.o \
		 src/PauseOverlay.o \
		 src/Scene.o \
		 src/SDL_Lite.o \
		 src/Segment.o \
		 src/Stroke.o \
		 src/Window.o \

INCLUDES   = Include
BOX2D_SOURCES := $(wildcard Source/Common/*.cpp Source/Collision/*.cpp Source/Dynamics/*.cpp Source/Dynamics/Contacts/*.cpp Source/Dynamics/Joints/*.cpp)
BOX2D_OBJS := $(patsubst Source/%.cpp,.build/box2d/%.o,$(BOX2D_SOURCES))
OBJS += $(BOX2D_OBJS)
LIBS = -lvita2d -lSceLibKernel_stub -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lSceCtrl_stub -lSceAppMgr_stub \
	-lSceCommonDialog_stub -lm -lc  -lSceNet_stub -lSceNetCtl_stub  -lSceTouch_stub

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
CXX    := $(PREFIX)-g++
CXXFLAGS += -fno-lto -g -Wl,-q -O3 -std=c++11 -Wno-narrowing -I$(INCLUDES)

all: $(TARGET).vpk

.build/box2d/%.o: Source/%.cpp
	@mkdir -p $(@D)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(TARGET).vpk: $(TARGET).velf
	vita-make-fself -s $< builder/eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE) $(TARGET) builder/sce_sys/param.sfo
	cp -f builder/sce_sys/param.sfo param.sfo
	cp -f builder/eboot.bin eboot.bin
	vita-pack-vpk -s builder/sce_sys/param.sfo -b builder/eboot.bin \
		--add builder/sce_sys/icon0.png=sce_sys/icon0.png \
		--add builder/sce_sys/livearea=sce_sys/livearea $@

%.velf: %.elf
	cp $< $<.unstripped.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf $(TARGET).velf $(TARGET).elf $(OBJS)
