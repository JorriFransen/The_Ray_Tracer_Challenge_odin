ODIN=odin

ODINFLAGS := -debug

default: test

all: raytracer odin_test custom_test putting_it_together_CH01

debug: raytracer

release: ODINFLAGS := ${ODINFLAGS:N-debug}
release: raytracer

raytracer: builddir
	$(ODIN) build src -out:build/raytracer.bin $(ODINFLAGS)

run: raytracer
	build/raytracer.bin


putting_it_together_CH01: builddir
	$(ODIN) build src/putting_it_together_CH01 -out:build/putting_it_together_CH01.bin $(ODINFLAGS) && build/putting_it_together_CH01.bin

test: custom_test

odin_test: builddir
	$(ODIN) test tests $(ODINFLAGS)

custom_test: builddir
	$(ODIN) build tests -out:build/tests.bin $(ODINFLAGS)
	build/tests.bin


builddir:
	mkdir -p build

clean:
	rm -rf build

