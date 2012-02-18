<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0"
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
            <h1 d:pr="de">Illustrationen (<xsl:value-of select="count(wd:entry[.//wd:link/@type='picture'])"/>)</h1>
            <h1 d:pr="ja">イラストレーション (<xsl:value-of select="count(wd:entry[.//wd:link/@type='picture'])"/>)</h1>
            <xsl:for-each select="wd:entry[.//wd:link/@type='picture']">
                <xsl:sort select=".//wd:link[@type='picture']/text()"/>
                <div class="">
                    <a href="x-dictionary:r:{@id}">
                        <xsl:value-of select=".//wd:link[@type='picture']/text()"/>
                    </a>
                    <xsl:text> | </xsl:text>
                    <xsl:call-template name="get_subentry_title"/>
                    <xsl:text> | </xsl:text>
                    <xsl:apply-templates mode="compact" select="./wd:sense"/>
                </div>
            </xsl:for-each>
        </d:entry>
    </xsl:template>

</xsl:stylesheet>