<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
        xmlns:wd="http://www.wadoku.de/xml/entry"
        exclude-result-prefixes="d"
        version="1.0">
    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="no"/>

    <!-- Parameter, der bestimmt, ob Untereinträge ihre eigenen Einträge erhalten,
         oder nur im Haupteintrag erscheinen, wenn = yes
    -->
    <xsl:param name="strictSubHeadIndex">no</xsl:param>

    <!-- lookup key für einträge mit referenzen auf einen Haupteintrag -->
    <xsl:key name="refs" match="wd:entry[./wd:ref[@type='main']]" use="./wd:ref/@id"/>

    <xsl:template match="entries">
        <d:dictionary xmlns="http://www.w3.org/1999/xhtml"
                      xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">
            <xsl:text>&#10;</xsl:text>

            <xsl:choose>
                <xsl:when test="$strictSubHeadIndex = 'yes'">
                    <!-- nur Einträge,
                      * die Untereinträge haben
                      * ohne Untereinträge und selbst kein Untereintrag sind
                      -->
                    <xsl:apply-templates select="wd:entry[count(./wd:ref[@type='main']) = 0 or count(key('refs',@id)) > 0]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="front"/>
        </d:dictionary>
    </xsl:template>

    <xsl:template name="front">
        <d:entry id="wadoku_front_matter" d:title="Wadoku Info">
            <d:index d:title="Wadoku Info" d:value="wadoku"/>
            <h1><b>Wadoku Mac Wörterbuch</b></h1>
            <h2>Über</h2>
            <p>
                Dieses Wörterbuch wurde aus dem XML-Datensatz
                <xsl:if test="count(entries/@date) > 0">
                    <xsl:text>(vom </xsl:text>
                    <xsl:value-of select="entries/@date"/>
                    <xsl:text>)</xsl:text>
                </xsl:if>
                des <a href="http://www.wadoku.de/">Wadoku-Online-Wörterbuches</a>
                erstellt.

            </p>
            <h2>Lizenz</h2>
            <p>
                <a href="http://www.wadoku.de/wiki/x/ZQE">http://www.wadoku.de/wiki/x/ZQE</a>
            </p>
            <h2>Ressourcen</h2>
            <p>
                XML-Dump: <a href="http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links">http://www.wadoku.de/wiki/display/WAD/Downloads+und+Links</a>
                Transformations-Skript und CSS: <a href="https://gist.github.com/813338">https://gist.github.com/813338</a>
            </p>
        </d:entry>
    </xsl:template>

    <xsl:template match="wd:entry">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="count(./wd:form/wd:orth[@midashigo]) != 0">
                    <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@midashigo]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                        <xsl:apply-templates mode="simple"
                                             select="./wd:form/wd:orth[not(@irr) and not(@midashigo)]"/>
                    </xsl:if>
                    <xsl:if test="./wd:form/wd:orth[@irr]">
                        <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@irr]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="yomi">
            <xsl:apply-templates select="./wd:form/wd:pron[not(@type)]"/>
        </xsl:variable>
        <d:entry id="{@id}" d:title="{$title}">
            <!-- index -->
            <d:index d:value="{$yomi}" d:title="{$title}" d:yomi="{$yomi}"/>
            <xsl:apply-templates select="./wd:form/wd:orth[not(@midashigo='true') and . != $yomi]">
                <xsl:with-param name="yomi" select="$yomi"/>
            </xsl:apply-templates>
            <!-- Index für Untereinträge -->
            <xsl:if test="$strictSubHeadIndex = 'yes'">
                <xsl:apply-templates mode="subheadindex" select="key('refs',@id)"/>
            </xsl:if>

            <!-- header -->
            <h1>
                <span class="headword">
                    <xsl:choose>
                        <xsl:when test="count(./wd:form/wd:pron[@accent])!=0">
                            <xsl:variable name="accent" select="number(./wd:form/wd:pron/@accent)"/>
                            <xsl:variable name="hiragana" select="$yomi"/>
                            <xsl:variable name="letters" select="'ゅゃょぁぃぅぇぉ'"/>
                            <xsl:variable name="firstMora"
                                          select="string-length(translate(substring($hiragana,2,1),$letters,''))=0"/>
                            <xsl:choose>
                                <xsl:when test="$accent=0">
                                    <xsl:choose>
                                        <xsl:when test="$firstMora">
                                            <span class="b">
                                                <xsl:value-of select="substring($hiragana,1,2)"/>
                                            </span>
                                            <span class="t l">
                                                <xsl:value-of select="substring($hiragana,3)"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="b">
                                                <xsl:value-of select="substring($hiragana,1,1)"/>
                                            </span>
                                            <span class="t l">
                                                <xsl:value-of select="substring($hiragana,2)"/>
                                            </span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:when test="$accent=1">
                                    <xsl:choose>
                                        <xsl:when test="$firstMora">
                                            <span class="t r">
                                                <xsl:value-of select="substring($hiragana,1,2)"/>
                                            </span>
                                            <span class="b">
                                                <xsl:value-of select="substring($hiragana,3)"/>
                                            </span>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="t r">
                                                <xsl:value-of select="substring($hiragana,1,1)"/>
                                            </span>
                                            <span class="b">
                                                <xsl:value-of select="substring($hiragana,2)"/>
                                            </span>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:choose>
                                        <xsl:when test="$firstMora">
                                            <span class="b r">
                                                <xsl:value-of select="substring($hiragana,1,2)"/>
                                            </span>
                                            <xsl:variable name="temp"
                                                          select="substring($hiragana,3,$accent - 1)"/>
                                            <xsl:variable name="count"
                                                          select="string-length($temp)-string-length(translate($temp,$letters,''))"/>
                                            <xsl:variable name="trail"
                                                          select="string-length(translate(substring($hiragana,3 + $count + $accent - 1,1),$letters,''))"/>
                                            <xsl:choose>
                                                <xsl:when test="$trail=0">
                                                    <span class="t r">
                                                        <xsl:value-of
                                                                select="substring($hiragana,3,$count + $accent)"/>
                                                    </span>
                                                    <span class="b">
                                                        <xsl:value-of
                                                                select="substring($hiragana,3 + $count + $accent)"
                                                                />
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <span class="t r">
                                                        <xsl:value-of
                                                                select="substring($hiragana,3,$count + $accent - 1)"
                                                                />
                                                    </span>
                                                    <span class="b">
                                                        <xsl:value-of
                                                                select="substring($hiragana,3 + $count + $accent - 1)"
                                                                />
                                                    </span>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:when>
                                        <xsl:otherwise>
                                            <span class="b r">
                                                <xsl:value-of select="substring($hiragana,1,1)"/>
                                            </span>
                                            <xsl:variable name="temp"
                                                          select="substring($hiragana,2,$accent - 1)"/>
                                            <xsl:variable name="count"
                                                          select="string-length($temp)-string-length(translate($temp,$letters,''))"/>
                                            <xsl:variable name="trail"
                                                          select="string-length(translate(substring($hiragana,2 + $count + $accent - 1,1),$letters,''))"/>
                                            <xsl:choose>
                                                <xsl:when test="$trail=0">
                                                    <span class="t r">
                                                        <xsl:value-of
                                                                select="substring($hiragana,2,$count + $accent)"/>
                                                    </span>
                                                    <span class="b">
                                                        <xsl:value-of
                                                                select="substring($hiragana,2 + $count + $accent)"
                                                                />
                                                    </span>
                                                </xsl:when>
                                                <xsl:otherwise>
                                                    <span class="t r">
                                                        <xsl:value-of
                                                                select="substring($hiragana,2,$count + $accent - 1)"
                                                                />
                                                    </span>
                                                    <span class="b">
                                                        <xsl:value-of
                                                                select="substring($hiragana,2 + $count + $accent - 1)"
                                                                />
                                                    </span>
                                                </xsl:otherwise>
                                            </xsl:choose>
                                        </xsl:otherwise>
                                    </xsl:choose>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$yomi"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
                <span class="hyouki">
                    <xsl:choose>
                        <xsl:when test="count(./wd:form//wd:orth[@midashigo]) != 0">
                            <xsl:text>&#12304;</xsl:text>
                            <xsl:apply-templates mode="simple"
                                                 select="./wd:form//wd:orth[@midashigo]"/>
                            <xsl:text>&#12305;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="./wd:form//wd:orth[not(@irr)]">
                                <xsl:text>&#12304;</xsl:text>
                                <xsl:apply-templates mode="simple"
                                                     select="./wd:form//wd:orth[not(@irr) and not(@midashigo)]"/>
                                <xsl:text>&#12305;</xsl:text>
                            </xsl:if>
                            <xsl:if test="./wd:form//wd:orth[@irr]">
                                <xsl:text>&#12310;</xsl:text>
                                <xsl:apply-templates mode="simple" select="./wd:form//wd:orth[@irr]"/>
                                <xsl:text>&#12311;</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </h1>
            <!-- meaning -->
            <div class="meaning">
                <xsl:if test="count(./wd:gramGrp/wd:pos) > 0">
                    <div class="hinshi">
                        <xsl:apply-templates select="./wd:gramGrp/wd:pos"/>
                    </div>
                </xsl:if>
                <!-- if only one sense, handle usg in sense template -->
                <xsl:if test="count(wd:sense) > 1">
                    <xsl:apply-templates select="wd:usg"/>
                </xsl:if>
                <xsl:apply-templates select="wd:sense"/>
                <xsl:apply-templates select="wd:link"/>
                <xsl:variable name="subs" select="key('refs',@id)"/>
                <xsl:if test="count($subs)>0">
                    <!-- Ableitungen -->
                    <xsl:variable name="hasei" select="$subs[wd:ref[
                    not(@subentrytype='head')
                    and not(@subentrytype='tail')
                    and not(@subentrytype='VwBsp')
                    and not(@subentrytype='WIdiom')
                    and not(@subentrytype='XSatz')
                    and not(@subentrytype='ZSprW')
                    and not(@subentrytype='other')
                    ]]"/>
                    <xsl:if test="count($hasei) > 0">
                        <span class="label" d:pr="ja"><b>派生語</b></span>
                        <span class="label" d:pr="de"><b>Ableitungen</b></span>
                        <xsl:apply-templates mode="subentry" select="$hasei[wd:ref[@subentrytype='suru']]"/>
                        <xsl:apply-templates mode="subentry" select="$hasei[wd:ref[@subentrytype='sa']]"/>
                        <xsl:apply-templates mode="subentry" select="$hasei[wd:ref[not(@subentrytype='sa') and not(@subentrytype='suru')]]"/>
                    </xsl:if>
                    <!-- Komposita -->
                    <xsl:if test="count($subs[wd:ref[@subentrytype='head' or @subentrytype='tail']]) > 0">
                        <span class="label" d:pr="ja"><b>合成語</b></span>
                        <span class="label" d:pr="de"><b>Zusammensetzungen</b></span>
                        <!-- Sichergehen, dass dieser Eintrag gemeint ist, bei evtl. Head- und tail-Kompositum -->
                        <xsl:variable name="id" select="@id"/>
                        <xsl:apply-templates mode="subentry" select="$subs[wd:ref[@subentrytype='head' and @id=$id]]"/>
                        <xsl:apply-templates mode="subentry" select="$subs[wd:ref[@subentrytype='tail' and @id=$id]]"/>
                    </xsl:if>
                    <!-- Rest -->
                    <xsl:if test="(count($subs) - count($hasei) - count($subs[wd:ref[@subentrytype='head' or @subentrytype='tail']])) > 0">
                        <xsl:apply-templates mode="subentry" select="$subs[wd:ref[@subentrytype='VwBsp']]"/>
                        <xsl:apply-templates mode="subentry" select="$subs[wd:ref[@subentrytype='XSatz']]"/>
                        <xsl:apply-templates mode="subentry"
                                             select="$subs[wd:ref[
                                         @subentrytype='WIdiom'
                                         or @subentrytype='ZSprW'
                                         or @subentrytype='other']]"/>
                    </xsl:if>
                </xsl:if>
                <xsl:apply-templates mode="global" select="./wd:ref[@type='main']"/>
            </div>
        </d:entry>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <!-- subentry -->
    <xsl:template mode="subentry" match="wd:entry">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="count(./wd:form/wd:orth[@midashigo]) != 0">
                    <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@midashigo][1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                        <xsl:apply-templates mode="simple"
                                             select="./wd:form/wd:orth[not(@irr) and not(@midashigo)][1]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <div class="subheadword" id="{@id}">
            <xsl:choose>
                <xsl:when test="wd:ref[@subentrytype='head']">
                    <xsl:if test="position()=1"><div>►</div></xsl:if>
                    <xsl:text>　</xsl:text>
                </xsl:when>
                <xsl:when test="wd:ref[@subentrytype='tail']">
                    <xsl:if test="position()=1"><div>◀</div></xsl:if>
                    <xsl:text>　</xsl:text>
                </xsl:when>
                <xsl:when test="wd:ref[@subentrytype='VwBsp']">
                    <xsl:if test="position()=1"><div>◇</div></xsl:if>
                    <xsl:text>　</xsl:text>
                </xsl:when>
                <xsl:when test="wd:ref[@subentrytype='WIdiom' or @subentrytype='ZSprW' or @subentrytype='other' or @subentrytype='XSatz']">
                    <xsl:if test="position()=1"><div>&#160;</div></xsl:if>
                </xsl:when>
            </xsl:choose>
            <!-- Untereintrag hat Untereinträge? dann als Link -->
            <xsl:choose>
                <xsl:when test="count(key('refs', @id)) > 0">
                    <a href="x-dictionary:r:{@id}"><xsl:value-of select="$title"/></a><xsl:text>｜</xsl:text><xsl:apply-templates mode="compact" select="wd:sense"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$title"/><xsl:text>｜</xsl:text><xsl:apply-templates mode="compact" select="wd:sense"/>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template mode="simple" match="wd:form/wd:orth">
        <xsl:choose>
            <xsl:when test="@midashigo='true'">
                <xsl:value-of select="translate(.,'(){}','（）｛｝')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- subentry indices -->
    <xsl:template mode="subheadindex" match="wd:entry">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="count(./wd:form/wd:orth[@midashigo]) != 0">
                    <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@midashigo]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                        <xsl:apply-templates mode="simple"
                                             select="./wd:form/wd:orth[not(@irr) and not(@midashigo)]"/>
                    </xsl:if>
                    <xsl:if test="./wd:form/wd:orth[@irr]">
                        <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@irr]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="yomi" select="./wd:form/wd:pron[not(@type)]"/>
        <xsl:variable name="id" select="./@id"/>

        <d:index d:value="{$yomi}" d:title="{$title}" d:yomi="{$yomi}"/>
        <xsl:for-each select="./wd:form/wd:orth[not(@midashigo='true') and . != $yomi]">
            <d:index d:title="{$title}" d:yomi="{$yomi}" d:value="{.}" d:anchor="xpointer(//*[@id='{$id}'])'"/>
        </xsl:for-each>
    </xsl:template>

    <!-- index -->
    <xsl:template match="wd:orth[not(@midashigo='true')]">
        <xsl:param name="yomi"/>
        <d:index d:title="{.}">
            <!-- kein yomi wenn Schreibung in Hiragana -->
            <xsl:if test=". != $yomi">
                <xsl:attribute name="d:yomi">
                    <xsl:value-of select="$yomi"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:attribute name="d:value">
                <xsl:value-of select="."/>
            </xsl:attribute>
        </d:index>
    </xsl:template>

    <xsl:template match="wd:sense" mode="compact">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="count(../wd:sense) > 1">
                <span class="indexnr">
                    <xsl:value-of select="position()"/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="../wd:usg"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:apply-templates select="wd:usg"/>
        <xsl:apply-templates select="wd:trans"/>
        <!--<xsl:apply-templates select = ".//wd:def"  />
   <xsl:apply-templates select = ".//def"  /-->
        <xsl:if test="./@season">
            <xsl:choose>
                <xsl:when test="./@season='spring'">
                    <span class="season spring" title="Jahreszeitenwort/季語: Frühling">
                        <xsl:text>春</xsl:text>
                    </span>
                </xsl:when>
                <xsl:when test="./@season='summer'">
                    <span class="season summer" title="Jahreszeitenwort/季語: Sommer">
                        <xsl:text>夏</xsl:text>
                    </span>
                </xsl:when>
                <xsl:when test="./@season='autumn'">
                    <span class="season autumn" title="Jahreszeitenwort/季語: Herbst">
                        <xsl:text>秋</xsl:text>
                    </span>
                </xsl:when>
                <xsl:when test="./@season='winter'">
                    <span class="season winter" title="Jahreszeitenwort/季語: Winter">
                        <xsl:text>冬</xsl:text>
                    </span>
                </xsl:when>
                <xsl:when test="./@season='newyear'">
                    <span class="season newyear" title="Jahreszeitenwort/季語: Neujahr">
                        <xsl:text>新年</xsl:text>
                    </span>
                </xsl:when>
            </xsl:choose>
        </xsl:if>
        <xsl:if test="./wd:etym">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="./wd:etym"/>
        </xsl:if>
        <xsl:if test="./wd:ref">
            <xsl:text> </xsl:text>
            <xsl:apply-templates select="./wd:ref"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:sense">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="sense">
            <xsl:choose>
                <xsl:when test="count(../wd:sense) > 1">
                    <span class="indexnr">
                        <xsl:value-of select="position()"/>
                    </span>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates select="../wd:usg"/>
                </xsl:otherwise>
            </xsl:choose>

            <xsl:apply-templates select="wd:usg"/>
            <xsl:apply-templates select="wd:trans"/>
            <!--<xsl:apply-templates select = ".//wd:def"  />
                <xsl:apply-templates select = ".//def"  /-->
            <xsl:if test="./@season">
                <xsl:choose>
                    <xsl:when test="./@season='spring'">
                        <span class="season spring" title="Jahreszeitenwort/季語: Frühling">
                            <xsl:text>春</xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="./@season='summer'">
                        <span class="season summer" title="Jahreszeitenwort/季語: Sommer">
                            <xsl:text>夏</xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="./@season='autumn'">
                        <span class="season autumn" title="Jahreszeitenwort/季語: Herbst">
                            <xsl:text>秋</xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="./@season='winter'">
                        <span class="season winter" title="Jahreszeitenwort/季語: Winter">
                            <xsl:text>冬</xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:when test="./@season='newyear'">
                        <span class="season newyear" title="Jahreszeitenwort/季語: Neujahr">
                            <xsl:text>新年</xsl:text>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:if test="./wd:etym">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="./wd:etym"/>
            </xsl:if>
            <xsl:if test="./wd:ref">
                <xsl:text> </xsl:text>
                <xsl:apply-templates select="./wd:ref"/>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="wd:trans">
        <xsl:choose>
            <xsl:when test="@langdesc='scientific'">
                <span class="latin">
                    <xsl:apply-templates/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:choose>
            <!--<xsl:when test="position()=last()"><xsl:text>.</xsl:text></xsl:when>-->
            <xsl:when test="count(following-sibling::wd:trans)=0">
                <!-- wenn Satzzeichen schon im letzten Trans, dann keinen Punkt einfügen-->
                <xsl:variable name="lastchild" select="child::wd:tr/*[position()=last()]"/>
                <xsl:choose>
                    <xsl:when test="$lastchild">
                        <xsl:choose>
                            <xsl:when
                                    test="contains(substring($lastchild, string-length($lastchild), 1), '.')"/>
                            <xsl:when
                                    test="contains(substring($lastchild, string-length($lastchild), 1), '!')"/>
                            <xsl:when
                                    test="contains(substring($lastchild, string-length($lastchild), 1), '?')"/>
                            <xsl:otherwise>
                                <xsl:text>.</xsl:text>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>.</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <span class="rel">
                    <xsl:choose>
                        <xsl:when
                                test="following-sibling::wd:trans[1]/wd:usg[@type='hint' and text()='rel.']">
                            <xsl:text> || </xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:text>; </xsl:text>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:token">
        <xsl:if
                test="position()&gt;1 and string-length(.)>0 and count(preceding-sibling::wd:text)=0">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="token">
            <xsl:value-of select="."/>
        </span>
        <span class="genus">
            <xsl:if test="@article='false' or @noArticleNecessary='true'">(</xsl:if>
            <xsl:value-of select="./@genus"/>
            <xsl:value-of select="./@numerus"/>
            <xsl:if test="not(@genus) and not(@numerus) and @article='false'">NAr</xsl:if>
            <xsl:if test="not(@genus) and not(@numerus) and @noArticleNecessary='true'">NArN</xsl:if>
            <xsl:if test="@article='false' or @noArticleNecessary='true'">)</xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="wd:tr">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="wd:title">
        <xsl:if test="position()&gt;1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="title">
            <xsl:if test="@orig='true'">
                <xsl:attribute name="class">title orig</xsl:attribute>
            </xsl:if>
            <xsl:if test="@lang">
                <xsl:attribute name="title">
                    <xsl:value-of select="@lang"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="wd:usg">
        <xsl:choose>
            <xsl:when test="@type='dom'">
                <span class="dom">
                    <xsl:apply-templates/>
                    <xsl:if test="count(following-sibling::wd:usg[@type='dom'])>0">
                        <xsl:text>, </xsl:text>
                    </xsl:if>
                    <xsl:if test="count(following-sibling::wd:usg[@type='dom'])=0">&#160;</xsl:if>
                </span>
            </xsl:when>
            <xsl:when test="@type='time'">
                <span class="reg">
                    <xsl:value-of select="."/>
                    <xsl:text> </xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@reg='lit'">
                <span class="reg">
                    <xsl:text>schriftspr. </xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@reg='coll'">
                <span class="reg">
                    <xsl:text>ugs. </xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@reg='vulg'">
                <span class="reg">
                    <xsl:text>vulg. </xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="@type='hint'">
                <xsl:choose>
                    <xsl:when test="text()='rel.'"/>
                    <xsl:otherwise>
                        <span class="usage">
                            <xsl:apply-templates/>
                            <xsl:if test="not(parent::wd:bracket) and position()=last()">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@reg">
                        <span class="reg">
                            <xsl:value-of select="@reg"/>
                            <xsl:text>.</xsl:text>
                        </span>
                    </xsl:when>
                    <xsl:otherwise>
                        <span class="usage">
                            <xsl:value-of select="."/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:if test="not(parent::wd:bracket) and position()=last()">
                    <xsl:text> </xsl:text>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:ref" mode="global">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="entry" select="//wd:entry[@id=$id]"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="count($entry/wd:form/wd:orth[@midashigo]) != 0">
                    <xsl:apply-templates mode="simple" select="$entry/wd:form/wd:orth[@midashigo]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="$entry/wd:form/wd:orth[not(@irr)]">
                        <xsl:apply-templates mode="simple"
                                             select="$entry/wd:form/wd:orth[not(@irr) and not(@midashigo)]"/>
                    </xsl:if>
                    <xsl:if test="$entry/wd:form/wd:orth[@irr]">
                        <xsl:apply-templates mode="simple" select="$entry/wd:form/wd:orth[@irr]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <div class="parentheadword">
            <a href="x-dictionary:r:{@id}" class="reflink parent">
                <xsl:value-of select="$title"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="wd:ref">
        <xsl:if test="position()&gt;1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <a href="x-dictionary:r:{@id}" title="{./wd:jap}">
            <xsl:choose>
                <xsl:when test="@type='syn'">
                    <xsl:attribute name="class">reflink syn</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='anto'">
                    <xsl:attribute name="class">reflink anto</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='main'">
                    <xsl:attribute name="class">reflink main</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='altread'">
                    <xsl:attribute name="class">reflink aread</xsl:attribute>
                </xsl:when>
                <xsl:when test="@type='other'">
                    <xsl:attribute name="class">reflink</xsl:attribute>
                </xsl:when>
            </xsl:choose>
            <xsl:apply-templates select="./wd:transcr"/>
            <xsl:apply-templates select="./wd:jap"/>
        </a>
    </xsl:template>

    <xsl:template match="wd:pos">
        <xsl:choose>
            <xsl:when test="string-length(.)>0">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="@type"/>
                <xsl:if test="not(contains(substring(@type, string-length(@type), 1), '.'))">
                    <xsl:if
                            test="@type!='Redensart' and @type!='Kanji' and @type!='BspSatz' and @type!='Sonderzeichen' and @type!='Sonderform'">
                        <xsl:text>.</xsl:text>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:text">
        <xsl:if test="@hasPrecedingSpace='true'">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:apply-templates/>
        <xsl:if test="@hasFollowingSpace='true'">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:bracket">
        <xsl:if test="preceding-sibling::*">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="klammer">
            <xsl:text>(</xsl:text>
            <xsl:for-each select="./*">
                <xsl:apply-templates select="."/>
                <xsl:if test="not(position()=last())">
                    <xsl:text>; </xsl:text>
                </xsl:if>
            </xsl:for-each>
            <!--  Scientific in Klammern
                <xsl:if test="count(//wd:trans[@langdesc='scientific'])>0">
                <xsl:text>; </xsl:text>
                <xsl:apply-templates select="//wd:trans[@langdesc='scientific']"/>
                </xsl:if>-->
            <xsl:text>)</xsl:text>
        </span>
        <xsl:if test="position()&lt;last()">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:famn">
        <xsl:if test="position()&gt;1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="famn">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="wd:emph">
        <em>
            <xsl:apply-templates/>
        </em>
    </xsl:template>

    <xsl:template match="wd:foreign">
        <xsl:if test="position()&gt;1 and not(starts-with(text(), ','))">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="foreign">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="wd:link">
        <xsl:if test="@type='picture'">
            <img alt="{@url}" src="Images/{@url}.jpg"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:impli">
        <span class="impli">
            <xsl:apply-templates/>
        </span>
        <xsl:if test="position() != last()">
            <xsl:text>; </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:*">
        <span class="{name(.)}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>
