#
# Makefile for the kernel mmc device drivers.
#

subdir-ccflags-$(CONFIG_MMC_DEBUG) := 

obj-$(CONFIG_MMC)		+= core/
obj-$(CONFIG_MMC)		+= card/
obj-$(subst m,y,$(CONFIG_MMC))	+= host/
