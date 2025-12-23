@echo off
echo Checking project for errors...
"C:\Godot\Godot_v4.4.1-stable_win64.exe" --headless --path "%CD%" --quit 2>&1 | findstr /v "Godot Engine"
echo Checking individual GDScript files...
for %%f in (src\*.gd) do (
    echo Checking %%f
    "C:\Godot\Godot_v4.4.1-stable_win64.exe" --headless --check-only --script "%%f" 2>&1 | findstr /v "Godot Engine"
)
echo Done.