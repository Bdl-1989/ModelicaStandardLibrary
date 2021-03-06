AR = ar -ru
RM = rm -f

CFLAGS = -O3 -Wno-attributes -fno-delete-null-pointer-checks
CPPFLAGS = -DNDEBUG -DHAVE_UNISTD_H -DHAVE_STDARG_H -DHAVE_HIDDEN -DHAVE_MEMCPY
INC = -I"../../C-Sources/zlib"

TARGETDIR = linux64

EXTC_OBJS = \
	ModelicaFFT.o \
	ModelicaInternal.o \
	ModelicaRandom.o \
	ModelicaStrings.o

TABLES_OBJS = \
	ModelicaStandardTables.o \
	ModelicaStandardTablesUsertab.o

MATIO_OBJS = \
	ModelicaMatIO.o \
	snprintf.o

IO_OBJS = \
	ModelicaIO.o

ZLIB_OBJS = \
	adler32.o \
	compress.o \
	crc32.o \
	deflate.o \
	gzclose.o \
	gzlib.o \
	gzread.o \
	gzwrite.o \
	infback.o \
	inffast.o \
	inflate.o \
	inftrees.o \
	trees.o \
	uncompr.o \
	zutil.o

ALL_OBJS = $(EXTC_OBJS) $(TABLES_OBJS) $(MATIO_OBJS) $(IO_OBJS) $(ZLIB_OBJS)

all: clean
	$(MAKE) libModelicaExternalC.a libModelicaStandardTables.a libModelicaIO.a libModelicaMatIO.a libzlib.a

libModelicaExternalC.a: $(EXTC_OBJS)
	$(AR) $@ $(EXTC_OBJS)
	cp $@ ../../Library/$(TARGETDIR)/$@

libModelicaStandardTables.a: $(TABLES_OBJS)
	$(AR) $@ $(TABLES_OBJS)
	cp $@ ../../Library/$(TARGETDIR)/$@

libModelicaMatIO.a: $(MATIO_OBJS)
	$(AR) $@ $(MATIO_OBJS)
	cp $@ ../../Library/$(TARGETDIR)/$@

libModelicaIO.a: $(IO_OBJS)
	$(AR) $@ $(IO_OBJS)
	cp $@ ../../Library/$(TARGETDIR)/$@

libzlib.a: $(ZLIB_OBJS)
	$(AR) $@ $(ZLIB_OBJS)
	cp $@ ../../Library/$(TARGETDIR)/$@

ModelicaStandardTables.o: ../../C-Sources/ModelicaStandardTables.c
	$(CC) $(CPPFLAGS) -DTABLE_SHARE=1 $(CFLAGS) $(INC) -c -o $@ $<

ModelicaStandardTablesUsertab.o: ../../C-Sources/ModelicaStandardTablesUsertab.c
	$(CC) $(CPPFLAGS) -DDUMMY_FUNCTION_USERTAB $(CFLAGS) $(INC) -c -o $@ $<

ModelicaMatIO.o: ../../C-Sources/ModelicaMatIO.c
	$(CC) $(CPPFLAGS) -DHAVE_ZLIB=1 $(CFLAGS) $(INC) -c -o $@ $<

snprintf.o: ../../C-Sources/snprintf.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

ModelicaIO.o: ../../C-Sources/ModelicaIO.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

ModelicaFFT.o: ../../C-Sources/ModelicaFFT.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

ModelicaInternal.o: ../../C-Sources/ModelicaInternal.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

ModelicaRandom.o: ../../C-Sources/ModelicaRandom.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

ModelicaStrings.o: ../../C-Sources/ModelicaStrings.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

%.o: ../../C-Sources/zlib/%.c
	$(CC) $(CPPFLAGS) $(CFLAGS) $(INC) -c -o $@ $<

clean:
	$(RM) $(ALL_OBJS)
	$(RM) *.a
	$(RM) ../../Library/$(TARGETDIR)/*.a
