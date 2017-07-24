projects = $(wildcard ./bsps/*.gpr)

all:
	@for prj in $(projects); do \
	  tgt=$$(cat "$$prj" | grep Target | cut -d \" -f 2); \
	  if [ -f "$$(which $$tgt-gcc)" ]; then \
	    echo "Building $$(basename "$$prj")"; \
	    cmd="gprbuild -P "$$prj" -p -j0 -q"; \
	    echo "> $$cmd"; \
	    $$cmd; \
	  else \
	    echo "*** Skipping $$(basename "$$prj"):"; \
	    echo "    no compiler found for $$tgt"; \
	  fi; \
	done

clean:
	@for prj in $(projects); do \
	  tgt=$$(cat "$$prj" | grep Target | cut -d \" -f 2); \
	  if [ -f "$$(which $$tgt-gcc)" ]; then \
	    echo "Cleaning $$(basename "$$prj")"; \
	    cmd="gprclean -P "$$prj" -r -q"; \
	    echo "> $$cmd"; \
	    $$cmd; \
	  fi; \
	done

install:
	@for prj in $(projects); do \
	  tgt=$$(cat $$prj | grep Target | cut -d \" -f 2); \
	  if [ -f "$$(which $$tgt-gcc)" ]; then \
	    root=$$(dirname $$(dirname $$(which $$tgt-gcc))); \
	    echo "Installing $$(basename $$prj) in $$root"; \
	    cmd="gprbuild -P "$$prj" -p -j0 -q"; \
	    echo "> $$cmd"; \
	    $$cmd; \
            cmd="gprinstall -P $$prj -p --prefix="$$root" -q -f"; \
	    echo "> $$cmd"; \
	    $$cmd; \
	  else \
	    echo "Skipping $$(basename $$prj): no compiler found for $$tgt"; \
	  fi; \
	done
