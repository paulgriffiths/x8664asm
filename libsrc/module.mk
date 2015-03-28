LOCAL_DIR  := libsrc
LOCAL_LIB  := $(LIBDIR)/libpgasm.a
LOCAL_SRC  := $(wildcard $(LOCAL_DIR)/*.asm)
LOCAL_OBJ  := $(subst .asm,.o,$(LOCAL_SRC))
LOCAL_LIST := $(subst .asm,.lst,$(LOCAL_SRC))

$(LOCAL_LIB): $(LOCAL_OBJ)
	@$(AR) $(ARFLAGS) $@ $^

LIBRARIES  += $(LOCAL_LIB)
OBJECTS	   += $(LOCAL_OBJ)
LISTFILES  += $(LOCAL_LIST)
