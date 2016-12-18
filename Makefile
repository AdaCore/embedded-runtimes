sfp = $(wildcard ravenscar-*/sfp)
full = $(wildcard ravenscar-*/full)

ROOT = $(shell dirname $(shell dirname $(shell which arm-eabi-gcc)))
INSTALL = $(ROOT)/arm-eabi/lib/gnat

all:
	for d in $(sfp); do \
	  echo $$d; \
	  cd $$d/..; \
	  gprbuild -P ravenscar_build.gpr -XRTS=ravenscar-sfp -j0; \
	  echo \* > sfp/obj/.gitignore; \
          echo \* > sfp/adalib/.gitignore; \
	  git add -f sfp/obj/.gitignore; \
          git add -f sfp/adalib/.gitignore; \
	  cd ..; \
	done
	@for d in $(full); do \
	  echo $$d; \
	  cd $$d/..; \
	  gprbuild -P ravenscar_build.gpr -XRTS=ravenscar-full -j0; \
	  echo \* > full/obj/.gitignore; \
          echo \* > full/adalib/.gitignore; \
	  git add -f full/obj/.gitignore; \
          git add -f full/adalib/.gitignore; \
	  cd ..; \
	done

install: all
	@cp -r bsps $(INSTALL)/bsps
	@cp -r base_runtimes $(INSTALL)/base_runtimes
	@for d in $(sfp) $(full); do \
	   variant=$$(basename $$d); \
	   base=$$(basename $$(dirname $$d) | sed -e 's/ravenscar/ravenscar-'$$variant'/'); \
	   dest="$(INSTALL)/$$base"; \
	   echo "Installing $$d in $$dest"; \
	   if [ -d $$dest ]; then rm -rf $$dest; fi; \
	   cp -r $$d $$dest; \
	   cat $$dest/runtime.xml | sed -e 's,../bsps,bsps,g' > tmp; \
	   mv tmp $$dest/runtime.xml; \
	   cat $$dest/ada_source_path | sed -e 's,../bsps,bsps,g' -e 's,../base_runtimes,base_runtimes,g' > tmp; \
	   mv tmp $$dest/ada_source_path; \
        done

clean:
	for d in $(sfp); do \
	  echo $$d; \
	  rm -rf $$d/obj/*; \
          rm -rf $$d/adalib/*; \
	done
	for d in $(full); do \
	  echo $$d; \
	  rm -rf $$d/obj/*; \
          rm -rf $$d/adalib/*; \
	done
