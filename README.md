# Howto

Kleines Howto zur Erzeugung des Mac-Wörterbuches.

## Vorbemerkungen

Die Umwandlung geschieht in zwei Schritten.

* Transformation der Wadoku.de-XML-Daten in das Xml-Format des Mac-Wörterbuches.
* Erzeugung des Mac-Wörterbuches aus den transformierten Daten.

Für den ersten Schritt wird ein XSLT-Prozessor, der XSLT 2.0 beherrscht, gebraucht.

Für den zweiten Schritt wird das *Dictionary Development Kit* benötigt,
welches im Paket ``Auxiliary Tools for Xcode``[1](https://developer.apple.com/downloads/index.action),
seit macOS 10.12 (Xcode 8.x) im Paket ``Additional Tools for Xcode``[2](http://adcdownload.apple.com/Developer_Tools/Additional_Tools_for_Xcode_8/Additional_Tools_for_Xcode_8_beta.dmg)
enthalten ist. Das gesamte Xcode-Paket wird hierfür nicht benötigt.
Vor Xcode 4.3 lag es im Verzeichnis ``/Developer/Extras/Dictionary Development Kit``.

Das erzeugte Wörterbuch ist kompatibel mit OS X ab 10.5 (Leopard).
Mit einer der folgenden Optionen lässt sich ein mit OS X 10.6 bzw. 10.11
(und aufwärts) kompatibles Wörterbuch erzeugen.
Die letzteren sind im Allgemeinen stärker komprimiert und nehmen damit weniger Platz 
auf der Festplatte ein.

Im Makefile:
```
DICT_BUILD_OPTS = -v 10.6
DICT_BUILD_OPTS = -v 10.11
```

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

## Troubleshooting

### Löschen der Einstellungen und Neustart der Dictionary.app

Für ```de.wadoku.dictionary.mac``` ist der Wert des ```CFBundleIdentifier``` aus der ```Info.plist``` zu verwenden.
```
/usr/libexec/PlistBuddy -c "Delete :com.apple.DictionaryServices:DCSDictionaryPrefs:de.wadoku.dictionary.mac" ~/Library/Preferences/.GlobalPreferences.plist
```

Seit macOS 10.12 existiert eine eigene Voreinstellungsdatei in ```~/Library/Preferences/com.apple.DictionaryServices.plist```, welche zu löschen ist.

## Referenzen

[Dictionary Services Programming Guide](http://developer.apple.com/library/mac/#documentation/UserExperience/Conceptual/DictionaryServicesProgGuide/Introduction/Introduction.html)
