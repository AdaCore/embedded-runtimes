rts = $(wildcard ravenscar-*)

all:
	for d in $(rts); do \
	  echo $$d; \
	  cd $$d; \
	  gprbuild -P ravenscar_build.gpr -j0; \
	  echo * > obj/.gitignore; \
          echo * > adalib/.gitignore; \
	  cd ..; \
	done

clean:
	for d in $(rts); do \
	  echo $$d; \
	  rm -rf $$d/obj/*; \
          rm -rf $$d/adalib/*; \
	done
