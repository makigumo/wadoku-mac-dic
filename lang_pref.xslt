<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">

    <xsl:output method="xml" encoding="UTF-8" indent="no"
                doctype-public="-//W3C//DTD XHTML 1.1//EN"
                doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd" />
    <xsl:param name="lang">0</xsl:param>
    <xsl:param name="show_uid-yes">0</xsl:param>

    <xsl:template match="*[@d:pr='ja']">
        <xsl:if test="$lang = '0'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[@d:pr='de']">
        <xsl:if test="$lang = '1'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()" />
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="*[@d:pr='show_uid']">
        <xsl:if test="$show_uid-yes = '1'">
            <xsl:element name="a">
                <xsl:attribute name="class">uid</xsl:attribute>
                <xsl:attribute name="href">http://www.wadoku.de/wadoku/entry/view/<xsl:value-of
                        select="."/></xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()" />
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>