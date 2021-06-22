# Howto

Kleines Howto zur Erzeugung des Mac-Wörterbuches.

## Vorbemerkungen

Die Umwandlung geschieht in zwei Schritten.

* Transformation der Wadoku.de-XML-Daten in das XML-Format für Apples *Dictionary Development Kit*.
* Erzeugung des Mac-Wörterbuches aus den transformierten Daten.

Für den ersten Schritt wird ein XSLT-Prozessor, der XSLT 2.0 beherrscht, gebraucht.

Für den zweiten Schritt wird das *Dictionary Development Kit* benötigt.
Dieses findet sich derzeit im Paket ``Additional Tools for Xcode``[2](https://developer.apple.com/download/all/?q=Additional).
Das gesamte Xcode-Paket ist hierfür nicht notwendig.

Im Makefile kann die mindestens benötigte OS X/macOS-Versionen spezifiziert werden.
* (default) 10.5 (Leopard)
 `DICT_BUILD_OPTS = -v 10.5`
* 10.6 (Snow Leopard)
 `DICT_BUILD_OPTS = -v 10.6`
* 10.11 (El Capitan)
 `DICT_BUILD_OPTS = -v 10.11`
 
Höhere Versionen haben den Vorteil, die Wörterbuchdaten im Allgemeinen stärker zu komprimieren
und somit weniger Platz auf der Festplatte zu beanspruchen.

## Dateien

### `xsl/entry_export_macdic.xsl`

Hauptskript zur Umwandlung der XML-Daten in das XML-Format
des Mac Dictionary Development Kit.
Verwendet werden ebenfalls folgende Dateien:

* `front_matter.xsl`
* `image_appendix.xsl`
* `seasonword_appendix.xsl`
* `gramgrp.xsl`

### `Wadoku.css`

CSS-Datei zur Formatierung der Einträge im Wörterbuch.

* Pfad muss als ``CSS_SRC_PATH`` bzw. ``CSS_PATH`` im Makefile angegeben werden.

### `OtherResources/lang_pref.xslt`

Transformationsskript zur Umsetzung der Voreinstellungen.

### OtherResources/Resources

Verzeichnis mit HTML-Dateien für die Voreinstellungselemente.

## Troubleshooting

### Löschen der Einstellungen und Neustart der Dictionary.app

Für ```de.wadoku.dictionary.mac``` ist der Wert des ```CFBundleIdentifier``` aus der ```Info.plist``` zu verwenden.
```
/usr/libexec/PlistBuddy -c "Delete :com.apple.DictionaryServices:DCSDictionaryPrefs:de.wadoku.dictionary.mac" ~/Library/Preferences/.GlobalPreferences.plist
```

Seit macOS 10.12 existiert eine eigene Voreinstellungsdatei in ```~/Library/Preferences/com.apple.DictionaryServices.plist```, welche zu löschen ist.

## Referenzen

[Dictionary Services Programming Guide](http://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/Introduction/Introduction.html)
