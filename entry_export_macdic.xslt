<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng"
        xmlns:wd="http://www.wadoku.de/xml/entry"
        exclude-result-prefixes="d xs"
        version="2.0">
    <xsl:import href="front_matter.xsl"/>
    <xsl:import href="image_appendix.xsl"/>
    <xsl:import href="seasonword_appendix.xsl"/>
    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="yes"/>

    <!-- Parameter, der bestimmt, ob Untereinträge ihre eigenen Einträge erhalten,
         oder nur im Haupteintrag erscheinen, wenn = yes
    -->
    <xsl:param name="strictSubHeadIndex">no</xsl:param>

    <!-- Trenner für Schreibungen/Stichworte -->
    <xsl:param name="orthdivider">
        <span class="divider">；</span>
    </xsl:param>

    <!-- Trenner für Bedeutungen mit inhaltlicher Nähe -->
    <xsl:variable name="relationDivider">
        <xsl:text> ‖ </xsl:text>
    </xsl:variable>

    <!-- Kana/Symbole, die nicht als einzelne Mora gelten -->
    <xsl:variable name="letters" select="'ゅゃょぁぃぅぇぉ・･·~’￨|…'"/>

    <!-- lookup key für einträge mit referenzen auf einen Haupteintrag -->
    <xsl:key name="refs" match="wd:entry[./wd:ref[@type='main']]" use="./wd:ref/@id"/>

    <xsl:template match="entries">
        <d:dictionary xmlns="http://www.w3.org/1999/xhtml"
                      xmlns:d="http://www.apple.com/DTDs/DictionaryService-1.0.rng">

            <xsl:choose>
                <xsl:when test="$strictSubHeadIndex = 'yes'">
                    <!-- nur Einträge,
                      * die Untereinträge haben
                      * ohne Untereinträge und selbst kein Untereintrag sind
                      -->
                    <xsl:apply-templates select="wd:entry[not(./wd:ref[@type='main']) or key('refs',@id)]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:apply-templates/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:call-template name="front"/>
            <xsl:call-template name="image_appendix"/>
            <xsl:call-template name="seasonword_appendix"/>
        </d:dictionary>
    </xsl:template>

    <xsl:template match="wd:entry">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="./wd:form/wd:orth[@midashigo]">
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
            <xsl:value-of select="replace(./wd:form/wd:pron[not(@type)],'う゛','ゔ')"/>
        </xsl:variable>
        <d:entry id="{@id}" d:title="{$title}">
            <!-- index -->
            <xsl:variable name="idx">
                <xsl:call-template name="build_entry_index">
                    <xsl:with-param name="title" select="$title"/>
                    <xsl:with-param name="yomi" select="$yomi"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- filter duplicate index entries -->
            <xsl:for-each select="$idx">
                <xsl:copy-of select="d:index[not(preceding-sibling::d:index/@d:value=./@d:value
                 and preceding-sibling::d:index/@d:title=./@d:title and preceding-sibling::d:index/@d:yomi=./@d:yomi)]"/>
            </xsl:for-each>
            <!-- Index für Untereinträge -->
            <xsl:if test="$strictSubHeadIndex = 'yes'">
                <xsl:apply-templates mode="subheadindex" select="key('refs',@id)"/>
            </xsl:if>

            <!-- header -->
            <h1>
                <span class="headword">
                    <ruby>
                        <rb>
                            <xsl:call-template name="reading_from_extended_yomi"/>
                        </rb>
                        <rt>
                            <xsl:value-of select="./wd:form/wd:pron[@type='romaji']"/>
                        </rt>
                    </ruby>
                </span>
                <span class="hyouki">
                    <xsl:choose>
                        <xsl:when test="./wd:form/wd:orth[@midashigo]">
                            <xsl:text>&#12304;</xsl:text>
                            <xsl:apply-templates mode="simple"
                                                 select="./wd:form/wd:orth[@midashigo]"/>
                            <xsl:text>&#12305;</xsl:text>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                                <xsl:text>&#12304;</xsl:text>
                                <xsl:apply-templates mode="simple"
                                                     select="./wd:form/wd:orth[not(@irr) and not(@midashigo)]"/>
                                <xsl:text>&#12305;</xsl:text>
                            </xsl:if>
                            <xsl:if test="./wd:form/wd:orth[@irr]">
                                <xsl:text>&#12310;</xsl:text>
                                <xsl:apply-templates mode="simple"
                                                     select="./wd:form/wd:orth[@irr]"/>
                                <xsl:text>&#12311;</xsl:text>
                            </xsl:if>
                        </xsl:otherwise>
                    </xsl:choose>
                </span>
            </h1>
            <div class="uid"><xsl:value-of select="@id"/></div>
            <!-- meaning -->
            <div class="meaning">
                <xsl:if test="./wd:gramGrp/wd:pos">
                    <div class="hinshi">
                        <xsl:apply-templates select="./wd:gramGrp/wd:pos"/>
                    </div>
                </xsl:if>
                <!-- if only one sense, handle usg in sense template -->
                <xsl:apply-templates select="wd:usg"/>
                <xsl:apply-templates select="wd:sense"/>
                <xsl:apply-templates select="wd:ref[not(@type='main')]"/>
                <xsl:apply-templates select="wd:link"/>
                <xsl:call-template name="entry_subs"/>
                <xsl:apply-templates mode="global" select="./wd:ref[@type='main']"/>
            </div>
        </d:entry>
    </xsl:template>

    <xsl:template name="build_entry_index">
        <xsl:param name="title"/>
        <xsl:param name="yomi"/>
        <!-- Lesung -->
        <d:index d:title="{$title}" d:value="{$yomi}" d:yomi="{$yomi}"/>
        <!-- Lesung mit … auch ohne … in den Suchindex -->
        <xsl:if test="contains($yomi, '…')">
            <d:index d:value="{translate($yomi, '…', '')}" d:title="{$title}" d:yomi="{$yomi}"/>
        </xsl:if>
        <!-- Schreibungen -->
        <xsl:for-each select="./wd:form/wd:orth[not(@midashigo='true') and . != $yomi]">
            <xsl:apply-templates mode="index"
                                 select=".">
                <xsl:with-param name="title" select="$title"/>
                <xsl:with-param name="yomi" select="$yomi"/>
            </xsl:apply-templates>
        </xsl:for-each>
    </xsl:template>
    <!-- Untereinträge -->
    <xsl:template name="entry_subs">
        <xsl:variable name="subs" select="key('refs',@id)"/>
        <xsl:if test="$subs">
            <div class="subentries">
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
                <xsl:if test="$hasei">
                    <span class="label" xml:lang="ja">
                        <b>派生語</b>
                    </span>
                    <span class="label" xml:lang="de">
                        <b>Ableitungen</b>
                    </span>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[@subentrytype='suru']]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[@subentrytype='sa']]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[not(@subentrytype='sa') and not(@subentrytype='suru')]]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                </xsl:if>
                <!-- Komposita -->
                <xsl:if test="$subs[wd:ref[@subentrytype='head' or @subentrytype='tail']]">
                    <span class="label" xml:lang="ja">
                        <b>合成語</b>
                    </span>
                    <span class="label" xml:lang="de">
                        <b>Zusammensetzungen</b>
                    </span>
                    <!-- Sichergehen, dass dieser Eintrag gemeint ist, bei evtl. Head- und tail-Kompositum -->
                    <xsl:variable name="id" select="@id"/>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='head' and @id=$id]]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='tail' and @id=$id]]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                </xsl:if>
                <!-- Rest -->
                <xsl:if test="(count($subs) - count($hasei) - count($subs[wd:ref[@subentrytype='head' or @subentrytype='tail']])) > 0">
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='VwBsp']]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='XSatz']]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[
                                         @subentrytype='WIdiom'
                                         or @subentrytype='ZSprW'
                                         or @subentrytype='other']]">
                        <xsl:sort select="./wd:form/wd:pron[not(@type)]/wd:text/text()"/>
                    </xsl:apply-templates>
                </xsl:if>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:function name="wd:get_accented_part" as="xs:string">
        <xsl:param name="str"/>
        <xsl:param name="accent"/>
        <xsl:choose>
            <xsl:when test="string-length(translate($str, $letters, '')) > $accent">
                <xsl:value-of select="wd:get_accented_part(substring($str, 1, string-length($str)-1), $accent)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="substring($str, 1, string-length($str)-1)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:template name="insert_divider">
        <!--
        ersetzt Pipe (|) durch span-Element mit divider class
        arbeitet auf Strings
        -->
        <xsl:param name="t"/>
        <xsl:analyze-string
                regex="￨"
                select="$t">
            <xsl:matching-substring>
                <span class="divider">￨</span>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="enrich_midashigo">
        <xsl:analyze-string select="." regex="△(.)|×(.)|〈(.*?)〉|｛(.*?)｝|（([^（）]*?)）|（（([^（）]*?)）([^（）]*?)）">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(1)">
                        <span class="njok"><!-- non joyo on/kun -->
                            <xsl:value-of select="regex-group(1)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(2)">
                        <span class="njk"><!-- non joyo kanji -->
                            <xsl:value-of select="regex-group(2)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(3)">
                        <span class="jjk"><!-- jukujikun joyo kanji -->
                            <xsl:value-of select="regex-group(3)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(4)">
                        <span class="fjjk"><!-- fuhyo jukujikun joyo kanji -->
                            <xsl:value-of select="regex-group(4)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(5)">
                        <span class="paren">
                            <xsl:value-of select="regex-group(5)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(6)">
                        <span class="paren">
                            <span class="paren">
                                <xsl:value-of select="regex-group(6)"/>
                            </span>
                            <xsl:value-of select="regex-group(7)"/>
                        </span>
                    </xsl:when>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:value-of select="."/>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:template>

    <xsl:template name="reading_from_extended_yomi">
        <xsl:variable name="yomi">
            <!--
              * entferne störende Symbole
              * typographische Korrekturen/Vereinheitlichung
            -->
            <xsl:value-of select="
                            replace(
                            translate(
                            translate(./wd:form/wd:pron[@type='hatsuon'],'&lt;>/[]1234567890:　 GrJoDevN_＿',''),
                            &quot;・･'’&quot;, '··￨￨'),
                            'う゛','ゔ')
                        "/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="./wd:form/wd:pron[@accent]">
                <xsl:variable name="accent" select="number(./wd:form/wd:pron/@accent)"/>
                <xsl:variable name="startsWithEllipsis" select="starts-with($yomi, '…')"/>
                <xsl:variable name="hiragana">
                    <xsl:choose>
                        <xsl:when test="$startsWithEllipsis">
                            <xsl:value-of select="substring($yomi, 2)"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:value-of select="$yomi"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="firstMora"
                              select="string-length(translate(substring($hiragana,2,1),$letters,''))=0"/>
                <xsl:if test="$startsWithEllipsis">
                    <xsl:text>…</xsl:text>
                </xsl:if>
                <xsl:choose>
                    <xsl:when test="$accent=0">
                        <xsl:choose>
                            <xsl:when test="$firstMora">
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,2)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="t l">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,3)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,1)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="t l">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,2)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:when test="$accent=1">
                        <xsl:choose>
                            <xsl:when test="$firstMora">
                                <span class="t r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,2)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,3)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="t r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,1)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,2)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="$firstMora">
                                <span class="b r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,2)"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:variable name="temp"
                                              select="wd:get_accented_part(substring($hiragana, 3, string-length($hiragana)), $accent)"/>
                                <xsl:variable name="count"
                                              select="string-length($temp)-string-length(translate($temp,$letters,''))"/>
                                <xsl:variable name="trail"
                                              select="string-length(translate(substring($hiragana,3 + $count + $accent - 1,1),$letters,''))"/>
                                <xsl:choose>
                                    <xsl:when test="$trail=0">
                                        <span class="t r">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,3,$count + $accent)"/>
                                            </xsl:call-template>
                                        </span>
                                        <span class="b">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,3 + $count + $accent)"/>
                                            </xsl:call-template>
                                        </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="t r">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,3,$count + $accent - 1)"/>
                                            </xsl:call-template>
                                        </span>
                                        <span class="b">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,3 + $count + $accent - 1)"/>
                                            </xsl:call-template>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="b r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana,1,1)"/>
                                    </xsl:call-template>
                                </span>
                                <xsl:variable name="str1"
                                              select="substring($hiragana,2,string-length($hiragana))"/>
                                <xsl:variable name="temp" select="wd:get_accented_part($str1, $accent)"/>
                                <xsl:variable name="count"
                                              select="string-length($temp)-string-length(translate($temp,$letters,''))"/>
                                <xsl:variable name="trail"
                                              select="string-length(substring-after($str1, $temp))"/>
                                <xsl:choose>
                                    <xsl:when test="$trail=0">
                                        <span class="t r">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,2,$count + $accent)"/>
                                            </xsl:call-template>
                                        </span>
                                        <span class="b">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,2 + $count + $accent)"/>
                                            </xsl:call-template>
                                        </span>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <span class="t r">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,2,$count + $accent - 1)"/>
                                            </xsl:call-template>
                                        </span>
                                        <span class="b">
                                            <xsl:call-template name="insert_divider">
                                                <xsl:with-param name="t"
                                                                select="substring($hiragana,2 + $count + $accent - 1)"/>
                                            </xsl:call-template>
                                        </span>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insert_divider">
                    <xsl:with-param name="t"
                                    select="$yomi"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>

    </xsl:template>

    <!-- subentry -->
    <xsl:template mode="subentry" match="wd:entry">
        <xsl:variable name="title">
            <xsl:call-template name="get_subentry_title"/>
        </xsl:variable>
        <div class="subheadword" id="{@id}">
            <xsl:call-template name="get_subentry_type"/>
            <!-- Untereintrag hat Untereinträge? dann als Link -->
            <ruby>
                <rb>
                    <xsl:choose>
                        <xsl:when test="key('refs', @id)">
                            <a href="x-dictionary:r:{@id}">
                                <xsl:copy-of select="$title"/>
                            </a>
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:copy-of select="$title"/>
                        </xsl:otherwise>
                    </xsl:choose>
                </rb>
                <rt>
                    <xsl:call-template name="reading_from_extended_yomi"/>
                </rt>
            </ruby>
            <xsl:text>｜</xsl:text>
            <xsl:apply-templates mode="compact"
                                 select="wd:sense"/>
        </div>
    </xsl:template>

    <xsl:template name="get_subentry_title">
        <xsl:choose>
            <xsl:when test="./wd:form/wd:orth[@midashigo]">
                <xsl:apply-templates mode="simple"
                                     select="./wd:form/wd:orth[@midashigo][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                    <xsl:apply-templates mode="simple"
                                         select="./wd:form/wd:orth[not(@irr) and not(@midashigo)][1]"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get_subentry_type">
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
    </xsl:template>

    <xsl:template mode="simple" match="wd:form/wd:orth">
        <xsl:choose>
            <xsl:when test="@midashigo='true'">
                <xsl:for-each select="translate(.,'(){}・･','（）｛｝··')">
                    <xsl:call-template name="enrich_midashigo"/>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="translate(.,'・･','··')"/>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="not(position()=last())">
            <xsl:copy-of select="$orthdivider"/>
        </xsl:if>
    </xsl:template>

    <!-- subentry indices -->
    <xsl:template mode="subheadindex" match="wd:entry">
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="./wd:form/wd:orth[@midashigo]">
                    <xsl:apply-templates mode="simple" select="./wd:form/wd:orth[@midashigo]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:if test="./wd:form/wd:orth[not(@irr)]">
                        <xsl:apply-templates mode="simple"
                                             select="./wd:form/wd:orth[not(@irr) and not(@midashigo)]"/>
                    </xsl:if>
                    <xsl:if test="./wd:form/wd:orth[@irr]">
                        <xsl:apply-templates mode="simple"
                                             select="./wd:form/wd:orth[@irr]"/>
                    </xsl:if>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="yomi" select="./wd:form/wd:pron[not(@type)]"/>
        <xsl:variable name="id" select="./@id"/>

        <d:index d:value="{$yomi}" d:title="{$title}" d:yomi="{$yomi}"/>
        <xsl:for-each select="./wd:form/wd:orth[not(@midashigo='true') and . != $yomi]">
            <d:index d:title="{$title}"
                     d:yomi="{$yomi}"
                     d:value="{.}"
                     d:anchor="xpointer(//*[@id='{$id}'])'"/>
        </xsl:for-each>
    </xsl:template>

    <!-- index -->
    <xsl:template mode="index" match="wd:orth[not(@midashigo='true')]">
        <xsl:param name="title"/>
        <xsl:param name="yomi"/>
        <!-- Schreibung auch als Titel, passt besser zu den Standard-Wörterbüchern -->
        <d:index d:title="{.}"
                 d:value="{.}">
            <!-- kein yomi wenn Schreibung in Hiragana -->
            <xsl:if test=". != $yomi">
                <xsl:attribute name="d:yomi">
                    <xsl:value-of select="$yomi"/>
                </xsl:attribute>
            </xsl:if>
        </d:index>
        <!-- Schreibung unter dem Eintrags-Midashigo -->
        <d:index d:title="{$title}"
                 d:value="{.}">
            <!-- kein yomi wenn Schreibung in Hiragana -->
            <xsl:if test=". != $yomi">
                <xsl:attribute name="d:yomi">
                    <xsl:value-of select="$yomi"/>
                </xsl:attribute>
            </xsl:if>
        </d:index>
        <!-- wenn … enthalten, auch ohne … in den Index -->
        <xsl:if test="contains(., '…')">
            <d:index d:title="{$title}"
                     d:value="{translate(., '…', '')}">
                <!-- kein yomi wenn Schreibung in Hiragana -->
                <xsl:if test=". != $yomi">
                    <xsl:attribute name="d:yomi">
                        <xsl:value-of select="$yomi"/>
                    </xsl:attribute>
                </xsl:if>
            </d:index>
        </xsl:if>
        <!-- alternative nakaten in den Index -->
        <xsl:if test="contains(., '・') or contains(., '･')">
            <d:index d:title="{$title}"
                     d:yomi="{$yomi}"
                     d:value="{translate(., '・･', '··')}"/>
            <xsl:if test="contains(., '・')">
                <d:index d:title="{$title}"
                         d:yomi="{$yomi}"
                         d:value="{translate(., '・', '･')}"/>
            </xsl:if>
            <xsl:if test="contains(., '･')">
                <d:index d:title="{$title}"
                         d:yomi="{$yomi}"
                         d:value="{translate(., '･', '・')}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:sense" mode="compact">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="@related='true'">
                <span class="rel">
                    <xsl:copy-of select="$relationDivider"/>
                </span>
            </xsl:when>
            <xsl:when test="following-sibling::wd:sense[not(@related)] or preceding-sibling::wd:sense[not(@related)]">
                <span class="indexnr">
                    <xsl:number count="wd:sense[not(@related)]"/>
                </span>
                <xsl:text>&#160;</xsl:text>
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
            <xsl:call-template name="season"/>
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

    <xsl:template match="wd:sense[not(empty(./wd:sense))]">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="master sense">
            <span class="indexnr" >
                <xsl:number format="A" value="position()"/>
            </span>
            <xsl:text>&#160;</xsl:text>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="wd:sense[empty(./wd:sense)]">
        <xsl:choose>
            <xsl:when test="@related='true'">
                <span class="rel">
                    <xsl:copy-of select="$relationDivider"/>
                </span>
                <span class="sense related">
                    <xsl:apply-templates mode="core" select="."/>
                </span>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="position()>1">
                    <xsl:text> </xsl:text>
                    <br/>
                </xsl:if>
                <span class="sense">
                    <xsl:if test="following-sibling::wd:sense[not(@related)] or preceding-sibling::wd:sense[not(@related)]">
                        <span class="indexnr">
                            <xsl:number count="wd:sense[not(@related)]"/>
                        </span>
                        <xsl:text>&#160;</xsl:text>
                    </xsl:if>
                    <xsl:apply-templates mode="core" select="."/>
                </span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:sense" mode="core">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="not(empty(wd:bracket))">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="not(empty(wd:def) and empty(wd:expl))">
                <!--
                 einträge ohne bracket
                -->
                <xsl:if test="wd:trans/preceding-sibling::*[not(self::wd:trans)]">
                    <xsl:for-each select="wd:trans/preceding-sibling::*[not(self::wd:trans)]">
                        <xsl:apply-templates select="."/>
                    </xsl:for-each>
                    <xsl:text> </xsl:text>
                </xsl:if>
                <xsl:apply-templates select="wd:trans"/>
                <xsl:if test="wd:trans[last()]/following-sibling::*[not(self::wd:trans)]">
                    <xsl:text> </xsl:text>
                    <span class="klammer">
                        <xsl:text>(</xsl:text>
                        <xsl:for-each select="wd:trans[last()]/following-sibling::*[not(self::wd:trans)]">
                            <xsl:apply-templates select="."/>
                            <xsl:if test="position()&lt;last()">; </xsl:if>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="wd:usg" />
                <xsl:apply-templates select="wd:trans" />
                <!--<xsl:apply-templates select = ".//wd:def"  />
               <xsl:apply-templates select = ".//def"  /-->
                <xsl:if test="@season">
                    <xsl:call-template name="season"/>
                </xsl:if>
                <xsl:if test="wd:etym">
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="wd:etym"/>
                </xsl:if>
                <xsl:if test="./wd:ref">
                    <xsl:text> </xsl:text>
                    <xsl:apply-templates select="./wd:ref"/>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="season">
        <xsl:choose>
            <xsl:when test="./@season='spring'">
                <span class="season spring" xml:lang="ja" title="季語">
                    <xsl:text>春</xsl:text>
                </span>
                <span class="season spring" xml:lang="de" title="Jahreszeitenwort">
                    <xsl:text>Frühling</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="./@season='summer'">
                <span class="season summer" xml:lang="ja" title="季語">
                    <xsl:text>夏</xsl:text>
                </span>
                <span class="season summer" xml:lang="de" title="Jahreszeitenwort">
                    <xsl:text>Sommer</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="./@season='autumn'">
                <span class="season autumn" xml:lang="ja" title="季語">
                    <xsl:text>秋</xsl:text>
                </span>
                <span class="season autumn" xml:lang="de" title="Jahreszeitenwort">
                    <xsl:text>Herbst</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="./@season='winter'">
                <span class="season winter" xml:lang="ja" title="季語">
                    <xsl:text>冬</xsl:text>
                </span>
                <span class="season winter" xml:lang="de" title="Jahreszeitenwort">
                    <xsl:text>Winter</xsl:text>
                </span>
            </xsl:when>
            <xsl:when test="./@season='newyear'">
                <span class="season newyear" xml:lang="ja" title="季語">
                    <xsl:text>新年</xsl:text>
                </span>
                <span class="season newyear" xml:lang="de" title="Jahreszeitenwort">
                    <xsl:text>Neujahr</xsl:text>
                </span>
            </xsl:when>
        </xsl:choose>
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
            <xsl:when test="not(following-sibling::wd:trans)">
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
                        <xsl:when test="following-sibling::wd:trans[1]/wd:usg[@type='hint' and text()='rel.']">
                            <xsl:copy-of select="$relationDivider"/>
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
        <xsl:if test="position()>1 and string-length(.)>0 and not(preceding-sibling::wd:text)">
            <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:if test="preceding-sibling::wd:iron">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="token">
            <xsl:value-of select="."/>
            <xsl:call-template name="genusTemplate">
                <xsl:with-param name="lang">de</xsl:with-param>
                <xsl:with-param name="genus">
                    <xsl:if test="@genus">
                        <xsl:call-template name="genusTemplate-de"/>
                        <xsl:if test="@numerus">
                            <xsl:text>, </xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="@numerus">
                        <xsl:call-template name="numerusTemplate-de"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="genusTemplate">
                <xsl:with-param name="lang">ja</xsl:with-param>
                <xsl:with-param name="genus">
                    <xsl:if test="@genus">
                        <xsl:call-template name="genusTemplate-ja"/>
                        <xsl:if test="@numerus">
                            <xsl:text>・</xsl:text>
                        </xsl:if>
                    </xsl:if>
                    <xsl:if test="@numerus">
                        <xsl:call-template name="numerusTemplate-ja"/>
                    </xsl:if>
                </xsl:with-param>
            </xsl:call-template>
        </span>
        <xsl:if test="following-sibling::wd:iron">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template name="genusTemplate">
        <xsl:param name="genus"/>
        <xsl:param name="lang"/>
        <i class="genus" lang="{$lang}">
            <xsl:if test="string-length($genus) > 0">
                <xsl:attribute name="title">
                    <xsl:value-of select="$genus"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:text>&#160;</xsl:text>
            <xsl:if test="@article='false' or @noArticleNecessary='true'">(</xsl:if>
            <xsl:value-of select="@genus"/>
            <xsl:value-of select="@numerus"/>
            <xsl:if test="not(@genus) and not(@numerus) and @article='false'">NAr</xsl:if>
            <xsl:if test="not(@genus) and not(@numerus) and @noArticleNecessary='true'">NArN</xsl:if>
            <xsl:if test="@article='false' or @noArticleNecessary='true'">)</xsl:if>
        </i>
    </xsl:template>

    <xsl:template name="numerusTemplate-de">
        <xsl:choose>
            <xsl:when test="@numerus='pl'">
                <xsl:choose>
                    <xsl:when test="@genus">
                        <xsl:text>Plural</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>Pluraletantum</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="numerusTemplate-ja">
        <xsl:choose>
            <xsl:when test="@numerus='pl'">
                <xsl:choose>
                    <xsl:when test="@genus">
                        <xsl:text>複数</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>絶対複数</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="genusTemplate-de">
        <xsl:choose>
            <xsl:when test="@genus='m'">
                <xsl:text>männlich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='f'">
                <xsl:text>weiblich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='n'">
                <xsl:text>sächlich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='mn'">
                <xsl:text>männlich oder sächlich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='mf'">
                <xsl:text>männlich oder weiblich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='nf'">
                <xsl:text>sächlich oder männlich</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="genusTemplate-ja">
        <xsl:choose>
            <xsl:when test="@genus='m'">
                <xsl:text>男性</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='f'">
                <xsl:text>女性</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='n'">
                <xsl:text>中性</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='mn'">
                <xsl:text>男性／中性</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='mf'">
                <xsl:text>男性／女性</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='nf'">
                <xsl:text>中性／女性</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>


    <xsl:template match="wd:tr">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="wd:title">
        <xsl:if test="position()>1">
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
                <span class="dom" >
                    <xsl:apply-templates />
                    <xsl:call-template name="usg_after"/>
                </span>
            </xsl:when>
            <xsl:when test="@type='time'">
                <span class="reg">
                    <xsl:value-of select="."/>
                    <xsl:call-template name="usg_after"/>
                </span>
            </xsl:when>
            <xsl:when test="@reg='lit'">
                <span class="reg">
                    <xsl:text>schriftspr.</xsl:text>
                    <xsl:call-template name="usg_after"/>
                </span>
            </xsl:when>
            <xsl:when test="@reg='coll'">
                <span class="reg">
                    <xsl:text>ugs.</xsl:text>
                    <xsl:call-template name="usg_after"/>
                </span>
            </xsl:when>
            <xsl:when test="@reg='vulg'">
                <span class="reg">
                    <xsl:text>vulg.</xsl:text>
                    <xsl:call-template name="usg_after"/>
                </span>
            </xsl:when>
            <xsl:when test="@type='hint'">
                <xsl:choose>
                    <xsl:when test="text()='rel.'"/>
                    <xsl:otherwise>
                        <span class="usage">
                            <xsl:apply-templates/>
                            <xsl:call-template name="usg_after"/>
                        </span>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:otherwise>
                <xsl:choose>
                    <xsl:when test="@reg">
                        <span class="reg">
                            <xsl:value-of select="@reg"/>
                            <xsl:if test="lower-case(@reg)=@reg and not(ends-with(@reg,'.'))"><xsl:text>.</xsl:text></xsl:if>
                            <xsl:call-template name="usg_after"/>
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

    <!-- Einfügen von Leerzeichen bzw. Komma, wenn gleiches usg-Element folgt. -->
    <xsl:template name="usg_after">
        <xsl:choose>
            <xsl:when test="empty(following-sibling::wd:usg[@type=./@type or @reg and ./@reg])">
                <xsl:text>&#160;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:text>, </xsl:text>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:ref" mode="global">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="entry" select="/entries/wd:entry[@id=$id]"/>
        <xsl:variable name="title">
            <xsl:choose>
                <xsl:when test="$entry/wd:form/wd:orth[@midashigo]">
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
                <xsl:copy-of select="$title"/>
            </a>
        </div>
    </xsl:template>

    <xsl:template match="wd:ref">
        <xsl:if test="position()>1">
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
                <xsl:when test="@type='alttranscr'">
                    <xsl:attribute name="class">reflink atranscr</xsl:attribute>
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

    <xsl:template match="wd:pos/wd:expl">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="wd:text">
        <span class="text">
            <xsl:if test="@hasPrecedingSpace='true'">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates/>
            <xsl:if test="@hasFollowingSpace='true'">
                <xsl:text> </xsl:text>
            </xsl:if>
        </span>
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
                <xsl:if test="exists(//wd:trans[@langdesc='scientific'])">
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
        <xsl:if test="position()>1">
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
        <xsl:if test="position()>1 and not(starts-with(text(), ','))">
            <xsl:text> </xsl:text>
        </xsl:if>
        <span class="foreign">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="wd:link[@type='picture']">
        <div class="image">
            <img alt="{text()}" src="Images/{@url}.jpg"/>
            <div class="caption"><xsl:value-of select="text()"/></div>
        </div>
    </xsl:template>

    <xsl:template match="wd:link[lower-case(@type)='url']">
        <div class="url">
            <a href="{.}"><xsl:value-of select="."/></a>
        </div>
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
