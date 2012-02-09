# Howto

Kleines Howto zur Erzeugung des Mac Dictionarys.

## Dateien

### entry_export_macdic.xslt

Transformationsskript zur Umwandlung der XML-Daten in das XML-Format
des Mac Dictionary Development Kit (/Developer/Extras/Dictionary Development Kit).

### Wadoku.css

CSS-Datei zur Formatierung der Einträge im Wörterbuch.

* Pfad muss im Makefile angegeben werden.

### lang_pref.xslt

Transformationsskript zur Umsetzung der Voreinstellungen.

* Muss in OtherResources liegen.

### Resources

Verzeichnis mit HTML-Dateien für die Voreinstellungselementen.

* Verzeichnis muss in OtherResources liegen.

## plist-Einträge

```xml
	<key>DCSDictionaryDefaultPrefs</key>
	<dict>
	    <key>lang</key>
        <string>0</string>
        <key>version</key>
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

http://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/Introduction/Introduction.html
