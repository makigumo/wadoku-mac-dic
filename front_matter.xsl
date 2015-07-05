<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
                xmlns:wd="http://www.wadoku.de/xml/entry"
                xmlns="http://www.w3.org/1999/xhtml"
                exclude-result-prefixes="d">
    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="no"/>

    <xsl:template name="front">
        <d:entry id="wadoku_front_matter" d:title="Wadoku Info">
            <h1 xml:lang="de">Wadoku - Japanisch-Deutsches Wörterbuch für Mac</h1>
            <h1 xml:lang="ja">Mac用和独辞典</h1>
            <h3 xml:lang="de">Über diese Wörterbuch</h3>
            <h3 xml:lang="ja">本辞典について</h3>
            <p xml:lang="de">
                Dieses Wörterbuch wurde aus dem XML-Datensatz
                <xsl:if test="/entries[@date] and string(@date) castable as xs:date">
                    <xsl:text>(vom </xsl:text>
                    <xsl:value-of select="format-dateTime(/entries/@date, '[D1o] [MNn] [Y0001]','de','AD','DE')"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                des <a href="http://www.wadoku.de/">Wadoku-Online-Wörterbuches</a>
                erstellt.
            </p>
            <p xml:lang="ja">
                本辞典は<a href="http://www.wadoku.de/">オンライン和独辞典</a>のXMLデータ
                <xsl:if test="/entries[@date] and string(@date) castable as xs:date">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="format-dateTime(/entries/@date, '[Y0001]年[M01]月[D01]日')"/>
                    <xsl:text>より)</xsl:text>
                </xsl:if>
                を変換したものです。
            </p>
            <h3 xml:lang="de">Anhang</h3>
            <h3 xml:lang="ja">付録</h3>
            <ol>
                <li xml:lang="de"><a href="x-dictionary:r:wadoku_appendix_image">Illustrationen</a></li>
                <li xml:lang="ja"><a href="x-dictionary:r:wadoku_appendix_image">イラストレーション</a></li>
                <li xml:lang="de"><a href="x-dictionary:r:wadoku_appendix_seasonwords">Jahreszeitenwörter</a></li>
                <li xml:lang="ja"><a href="x-dictionary:r:wadoku_appendix_seasonwords">季語</a></li>
            </ol>
            <h3 xml:lang="de">Statistik</h3>
            <h3 xml:lang="ja">統計</h3>
            <table style="width: 100%">
                <tbody>
                    <tr>
                        <th xml:lang="de">Datensätze</th>
                        <th xml:lang="ja">レコード数</th>
                        <td><xsl:value-of select="count(wd:entry)"/></td>
                    </tr>
                    <tr>
                        <th xml:lang="de">Schreibungen</th>
                        <th xml:lang="ja">表記数</th>
                        <td><xsl:value-of select="count(wd:entry//wd:orth[not(@type='midashigo')])"/></td>
                    </tr>
                    <tr>
                        <th xml:lang="de">Bedeutungen</th>
                        <th xml:lang="ja">意味数</th>
                        <td><xsl:value-of select="count(wd:entry//wd:sense)"/></td>
                    </tr>
                    <tr>
                        <th xml:lang="de">Übersetzungen</th>
                        <th xml:lang="ja">翻訳項目数</th>
                        <td><xsl:value-of select="count(wd:entry//wd:trans)"/></td>
                    </tr>
                </tbody>
            </table>
            <h3 xml:lang="de">Lizenz</h3>
            <h3 xml:lang="ja">ライセンス</h3>
            <p>
                <a href="http://www.wadoku.de/wiki/x/ZQE">http://www.wadoku.de/wiki/x/ZQE</a>
            </p>
            <h3 xml:lang="de">Ressourcen</h3>
            <h3 xml:lang="ja">資源</h3>
            <dl>
                <dt xml:lang="de">XML-Dump</dt>
                <dt xml:lang="ja">XMLデータ</dt>
                <dd><a href="http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links">http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links</a></dd>
                <dt xml:lang="de">Transformations-Skript, CSS usw.</dt>
                <dt xml:lang="ja">変換スクリプトやCSSスタイルシートなど</dt>
                <dd><a href="https://github.com/makigumo/wadoku-mac-dic">https://github.com/makigumo/wadoku-mac-dic</a></dd>
            </dl>
        </d:entry>
    </xsl:template>


</xsl:stylesheet>
