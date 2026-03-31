TARGET = 
PREFIX = 
ARCH =

ifeq ($(TARGET),)
$(error Please set TARGET via command line or environment variables)
endif

ifeq ($(PREFIX),)
$(error Please set PREFIX via command line or environment variables)
endif

ifeq ($(ARCH),)
$(error Please set ARCH via command line or environment variables)
endif

.PHONY: default
default: all

.PHONY: all
all: xmrig/build/xmrig

xmrig/build/xmrig: xmrig/scripts/deps/lib/libhwloc.a xmrig/scripts/deps/lib/libuv.a xmrig/scripts/deps/lib/libcrypto.a xmrig/scripts/deps/lib/libssl.a .xmrig-patched
	env PATH=$(PREFIX)/bin:$(PATH) cmake -S xmrig -B xmrig/build -G Ninja \
		-DCMAKE_SYSTEM_NAME=Linux \
		-DCMAKE_SYSTEM_PROCESSOR=$(ARCH) \
		-DCMAKE_C_COMPILER=$(PREFIX)-cc \
		-DCMAKE_CXX_COMPILER=$(PREFIX)-c++ \
		-DCMAKE_FIND_ROOT_PATH_MODE_PROGRAM=NEVER \
		-DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=ONLY \
		-DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=ONLY \
		-DCMAKE_BUILD_TYPE=Release \
		-DXMRIG_DEPS=scripts/deps \
		-DBUILD_STATIC=ON \
		-DWITH_HWLOC=ON \
		-DWITH_TLS=ON \
		-DWITH_ADL=OFF \
		-DWITH_CN_FEMTO=OFF \
		-DWITH_CN_HEAVY=OFF \
		-DWITH_CN_LITE=OFF \
		-DWITH_CN_PICO=OFF \
		-DWITH_CUDA=OFF \
		-DWITH_GHOSTRIDER=OFF \
		-DWITH_KAWPOW=OFF \
		-DWITH_NVML=OFF \
		-DWITH_OPENCL=OFF \
		-DWITH_STRICT_CACHE=OFF \
		-DWITH_VAES=OFF \
		-DWITH_BENCHMARK=OFF
	make -C xmrig/build $(MAKEOPTS)

.xmrig-patched:
	patch -Np1 -i openssl-cross-fix.patch
	touch .xmrig-patched

xmrig/scripts/deps/lib/libcrypto.a: libressl/crypto/.libs/libcrypto.a
	mkdir -p xmrig/scripts/deps/include
	mkdir -p xmrig/scripts/deps/lib
	cp -a $< $@
	cp -f -r libressl/include xmrig/scripts/deps/

xmrig/scripts/deps/lib/libhwloc.a: hwloc/hwloc/.libs/libhwloc.a
	mkdir -p xmrig/scripts/deps/include
	mkdir -p xmrig/scripts/deps/lib
	cp -a $< $@
	cp -f -r hwloc/include xmrig/scripts/deps/

xmrig/scripts/deps/lib/libssl.a: libressl/ssl/.libs/libssl.a
	mkdir -p xmrig/scripts/deps/include
	mkdir -p xmrig/scripts/deps/lib
	cp -a $< $@

xmrig/scripts/deps/lib/libuv.a: libuv/.libs/libuv.a
	mkdir -p xmrig/scripts/deps/include
	mkdir -p xmrig/scripts/deps/lib
	cp -a $< $@
	cp -f -r libuv/include xmrig/scripts/deps/

hwloc/hwloc/.libs/libhwloc.a:
	env PATH=$(PREFIX)/bin:$(PATH) sh -c "cd hwloc && ./configure \
		--host=$(TARGET) \
		--enable-static \
		--disable-shared \
		--disable-io \
		--disable-libudev \
		--disable-libxml2 \
		--disable-cairo"
	env PATH=$(PREFIX)/bin:$(PATH) $(MAKE) -C hwloc $(MAKEOPTS)

libressl/ssl/.libs/libssl.a:
	env PATH=$(PREFIX)/bin:$(PATH) sh -c "cd libressl && ./configure \
		--host=$(TARGET) \
		--enable-static \
		--disable-shared"
	env PATH=$(PREFIX)/bin:$(PATH) $(MAKE) -C libressl $(MAKEOPTS)

libressl/crypto/.libs/libcrypto.a: libressl/ssl/.libs/libssl.a

libuv/.libs/libuv.a:
	env PATH=$(PREFIX)/bin:$(PATH) sh -c "cd libuv && ./configure \
		--host=$(TARGET) \
		--enable-static \
		--disable-shared"
	env PATH=$(PREFIX)/bin:$(PATH) $(MAKE) -C libuv $(MAKEOPTS)

.PHONY: clean
clean:
	$(MAKE) -C hwloc distclean
	$(MAKE) -C libressl distclean
	$(MAKE) -C libuv distclean
	rm -rf xmrig/build
	rm –rf xmrig/scripts/deps
