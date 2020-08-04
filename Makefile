#
#
#

VERSION=v2.4

LIPO=lipo
IPHONEOS_TARGETS=iphoneos-arm64 iphoneos-arm64e iphonesimulator-x86_64
APPLETVOS_TARGETS=appletvos-arm64 appletvsimulator-x86_64
TARGETS=$(IPHONEOS_TARGETS) $(APPLETVOS_TARGETS)
LIBRTMP_PREFIX=librtmp
IPHONEOS_LIB=$(LIBRTMP_PREFIX)-iphoneos.a
APPLETVOS_LIB=$(LIBRTMP_PREFIX)-appletvos.a

MAKETARGETS=all clean

.PHONY: $(MAKETARGETS) $(TARGETS)

all: Makefiles $(TARGETS) $(IPHONEOS_LIB) $(APPLETVOS_LIB)

clean: $(TARGETS)
	@for t in $(TARGETS); \
	do \
		rm -rf $$t ;\
	done
	@rm -rf $(IPHONEOS_LIB) $(APPLETVOS_LIB)

$(TARGETS):
	@if [ -d $@ ]; then \
		echo "===> Entering $@ for $(MAKECMDGOALS)" ;\
		$(MAKE) -C $@ $(MAKECMDGOALS) ;\
	fi

$(IPHONEOS_LIB): $(foreach v,$(IPHONEOS_TARGETS),$(shell echo $v/librtmp-$v.a))
	@$(LIPO) -create $(foreach v,$(IPHONEOS_TARGETS),$(shell echo $v/librtmp-$v.a)) -o $(IPHONEOS_LIB)

$(APPLETVOS_LIB): $(foreach v,$(APPLETVOS_TARGETS),$(shell echo $v/librtmp-$v.a))
	@$(LIPO) -create $(foreach v,$(APPLETVOS_TARGETS),$(shell echo $v/librtmp-$v.a)) -o $(APPLETVOS_LIB)

Makefiles: Makefile.tmpl
	@for t in $(TARGETS); \
	do \
		echo Creating $$t/Makefile; \
		mkdir -p $$t ;\
		rm -f $$t/Makefile; \
		cat $< | sed -e "s/@ARCH@/`echo $$t | sed -e 's/^[^-]*-//'`/" | sed -e "s/@PLATFORM@/`echo $$t | sed -e 's/-[^-]*$$//'`/" > $$t/Makefile ;\
	done
