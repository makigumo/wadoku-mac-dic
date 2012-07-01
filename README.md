# Howto

Kleines Howto zur Erzeugung des Mac-Wörterbuches.

## Vorbemerkungen

Das erzeugte Wörterbuch ist kompatibel mit OS X 10.5 (Leopard).
Folgende Option erzeugt ein mit OS X 10.6 kompatibles Wörterbuch,
dieses ist im Allgemeinen stärker komprimiert und nimmt damit
weniger Platz auf der Festplatte ein.
Im Makefile:
```
DICT_BUILD_OPTS = -v 10.6
```

Es wird das Dictionary Development Kit benötigt:, welches bei installiertem Xcode
in ``/Developer/Extras/Dictionary Development Kit`` liegt.
Beim App-Store-Download von Xcode 4.3 ist es im Extra-Paket
``Auxiliary Tools for Xcode``[1](https://developer.apple.com/downloads/index.action).

## Dateien

### entry_export_macdic.xslt

Transformationsskript zur Umwandlung der XML-Daten in das XML-Format
des Mac Dictionary Development Kit.

### Wadoku.css

CSS-Datei zur Formatierung der Einträge im Wörterbuch.

* Pfad muss im Makefile angegeben werden.

### lang_pref.xslt

Transformationsskript zur Umsetzung der Voreinstellungen.

* Muss in OtherResources liegen.

### Resources

Verzeichnis mit HTML-Dateien für die Voreinstellungselemente.

* Verzeichnis muss in OtherResources liegen.

## plist-Einträge

```xml
    <key>DCSDictionaryFrontMatterReferenceID</key>
    <string>wadoku_front_matter</string>
	<key>DCSDictionaryDefaultPrefs</key>
	<dict>
	    <key>lang</key>
        <string>0</string>
        <key>version</key>
        <string>1</string>
        <key>show_uid</key>
        <string/>
        <key>show_genera</key>
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

## Referenzen

[Dictionary Services Programming Guide](http://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/Introduction/Introduction.html)
