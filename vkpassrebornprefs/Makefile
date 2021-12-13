TARGET := iphone:clang:latest:14.4

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = VKPassRebornPrefs

SYSROOT = $(THEOS)/sdks/iPhoneOS14.4.sdk

VKPassRebornPrefs_PRIVATE_FRAMEWORKS = Preferences
VKPassRebornPrefs_FILES = $(shell find Sources/VKPassRebornPrefs -name '*.swift') $(shell find Sources/VKPassRebornPrefsC -name '*.m' -o -name '*.c' -o -name '*.mm' -o -name '*.cpp')
VKPassRebornPrefs_INSTALL_PATH = /Library/PreferenceBundles
VKPassRebornPrefs_SWIFTFLAGS = -ISources/VKPassRebornPrefsC/include
VKPassRebornPrefs_CFLAGS = -fobjc-arc
ADDITIONAL_OBJCFLAGS = -Wno-error

include $(THEOS_MAKE_PATH)/bundle.mk
