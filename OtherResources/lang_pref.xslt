<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        version="1.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">

    <xsl:output method="xml" encoding="UTF-8" indent="no"
                doctype-public="-//W3C//DTD XHTML 1.1//EN"
                doctype-system="http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd"/>
    <xsl:param name="display-debug">false</xsl:param>
    <xsl:param name="displaylang">0</xsl:param>
    <xsl:param name="display-uid">0</xsl:param>
    <xsl:param name="display-genera">1</xsl:param>
    <xsl:param name="display-ruby">0</xsl:param>
    <xsl:param name="display-short">1</xsl:param>

    <xsl:template match="body">
        <xsl:copy>
            <xsl:attribute name="lang">
                <xsl:choose>
                    <xsl:when test="$displaylang = '0'">
                        <xsl:text>ja</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>de</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:attribute>
            <xsl:if test="$display-debug = 'true'">
                <div class="debug">
                    <div>
                        display-short:
                        <xsl:value-of select="$display-short"/>
                    </div>
                    <div>
                        display-uid:
                        <xsl:value-of select="$display-uid"/>
                    </div>
                    <div>
                        display-ruby:
                        <xsl:value-of select="$display-ruby"/>
                    </div>
                    <div>
                        display-genera:
                        <xsl:value-of select="$display-genera"/>
                    </div>
                    <div>
                        displaylang:
                        <xsl:value-of select="$displaylang"/>
                    </div>
                </div>
            </xsl:if>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="div[@class='uid']">
        <xsl:if test="$display-uid = '1'">
            <xsl:element name="a">
                <xsl:attribute name="class">uid</xsl:attribute>
                <xsl:attribute name="href">https://www.wadoku.de/entry/view/<xsl:value-of select="."/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </xsl:element>
        </xsl:if>
    </xsl:template>

    <xsl:template match="span[@class='genus']">
        <xsl:if test="$display-genera = '1'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="rt">
        <xsl:if test="$display-ruby = '1'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ruby[not(@class)]">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="ruby[@class='short']">
        <xsl:if test="$display-short = '1'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ruby[@class='long']">
        <xsl:if test="$display-short = '0'">
            <xsl:copy>
                <xsl:apply-templates select="@*|node()"/>
            </xsl:copy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="@*|node()">
        <xsl:copy>
            <xsl:apply-templates select="@*|node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>