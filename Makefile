projects = $(wildcard ./bsps/*.gpr)

all:
	@for prj in $(projects); do \
	  tgt=$$(cat $$prj | grep Target | cut -d \" -f 2); \
	  if [ -f "$$(which $$tgt-gcc)" ]; then \
	    echo "Building $$(basename $$prj)"; \
	    gprbuild -P $$prj -p -j0 -q; \
	  else \
	    echo "Skipping $$(dirname $$prj): no compiler found for $$tgt"; \
	  fi; \
	done

install:
	@for prj in $(projects); do \
	  tgt=$$(cat $$prj | grep Target | cut -d \" -f 2); \
	  if [ -f "$$(which $$tgt-gcc)" ]; then \
	    root=$$(dirname $$(dirname $$(which $$tgt-gcc))); \
	    echo "Installing $$(basename $$prj) in $$root"; \
	    gprbuild -P $$prj -p -j0 -q; \
            gprinstall -P $$prj -p -f -q --prefix=$$root; \
	  else \
	    echo "Skipping $$(basename $$prj): no compiler found for $$tgt"; \
	  fi; \
	done
