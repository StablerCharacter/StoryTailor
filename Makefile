main:
	flutter build linux --release

clean:
	flutter clean

APPIMAGE_TOOL ?= appimagetool

appimage-resources:
	rm -rf AppDir
	mkdir -pv ./AppDir/opt/
	cp -r build/linux/x64/release/bundle/ ./AppDir/opt/storytailor
	cp ./meta/io.github.stablercharacter.storytailor.desktop ./AppDir/
	install -D ./meta/io.github.stablercharacter.storytailor.desktop ./AppDir/usr/share/applications/io.github.stablercharacter.storytailor.desktop
	install -D ./meta/io.github.stablercharacter.storytailor.appdata.xml ./AppDir/usr/share/metainfo/io.github.stablercharacter.storytailor.appdata.xml
	install -m 755 ./scripts/AppImage-RunApp.sh ./AppDir/AppRun
	cp ./assets/icon.png ./AppDir/storytailor.png

appimage: appimage-resources
	ARCH=x86_64 ${APPIMAGE_TOOL} -g AppDir

appimage-signed: appimage-resources
	ARCH=x86_64 ${APPIMAGE_TOOL} -g -s AppDir
