<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
                xmlns:wd="http://www.wadoku.de/xml/entry"
                exclude-result-prefixes="d">
    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="no"/>

    <xsl:template name="front">
        <d:entry id="wadoku_front_matter" d:title="Wadoku Info">
            <h1 d:pr="de">WaDoku - Japanisch-Deutsches Wörterbuch für Mac</h1>
            <h1 d:pr="ja">Mac用和独辞典</h1>
            <h2 d:pr="de">Über</h2>
            <h2 d:pr="ja">本辞典について</h2>
            <p d:pr="de">
                Dieses Wörterbuch wurde aus dem XML-Datensatz
                <xsl:if test="count(entries/@date) > 0">
                    <xsl:text>(vom </xsl:text>
                    <xsl:value-of select="entries/@date"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                des <a href="http://www.wadoku.de/">WaDoku-Online-Wörterbuches</a>
                erstellt.
            </p>
            <p d:pr="ja">
                <xsl:text>本辞典は</xsl:text>
                <a href="http://www.wadoku.de/">オンライン和独辞典</a>
                <xsl:text>のXMLデータ</xsl:text>
                <xsl:if test="count(entries/@date) > 0">
                    <xsl:text>(</xsl:text>
                    <xsl:value-of select="entries/@date"/>
                    <xsl:text>より)</xsl:text>
                </xsl:if>
                <xsl:text>を変換したものです。</xsl:text>
            </p>
            <h2 d:pr="de">Anhang</h2>
            <h2 d:pr="ja">付録</h2>
            <p>
                <ol>
                    <li><a d:pr="de" href="x-dictionary:r:wadoku_appendix_image">Illustrationen</a></li>
                    <li><a d:pr="ja" href="x-dictionary:r:wadoku_appendix_image">イラストレーション</a></li>
                </ol>
            </p>
            <h2 d:pr="de">Statistik</h2>
            <h2 d:pr="ja">統計</h2>
            <p>
                <table>
                    <tbody>
                        <tr>
                            <th d:pr="de">Datensätze</th>
                            <th d:pr="ja">レコード数</th>
                            <td><xsl:value-of select="count(wd:entry)"/></td>
                        </tr>
                        <tr>
                            <th d:pr="de">Schreibungen</th>
                            <th d:pr="ja">表記数</th>
                            <td><xsl:value-of select="count(wd:entry//wd:orth[not(@type='midashigo')])"/></td>
                        </tr>
                        <tr>
                            <th d:pr="de">Bedeutungen</th>
                            <th d:pr="ja">意味数</th>
                            <td><xsl:value-of select="count(wd:entry//wd:sense)"/></td>
                        </tr>
                        <tr>
                            <th d:pr="de">Übersetzungen</th>
                            <th d:pr="ja">翻訳項目数</th>
                            <td><xsl:value-of select="count(wd:entry//wd:trans)"/></td>
                        </tr>
                    </tbody>
                </table>
            </p>
            <h2 d:pr="de">Lizenz</h2>
            <h2 d:pr="ja">ライセンス</h2>
            <p>
                <a href="http://www.wadoku.de/wiki/x/ZQE">http://www.wadoku.de/wiki/x/ZQE</a>
            </p>
            <h2 d:pr="de">Ressourcen</h2>
            <h2 d:pr="ja">リソース</h2>
            <p>
                XML-Dump: <a href="http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links">http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links</a>
                Transformations-Skript und CSS: <a href="https://gist.github.com/813338">https://gist.github.com/813338</a>
            </p>
        </d:entry>
    </xsl:template>


</xsl:stylesheet>