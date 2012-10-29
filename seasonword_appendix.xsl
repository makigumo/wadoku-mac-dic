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

    <xsl:template name="seasonword_appendix">
        <d:entry id="wadoku_appendix_seasonwords" d:title="Anhang: Jahreszeitenwörter">
            <h1 xml:lang="de">Jahreszeitenwörter (<xsl:value-of select="count(wd:entry[.//wd:sense/@season])"/>)</h1>
            <h1 xml:lang="ja">季語 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season])"/>)</h1>
            <dl>
                <dt xml:lang="de">Neujahr (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='newyear'])"/>)</dt>
                <dt xml:lang="ja">新年 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='newyear'])"/>)</dt>
                <xsl:for-each select="wd:entry[.//wd:sense/@season='newyear']">
                    <!-- sortiere nach Aussprache -->
                    <xsl:sort select=".//wd:pron[not(@type)]/wd:text/text()"/>
                    <dd>
                        <a href="x-dictionary:r:{@id}">
                            <xsl:call-template name="get_subentry_title"/>
                        </a>
                        <xsl:text> | </xsl:text>
                        <xsl:apply-templates mode="compact" select="./wd:sense"/>
                    </dd>
                </xsl:for-each>

                <dt xml:lang="de">Frühling (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='spring'])"/>)</dt>
                <dt xml:lang="ja">春 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='spring'])"/>)</dt>
                <xsl:for-each select="wd:entry[.//wd:sense/@season='spring']">
                    <!-- sortiere nach Aussprache -->
                    <xsl:sort select=".//wd:pron[not(@type)]/wd:text/text()"/>
                    <dd>
                        <a href="x-dictionary:r:{@id}">
                            <xsl:call-template name="get_subentry_title"/>
                        </a>
                        <xsl:text> | </xsl:text>
                        <xsl:apply-templates mode="compact" select="./wd:sense"/>
                    </dd>
                </xsl:for-each>

                <dt xml:lang="de">Sommer (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='summer'])"/>)</dt>
                <dt xml:lang="ja">夏 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='summer'])"/>)</dt>
                <xsl:for-each select="wd:entry[.//wd:sense/@season='summer']">
                    <!-- sortiere nach Aussprache -->
                    <xsl:sort select=".//wd:pron[not(@type)]/wd:text/text()"/>
                    <dd>
                        <a href="x-dictionary:r:{@id}">
                            <xsl:call-template name="get_subentry_title"/>
                        </a>
                        <xsl:text> | </xsl:text>
                        <xsl:apply-templates mode="compact" select="./wd:sense"/>
                    </dd>
                </xsl:for-each>

                <dt xml:lang="de">Herbst (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='autumn'])"/>)</dt>
                <dt xml:lang="ja">秋 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='autumn'])"/>)</dt>
                <xsl:for-each select="wd:entry[.//wd:sense/@season='autumn']">
                    <!-- sortiere nach Aussprache -->
                    <xsl:sort select=".//wd:pron[not(@type)]/wd:text/text()"/>
                    <dd>
                        <a href="x-dictionary:r:{@id}">
                            <xsl:call-template name="get_subentry_title"/>
                        </a>
                        <xsl:text> | </xsl:text>
                        <xsl:apply-templates mode="compact" select="./wd:sense"/>
                    </dd>
                </xsl:for-each>

                <dt xml:lang="de">Winter (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='winter'])"/>)</dt>
                <dt xml:lang="ja">冬 (<xsl:value-of select="count(wd:entry[.//wd:sense/@season='winter'])"/>)</dt>
                <xsl:for-each select="wd:entry[.//wd:sense/@season='winter']">
                    <!-- sortiere nach Aussprache -->
                    <xsl:sort select=".//wd:pron[not(@type)]/wd:text/text()"/>
                    <dd>
                        <a href="x-dictionary:r:{@id}">
                            <xsl:call-template name="get_subentry_title"/>
                        </a>
                        <xsl:text> | </xsl:text>
                        <xsl:apply-templates mode="compact" select="./wd:sense"/>
                    </dd>
                </xsl:for-each>
            </dl>
        </d:entry>
    </xsl:template>

</xsl:stylesheet>