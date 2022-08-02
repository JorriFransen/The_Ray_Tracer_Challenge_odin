ODIN=odin

ODINFLAGS := -debug
COLLECTION_FLAGS := -collection:raytracer=src

default: test

all: raytracer odin_test custom_test putting_it_together

debug: raytracer

release: ODINFLAGS := ${ODINFLAGS:N-debug}
release: raytracer

raytracer: builddir
	$(ODIN) build src -out:build/raytracer.bin $(ODINFLAGS)

run: raytracer
	build/raytracer.bin


putting_it_together: builddir
	$(ODIN) build src/putting_it_together -out:build/putting_it_together.bin $(COLLECTION_FLAGS) $(ODINFLAGS) && build/putting_it_together.bin

#feh images/putting_it_together_ch02.ppm --force-aliasing --fullscreen --auto-zoom

test: custom_test

odin_test: builddir
	$(ODIN) test tests $(COLLECTION_FLAGS) $(ODINFLAGS)

custom_test: builddir
	$(ODIN) build tests -out:build/tests.bin $(COLLECTION_FLAGS) $(ODINFLAGS)
	build/tests.bin $(ODINTEST_FLAGS)


builddir:
	mkdir -p build

clean:
	rm -rf build

