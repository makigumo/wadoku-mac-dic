<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
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
            <h1 xml:lang="de">WaDoku - Japanisch-Deutsches Wörterbuch für Mac</h1>
            <h1 xml:lang="ja">Mac用和独辞典</h1>
            <h2 xml:lang="de">Über</h2>
            <h2 xml:lang="ja">本辞典について</h2>
            <p xml:lang="de">
                Dieses Wörterbuch wurde aus dem XML-Datensatz
                <xsl:if test="count(entries/@date) > 0">
                    <xsl:text>(vom </xsl:text>
                    <xsl:value-of select="entries/@date"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                des <a href="http://www.wadoku.de/">WaDoku-Online-Wörterbuches</a>
                erstellt.
            </p>
            <p xml:lang="ja">
                本辞典は<a href="http://www.wadoku.de/">オンライン和独辞典</a>のXMLデータ
                <xsl:if test="count(entries/@date) > 0">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="entries/@date"/>
                    <xsl:text>より)</xsl:text>
                </xsl:if>
                を変換したものです。
            </p>
            <h2 xml:lang="de">Anhang</h2>
            <h2 xml:lang="ja">付録</h2>
            <ol>
                <li xml:lang="de"><a href="x-dictionary:r:wadoku_appendix_image">Illustrationen</a></li>
                <li xml:lang="ja"><a href="x-dictionary:r:wadoku_appendix_image">イラストレーション</a></li>
                <li xml:lang="de"><a href="x-dictionary:r:wadoku_appendix_seasonwords">Jahreszeitenwörter</a></li>
                <li xml:lang="ja"><a href="x-dictionary:r:wadoku_appendix_seasonwords">季語</a></li>
            </ol>
            <h2 xml:lang="de">Statistik</h2>
            <h2 xml:lang="ja">統計</h2>
            <table>
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
            <h2 xml:lang="de">Lizenz</h2>
            <h2 xml:lang="ja">ライセンス</h2>
            <p>
                <a href="http://www.wadoku.de/wiki/x/ZQE">http://www.wadoku.de/wiki/x/ZQE</a>
            </p>
            <h2 xml:lang="de">Ressourcen</h2>
            <h2 xml:lang="ja">リソース</h2>
            <p xml:lang="de">
                XML-Dump: <a href="http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links">http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links</a>
                Transformations-Skript, CSS usw.: <a href="https://gist.github.com/813338">https://gist.github.com/813338</a>
            </p>
            <p xml:lang="ja">
                XMLデータ:<a href="http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links">http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links</a>
                変換スクリプトやCSSスタイルシートなど: <a href="https://gist.github.com/813338">https://gist.github.com/813338</a>
            </p>
        </d:entry>
    </xsl:template>


</xsl:stylesheet>