# Building the FFmpegKitNext library

## Android

Building for ARM v7a and ARM v7a Neon is disabled due to build errors related to the `libjxl` library

```bash
ANDROID_SDK_ROOT=/run/media/linesofcodes/PenguinData/Android ANDROID_NDK_ROOT=/run/media/linesofcodes/PenguinData/Android/ndk/29.0.14206865 ./nix-android.sh -p . --disable-arch-arm-v7a --disable-arch-arm-v7a-neon --enable-gpl --enable-lib-android-media-codec --enable-lib-android-zlib --enable-lib-chromaprint --enable-lib-dav1d --enable-lib-fontconfig --enable-lib-freetype --enable-lib-fribidi --enable-lib-gmp --enable-lib-harfbuzz --enable-lib-kvazaar --enable-lib-lame --enable-lib-libaom --enable-lib-libass --enable-lib-libjxl --enable-lib-liblc3 --enable-lib-libsvtav1 --enable-lib-libiconv --enable-lib-libilbc --enable-lib-libtheora --enable-lib-libvorbis --enable-lib-libvpx --enable-lib-libwebp --enable-lib-libxml2 --enable-lib-opencore-amr --enable-lib-openssl --enable-lib-opus --enable-lib-sdl --enable-lib-shine --enable-lib-snappy --enable-lib-soxr --enable-lib-speex --enable-lib-srt --enable-lib-tesseract --enable-lib-twolame --enable-lib-vo-amrwbenc --enable-lib-zimg --enable-lib-libvidstab --enable-lib-rubberband --enable-lib-x264 --enable-lib-x265
```

> [!NOTE]
> Make Java 21 the default on your system

## Linux

In `flake.nix`, Modify the `linuxToolchainPackages` and add the following extra packages:

```nix
      linuxToolchainPackages = pkgs: with pkgs; commonToolPackages pkgs ++ [
        ...
        srt
        lame
        opencore-amr
        snappy
        soxr
        speex
        libtheora
        twolame
        libv4l
        vid-stab
        vo-amrwbenc
        libvpx
        x265
        opencl-headers
        ocl-icd
        SDL2
      ];
```

In `scripts/linux/ffmpeg.sh`, Modify `PKG_CONFIG_LIBDIR` to the following:

```bash
export PKG_CONFIG_LIBDIR="/nix/store/q0phjan2sz1cavhadg84dh5m4946jm9h-sdl2-compat-2.32.56-dev/lib/pkgconfig/:/nix/store/vw8wgjglgqgvrdvnylly9f9xcp5rqfjy-x265-4.1-dev/lib/pkgconfig/:/nix/store/209g6g7cxhj83hrasw1ns5hmyxq6n01y-vid.stab-unstable-2022-05-30/lib/pkgconfig/:/nix/store/0jck6cnks8j0mjyr39llq5zplvsass6a-v4l-utils-1.24.1-dev/lib/pkgconfig/:/nix/store/xipwgwmj4lv0i7nx95ndnsra2wfmpjhy-speex-1.2.1-dev/lib/pkgconfig/:$(get_linux_pkg_config_libdir)"
```

Finally, Build it:

```bash
./nix-linux.sh -p default --enable-gpl --enable-lib-linux-alsa --enable-lib-chromaprint --enable-lib-dav1d --enable-lib-linux-fontconfig --enable-lib-linux-freetype --enable-lib-linux-fribidi --enable-lib-linux-gmp --enable-lib-linux-harfbuzz --enable-lib-kvazaar --enable-lib-linux-lame --enable-lib-libaom --enable-lib-linux-libass --enable-lib-libjxl --enable-lib-liblc3 --enable-lib-libsvtav1 --enable-lib-linux-libiconv --enable-lib-libilbc --enable-lib-linux-libtheora --enable-lib-linux-libvorbis --enable-lib-linux-libvpx --enable-lib-linux-libwebp --enable-lib-linux-libxml2 --enable-lib-linux-opencl --enable-lib-linux-opencore-amr --enable-lib-openssl --enable-lib-linux-opus --enable-lib-linux-sdl --enable-lib-linux-snappy --enable-lib-linux-soxr --enable-lib-linux-speex --enable-lib-srt --enable-lib-linux-tesseract --enable-lib-linux-twolame --enable-lib-linux-vaapi --enable-lib-linux-v4l2 --enable-lib-linux-vo-amrwbenc --enable-lib-linux-zlib --enable-lib-vvenc --enable-lib-zimg --enable-lib-linux-libvidstab --enable-lib-linux-rubberband --enable-lib-x264 --enable-lib-linux-x265
```
