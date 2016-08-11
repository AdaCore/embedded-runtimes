sfp = $(wildcard ravenscar-*/sfp)
full = $(wildcard ravenscar-*/full)

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
	for d in $(full); do \
	  echo $$d; \
	  cd $$d/..; \
	  gprbuild -P ravenscar_build.gpr -XRTS=ravenscar-full -j0; \
	  echo \* > full/obj/.gitignore; \
          echo \* > full/adalib/.gitignore; \
	  git add -f full/obj/.gitignore; \
          git add -f full/adalib/.gitignore; \
	  cd ..; \
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
