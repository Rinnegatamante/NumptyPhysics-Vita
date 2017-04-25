VITASDK=C:\vitasdk\arm-vita-eabi
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

INCLUDES   = include
LIBS = -lvita2d -lSceLibKernel_stub -lSceDisplay_stub -lSceGxm_stub \
	-lSceSysmodule_stub -lSceCtrl_stub \
	-lSceCommonDialog_stub -lm -lc -lbox2d -lSceNet_stub -lSceNetCtl_stub  -lSceTouch_stub

PREFIX  = arm-vita-eabi
CC      = $(PREFIX)-gcc
CXX    := $(PREFIX)-g++
CXXFLAGS += -fno-lto -g -Wl,-q -O3 -std=c++11 -Wno-narrowing -I$(INCLUDES) -L$(VITASDK)\lib

all: $(TARGET).vpk

$(TARGET).vpk: $(TARGET).velf
	vita-make-fself -s $< .\builder\eboot.bin
	vita-mksfoex -s TITLE_ID=$(TITLE) $(TARGET) param.sfo
	cp -f param.sfo ./builder/sce_sys/param.sfo
	cp -f ./builder/eboot.bin eboot.bin
	
	#------------ Comment this if you don't have 7zip ------------------
	7z a -tzip ./$(TARGET).vpk -r .\builder\sce_sys\* .\builder\eboot.bin 
	#-------------------------------------------------------------------

%.velf: %.elf
	cp $< $<.unstripped.elf
	$(PREFIX)-strip -g $<
	vita-elf-create $< $@

$(TARGET).elf: $(OBJS)
	$(CXX) $(CXXFLAGS) $^ $(LIBS) -o $@

clean:
	@rm -rf $(TARGET).velf $(TARGET).elf $(OBJS)