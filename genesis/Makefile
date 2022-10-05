.PHONY: build
build: genesis

.PHONY: genesis
genesis: genesis-el genesis-cl

.PHONY: genesis-el
genesis-el:
	cd el; ./build_el.sh

.PHONY: genesis-cl
genesis-cl: genesis-el
	cd cl; ./build_cl.sh

.PHONY: clean
clean:
	rm -rf build
