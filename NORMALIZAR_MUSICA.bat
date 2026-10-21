@echo off
REM =====================================================================
REM  NORMALIZADOR DE MUSICA DEL SERVER (Music Director 1.3.0)
REM  Pone TODAS las canciones al mismo volumen: -10 LUFS integrado,
REM  true peak -1.0 dB (sin clipping), 44.1 kHz estereo, LAME V0.
REM  Es el MISMO objetivo con el que viene la musica de la entrega del
REM  finale: una vez que pases toda tu libreria por aqui, ninguna
REM  cancion sonara mas baja que otra.
REM
REM  REQUIERE: ffmpeg.exe y ffprobe.exe AL LADO DE ESTE .bat
REM  Descarga (Windows, zip "release essentials"):
REM    https://www.gyan.dev/ffmpeg/builds/
REM  (dentro del zip, carpeta bin: copia los 2 .exe junto al .bat)
REM
REM  COMO SE USA:
REM   1) Copia este .bat + ffmpeg.exe + ffprobe.exe a una carpeta nueva
REM   2) Copia dentro los .mp3 a equilibrar (p. ej. TODO el contenido de
REM      sound/mobius/musica del server)
REM   3) Doble clic al .bat. Se crea la carpeta "salida" con los mp3
REM      renombrados con sufijo _EQ (el sufijo es IMPORTANTE: los
REM      clientes que ya tenian el archivo viejo con el nombre antiguo
REM      no lo vuelven a descargar; con el nombre nuevo SI lo bajan)
REM      y el archivo "lineas_para_las_listas.txt" con las lineas TAG-
REM      ya medidas para pegar en las listas del server.
REM   4) Sube los mp3 de "salida" al server y reemplaza en las listas
REM      (music_mapstart / tank_wave_sounds / tank_finale_sounds) las
REM      lineas viejas por las _EQ que imprime el script.
REM
REM  AVISO: si un mp3 ya viene CLIPPEADO (distorsionado de fabrica) el
REM  script no puede "des-clippearlo" (eso es danio de fuente), pero si
REM  lo deja al mismo volumen que el resto y sin sumar mas clipping.
REM =====================================================================
setlocal enabledelayedexpansion
cd /d "%~dp0"
if not exist ffmpeg.exe (
    echo FALTA ffmpeg.exe al lado de este .bat. Mira el encabezado del script.
    pause
    goto :eof
)
if not exist ffprobe.exe (
    echo FALTA ffprobe.exe al lado de este .bat. Mira el encabezado del script.
    pause
    goto :eof
)
if not exist salida mkdir salida
if exist lineas_para_las_listas.txt del lineas_para_las_listas.txt
set /a total=0
for %%F in (*.mp3) do (
    echo Normalizando: %%~nF
    ffmpeg -hide_banner -loglevel error -y -i "%%F" -af "loudnorm=I=-10:TP=-1:LRA=11" -ar 44100 -codec:a libmp3lame -q:a 0 "salida\%%~nF_EQ.mp3"
    set "rawdur="
    for /f "delims=" %%D in ('ffprobe -v error -show_entries format^=duration -of csv^=p^=0 "salida\%%~nF_EQ.mp3"') do set "rawdur=%%D"
    set "dur="
    if defined rawdur set "dur=!rawdur:~0,-7!"
    if not defined dur set "dur=0"
    if "!dur!"=="0" set /a dur=0
    >> lineas_para_las_listas.txt echo mobius/musica/%%~nF_EQ.mp3 TAG- %%~nF - !dur!
    set /a total+=1
)
echo.
echo Listo: !total! mp3 normalizados en "salida" (sufijo _EQ, mismos -10 LUFS).
echo Pega las lineas de lineas_para_las_listas.txt en tus listas del server.
pause
