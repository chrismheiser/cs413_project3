all:
	mkdir -p bin
	haxe -cp src \
	-swf-header 1280:720:60:FFFFFF \
	-swf-version 11.3 \
	-swf bin/Learn.swf \
	-swf-lib Starling.swc \
	--macro "patchTypes('starling.patch')" \
	-main com.learn.haxe.GameLoader

run:
	make
	cygstart bin/Learn.swf

runkill:
	taskkill /f /IM FlashPlayer16Debug.exe /fi "memusage gt 2"
	make run

clean:
	rm bin/Learn.swf
	mkdir -p bin