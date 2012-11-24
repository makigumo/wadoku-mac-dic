<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns="http://www.w3.org/1999/xhtml"
                xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
                xmlns:wd="http://www.wadoku.de/xml/entry"
                exclude-result-prefixes="d">
    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="no"/>

    <xsl:template name="image_appendix">
        <d:entry id="wadoku_appendix_image" d:title="Anhang: Bilder">
            <h1 xml:lang="de">Illustrationen (<xsl:value-of select="count(//wd:link[@type='picture'])"/>)</h1>
            <h1 xml:lang="ja">イラストレーション (<xsl:value-of select="count(//wd:link[@type='picture'])"/>)</h1>
            <dl>
                <xsl:for-each-group select="wd:entry"
                                    group-by=".//wd:link[@type='picture']/text()">
                    <xsl:sort select="current-grouping-key()"/>
                    <dt>
                        <xsl:value-of select="current-grouping-key()"/>
                    </dt>
                    <xsl:for-each select="current-group()">
                        <dd>
                            <a href="x-dictionary:r:{@id}">
                                <xsl:call-template name="get_subentry_title"/>
                            </a>
                            <xsl:text> | </xsl:text>
                            <xsl:apply-templates mode="compact" select="./wd:sense"/>
                        </dd>
                    </xsl:for-each>
                </xsl:for-each-group>
            </dl>
        </d:entry>
    </xsl:template>

</xsl:stylesheet>