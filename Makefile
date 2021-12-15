TARGET := iphone:clang:latest:12.2
INSTALL_TARGET_PROCESSES = VKClient
export THEOS_DEVICE_IP=192.168.31.8
#export THEOS_DEVICE_IP=10.1.1.176

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = VKPassReborn

VKPassReborn_FILES = $(shell find Sources/VKPassReborn -name '*.swift') $(shell find Sources/VKPassRebornC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
VKPassReborn_SWIFTFLAGS = -ISources/VKPassRebornC/include
VKPassReborn_CFLAGS = -fobjc-arc -ISources/VKPassRebornC/include

include $(THEOS_MAKE_PATH)/tweak.mk
include $(THEOS_MAKE_PATH)/aggregate.mk
