ifneq ($(PROCURSUS),1)
$(error Use the main Makefile)
endif

STRAPPROJECTS += sed
DOWNLOAD      += https://ftpmirror.gnu.org/sed/sed-$(SED_VERSION).tar.xz{,.sig}
SED_VERSION   := 4.8
DEB_SED_V     ?= $(SED_VERSION)

sed-setup: setup
	$(call PGP_VERIFY,sed-$(SED_VERSION).tar.xz)
	$(call EXTRACT_TAR,sed-$(SED_VERSION).tar.xz,sed-$(SED_VERSION),sed)

ifneq ($(wildcard $(BUILD_WORK)/sed/.build_complete),)
sed:
	@echo "Using previously built sed."
else
sed: sed-setup gettext
	cd $(BUILD_WORK)/sed && ./configure -C \
		--host=$(GNU_HOST_TRIPLE) \
		--prefix=/usr \
		--disable-dependency-tracking
	+$(MAKE) -C $(BUILD_WORK)/sed
	+$(MAKE) -C $(BUILD_WORK)/sed install \
		DESTDIR=$(BUILD_STAGE)/sed
	touch $(BUILD_WORK)/sed/.build_complete
endif

sed-package: sed-stage
	# sed.mk Package Structure
	rm -rf $(BUILD_DIST)/sed
	mkdir -p $(BUILD_DIST)/sed
	
	# sed.mk Prep sed
	cp -a $(BUILD_STAGE)/sed/usr $(BUILD_DIST)/sed
	
	# sed.mk Sign
	$(call SIGN,sed,general.xml)
	
	# sed.mk Make .debs
	$(call PACK,sed,DEB_SED_V)
	
	# sed.mk Build cleanup
	rm -rf $(BUILD_DIST)/sed

.PHONY: sed sed-package
