#!/bin/bash

set -e

# Decompile with Apktool (decode resources + classes)
wget -q https://github.com/iBotPeaches/Apktool/releases/download/v2.11.0/apktool_2.11.0.jar -O apktool.jar
java -jar apktool.jar d iceraven.apk -o iceraven-patched  # -s flag removed
rm -rf iceraven-patched/META-INF

# Color patching (legacy XML views - toolbar/webview chrome)
sed -i 's/<color name="fx_mobile_surface">.*/<color name="fx_mobile_surface">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_background">.*/<color name="fx_mobile_background">#ff000000<\/color>/g' iceraven-patched/res/values-night/colors.xml
sed -i 's/<color name="fx_mobile_layer_color_2">.*/<color name="fx_mobile_layer_color_2">@color\/photonDarkGrey90<\/color>/g' iceraven-patched/res/values-night/colors.xml

# Smali patching - PhotonColors (DarkGrey90 #15141A -> black)
sed -i 's/ff15141a/ff000000/g' iceraven-patched/smali_classes*/mozilla/components/ui/colors/PhotonColors.smali

# Smali patching - NovaColors (the NEW dark surfaces -> black)
NC=iceraven-patched/smali_classes*/mozilla/components/ui/colors/NovaColors.smali
sed -i 's/ff312f33/ff000000/g' $NC   # Gray65  (surfaceBright/surfaceContainerHighest/surfaceVariant)
sed -i 's/ff252428/ff000000/g' $NC   # Gray70  (surfaceContainerHigh)
sed -i 's/ff1d1b1f/ff000000/g' $NC   # Gray75  (surfaceContainer)
sed -i 's/ff171519/ff000000/g' $NC   # Gray80  (surfaceContainerLow/surfaceDim)
sed -i 's/ff131215/ff000000/g' $NC   # Gray85  (surfaceContainerLowest/surfaceDim)

# Smali patching - M3 dark defaults (Background/Surface/SurfaceDim all = Neutral6 -> black)
sed -i 's#sget-wide v0, Landroidx/compose/material3/tokens/PaletteTokens;->Neutral6:J#const-wide v0, 0xff000000L#' iceraven-patched/smali_classes*/androidx/compose/material3/tokens/ColorDarkTokens.smali

# Recompile the APK
java -jar apktool.jar b iceraven-patched -o iceraven-patched.apk --use-aapt2

# Align and sign the APK
zipalign 4 iceraven-patched.apk iceraven-patched-signed.apk

# Clean up
rm -rf iceraven-patched iceraven-patch ed.apk
