# Howto

Kleines Howto zur Erzeugung des Mac-Wörterbuches.

## Vorbemerkungen

Die Umwandlung geschieht in zwei Schritten.

* Transformation der Wadoku.de-XML-Daten in das Xml-Format des Mac-Wörterbuches.
* Erzeugung des Mac-Wörterbuches aus den transformierten Daten.

Das erzeugte Wörterbuch ist kompatibel mit OS X ab 10.5 (Leopard).
Mit der folgenden Option lässt sich ein mit OS X 10.6 (und aufwärts)
kompatibles Wörterbuch erzeugen, dieses ist im Allgemeinen stärker
komprimiert und nimmt damit weniger Platz auf der Festplatte ein.
Im Makefile:
```
DICT_BUILD_OPTS = -v 10.6
```

Es wird das *Dictionary Development Kit* benötigt, welches vor Xcode 4.3
in ``/Developer/Extras/Dictionary Development Kit`` lag.
Seither ist es im Extra-Paket
``Auxiliary Tools for Xcode``[1](https://developer.apple.com/downloads/index.action).

## Dateien

### entry_export_macdic.xslt

Transformationsskript zur Umwandlung der XML-Daten in das XML-Format
des Mac Dictionary Development Kit.
Verwendet werden ebenfalls folgende Dateien:

* front_matter.xsl
* image_appendix.xsl
* seasonword_appendix.xsl
* gramgrp.xsl

### Wadoku.css

CSS-Datei zur Formatierung der Einträge im Wörterbuch.

* Pfad muss als ``CSS_SRC_PATH`` bzw. ``CSS_PATH`` im Makefile angegeben werden.

### lang_pref.xslt

Transformationsskript zur Umsetzung der Voreinstellungen.

* Muss im Verzeichnis ``OtherResources`` liegen.
* Pfad muss als ``PREF_XSLT_SRC_PATH`` im Makefile angegeben werden.

### Resources

Verzeichnis mit HTML-Dateien für die Voreinstellungselemente.

* Muss im Verzeichnis ``OtherResources`` liegen.

## plist-Einträge

```xml
    <key>DCSDictionaryFrontMatterReferenceID</key>
    <string>wadoku_front_matter</string>
    <key>DCSDictionaryDefaultPrefs</key>
    <dict>
        <key>display-lang</key>
        <string>ja</string>
        <key>version</key>
        <string>1</string>
        <key>display-uid</key>
        <string>0</string>
        <key>display-genera</key>
        <string>1</string>
        <key>display-ruby</key>
        <string>0</string>
        <key>display-short</key>
        <string>1</string>
    </dict>
    <key>DCSDictionaryPrefsHTML</key>
    <string>prefs.xhtml</string>
    <key>DCSDictionaryXSL</key>
    <string>lang_pref.xslt</string>
```

## Änderungen in build_dict.sh

```diff
diff --git a/bin/build_dict.sh b/bin/build_dict.sh
index 369d708..c354215 100755
--- a/bin/build_dict.sh
+++ b/bin/build_dict.sh
@@ -8,7 +8,7 @@ DICT_BUILD_TOOL_DIR=${DICT_BUILD_TOOL_DIR:-"/Developer/Extras/Dictionary Develop
 DICT_BUILD_TOOL_BIN="$DICT_BUILD_TOOL_DIR/bin"

 do_add_supplementary_key=1
-preserve_unused_ref_id_in_reference_index=0
+preserve_unused_ref_id_in_reference_index=1

 COMPRESS_OPT=
 COMPRESS_SETTING=0
```

## Troubleshooting

### Löschen der Einstellungen und Neustart der Dictionary.app

Für ```de.wadoku.dictionary.mac``` ist der Wert des ```CFBundleIdentifier``` aus der ```Info.plist``` zu verwenden.
```
/usr/libexec/PlistBuddy -c "Delete :com.apple.DictionaryServices:DCSDictionaryPrefs:de.wadoku.dictionary.mac" ~/Library/Preferences/.GlobalPreferences.plist
```

## Referenzen

[Dictionary Services Programming Guide](http://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/Introduction/Introduction.html)
