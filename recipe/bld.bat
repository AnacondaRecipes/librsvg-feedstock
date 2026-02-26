setlocal EnableDelayedExpansion
@echo on

FOR /F "delims=" %%i IN ('cygpath.exe -m "%LIBRARY_PREFIX%"') DO set "LIBRARY_PREFIX_M=%%i"

:: set pkg-config path so that host deps can be found
set "PKG_CONFIG_PATH=%LIBRARY_LIB%\pkgconfig;%LIBRARY_PREFIX%\share\pkgconfig"

:: set XDG_DATA_DIRS to find gir files
set "XDG_DATA_DIRS=%LIBRARY_PREFIX%\share"

mkdir forgebuild
cd forgebuild

meson setup ^
  --buildtype=release ^
  --prefix=%LIBRARY_PREFIX% ^
  --backend=ninja ^
  -Dintrospection=enabled ^
  -Dpixbuf=enabled ^
  -Dpixbuf-loader=enabled ^
  -Dcfextragirdir=%LIBRARY_PREFIX%\share\gir-1.0 ^
  -Ddocs=disabled ^
  -Dtests=false ^
  ..
if errorlevel 1 exit 1

ninja
if errorlevel 1 exit 1

ninja install
if errorlevel 1 exit 1

:: Copy libraries to be named consistently with the Autotools builds.
:: This way people can migrate to the new names, but we don't break
:: packages that still depend on the old ones.
copy %LIBRARY_BIN%\rsvg-2-2.dll %LIBRARY_BIN%\rsvg-2.0-vs%VS_MAJOR%.dll
if errorlevel 1 exit 1
copy %LIBRARY_LIB%\rsvg-2.lib %LIBRARY_LIB%\rsvg-2.0.lib
if errorlevel 1 exit 1

:: This may not be necessary? Haven't checked what gdk-pixbuf looks
:: for on Windows.
move %LIBRARY_LIB%\gdk-pixbuf-2.0\2.10.0\loaders\pixbufloader_svg.dll %LIBRARY_LIB%\gdk-pixbuf-2.0\2.10.0\loaders\libpixbufloader_svg.dll
if errorlevel 1 exit 1

rmdir /s /q %LIBRARY_PREFIX%\share\doc
