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
    <xsl:include href="gramgrp.xsl"/>

    <xsl:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="UTF-8"
            indent="no"/>

    <!-- Parameter, der bestimmt, ob Untereinträge ihre eigenen Einträge erhalten,
         oder nur im Haupteintrag erscheinen, wenn = yes
    -->
    <xsl:param name="strictSubHeadIndex">no</xsl:param>

    <xsl:param name="skipAppendix">no</xsl:param>

    <xsl:param name="debug">no</xsl:param>

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

    <!-- kennzeichnet den Beginn eines Akzentverlaufs -->
    <xsl:variable name="accent_change_marker" select="'—'"/>

    <!-- lookup key für einträge mit referenzen auf einen Haupteintrag -->
    <xsl:key name="refs" match="wd:entry[./wd:ref[@type='main']]" use="./wd:ref/@id"/>

    <xsl:template match="wd:entries|entries">
        <xsl:if test="$debug = 'yes'">
            <xsl:processing-instruction name="xml-stylesheet">
                <xsl:text>type="text/css" href="813338/Wadoku.css"</xsl:text>
            </xsl:processing-instruction>
        </xsl:if>
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

            <xsl:if test="$skipAppendix ne 'yes'">
                <xsl:call-template name="front"/>
                <xsl:call-template name="image_appendix"/>
                <xsl:call-template name="seasonword_appendix"/>
            </xsl:if>

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
            <xsl:value-of select="replace(./wd:form/wd:reading/wd:hira,'う゛','ゔ')"/>
        </xsl:variable>

        <d:entry id="{@id}" d:title="{$title}">
            <!-- index -->
            <xsl:variable name="idx">
                <xsl:call-template name="build_entry_index">
                    <xsl:with-param name="title" select="$title"/>
                    <xsl:with-param name="yomi" select="$yomi"/>
                </xsl:call-template>
            </xsl:variable>
            <!-- filter index duplicates -->
            <xsl:for-each select="$idx">
                <xsl:copy-of select="d:index[not(preceding-sibling::d:index/@d:value=./@d:value
                 and preceding-sibling::d:index/@d:title=./@d:title and preceding-sibling::d:index/@d:yomi=./@d:yomi)]"/>
            </xsl:for-each>
            <!-- index for subentries -->
            <xsl:if test="$strictSubHeadIndex = 'yes'">
                <xsl:apply-templates mode="subheadindex" select="key('refs',@id)"/>
            </xsl:if>

            <xsl:if test="$strictSubHeadIndex != 'yes'">
                <!-- breadcrumb links to parent(s) -->
                <xsl:if test="./wd:ref[@type='main']">
                    <div class="parentheadword">
                        <xsl:apply-templates mode="parent" select="./wd:ref[@type='main']"/>
                    </div>
                </xsl:if>
            </xsl:if>
            <!-- header -->
            <h1>
                <!-- reading -->
                <span class="headword">
                    <ruby>
                        <rb>
                            <xsl:call-template name="reading_from_extended_yomi"/>
                        </rb>
                        <rt>
                            <xsl:value-of select="./wd:form/wd:reading/wd:romaji"/>
                        </rt>
                    </ruby>
                </span>
                <!-- accent -->
                <xsl:if test="./wd:form/wd:reading/wd:accent">
                    <span class="accents">
                        <xsl:for-each select="./wd:form/wd:reading/wd:accent">
                            <xsl:choose>
                                <xsl:when test="position() = 1">
                                    <small class="accent active" data-accent-id="{position()}">
                                        <xsl:value-of select="."/>
                                    </small>
                                </xsl:when>
                                <xsl:otherwise>
                                    <small class="accent" data-accent-id="{position()}">
                                        <xsl:value-of select="."/>
                                    </small>
                                </xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </span>
                </xsl:if>
                <!-- writing -->
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
            <div class="uid">
                <xsl:value-of select="@id"/>
            </div>
            <!-- meaning -->
            <div class="meaning">
                <!-- grammar group and global etymology-->
                <xsl:if test="./wd:gramGrp or ./wd:etym">
                    <div class="global">
                        <xsl:if test="./wd:gramGrp">
                            <span class="hinshi">
                                <xsl:apply-templates select="./wd:gramGrp"/>
                            </span>
                        </xsl:if>
                        <xsl:apply-templates select="./wd:etym"/>
                    </div>
                </xsl:if>
                <!-- if only one sense, handle usg in sense template -->
                <xsl:apply-templates select="wd:usg"/>
                <xsl:choose>
                    <xsl:when test="./wd:sense/wd:sense">
                        <ol class="master">
                            <xsl:for-each select="./wd:sense">
                                <xsl:apply-templates select="."/>
                            </xsl:for-each>
                        </ol>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:choose>
                            <xsl:when test="count(./wd:sense[not(@related='true')])>1">
                                <ol class="senses">
                                    <xsl:for-each select="./wd:sense">
                                        <xsl:apply-templates select="."/>
                                    </xsl:for-each>
                                </ol>
                            </xsl:when>
                            <xsl:otherwise>
                                <ol class="senses single">
                                    <xsl:for-each select="./wd:sense">
                                        <xsl:apply-templates select="."/>
                                    </xsl:for-each>
                                </ol>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
                <!-- note about typical spelling mistakes -->
                <xsl:if test="./wd:form/wd:orth[@type='mistake']">
                    <div class="note">
                        <div class="label">
                            <span xml:lang="ja">注意</span>
                            <span xml:lang="de">Hinweis</span>
                        </div>
                        <div class="content">
                            <xsl:text>「</xsl:text>
                            <xsl:apply-templates mode="mistake_note" select="./wd:form/wd:orth[@type='mistake']"/>
                            <xsl:text>」</xsl:text>
                            <span xml:lang="ja">はあやまり。</span>
                            <xsl:choose>
                                <xsl:when test="count(./wd:form/wd:orth[@type='mistake']) > 1">
                                    <span xml:lang="de">sind Falschschreibungen。</span>
                                </xsl:when>
                                <xsl:otherwise>
                                    <span xml:lang="de">ist eine Falschschreibung。</span>
                                </xsl:otherwise>
                            </xsl:choose>

                        </div>
                    </div>
                </xsl:if>
                <!-- synonyms, antonyms, alternate readings, alternate transcriptions -->
                <xsl:apply-templates select="wd:ref[not(@type='main')]"/>
                <!-- URLs, image links -->
                <xsl:apply-templates select="wd:link"/>
                <!-- subentries -->
                <xsl:call-template name="entry_subs"/>
                <!-- general synonyms -->
                <xsl:apply-templates select="./wd:ruigos"/>
            </div>
        </d:entry>
    </xsl:template>

    <xsl:template mode="mistake_note" match="wd:orth[@type='mistake']">
        <xsl:value-of select="."/>
        <xsl:if test="position() lt last()">
            <xsl:text>・</xsl:text>
        </xsl:if>
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
        <!-- Selbstreferenz -->
        <xsl:variable name="id" select="@id"/>
        <xsl:if test="$subs">
            <div class="subentries">
                <!-- Ableitungen -->
                <xsl:variable name="hasei" select="$subs[wd:ref[(
                    @subentrytype='suru' or
                    @subentrytype='shita' or
                    @subentrytype='shite' or
                    @subentrytype='sa' or
                    @subentrytype='mi' or
                    @subentrytype='na' or
                    @subentrytype='ni' or
                    @subentrytype='no' or
                    @subentrytype='kara' or
                    @subentrytype='da' or
                    @subentrytype='de' or
                    @subentrytype='e' or
                    @subentrytype='teki' or
                    @subentrytype='to' or
                    @subentrytype='taru' or
                    @subentrytype='garu' or
                    @subentrytype='ge' or
                    @subentrytype='o' or
                    @subentrytype='ku')
                     and @id=$id]]"/>
                <xsl:if test="$hasei">
                    <span class="label">
                        <b xml:lang="ja">派生語</b>
                        <b xml:lang="de">Ableitungen</b>
                    </span>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[@subentrytype='suru']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[@subentrytype='sa']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$hasei[wd:ref[not(@subentrytype='sa') and not(@subentrytype='suru')]]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                </xsl:if>
                <!-- Komposita -->
                <xsl:variable name="composita"
                              select="$subs[wd:ref[@subentrytype='head' or @subentrytype='tail']]"/>
                <xsl:if test="$composita">
                    <span class="label">
                        <b xml:lang="ja">合成語</b>
                        <b xml:lang="de">Zusammensetzungen</b>
                    </span>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='head']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='tail']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                </xsl:if>
                <!-- Rest -->
                <xsl:if test="(count($subs) - count($hasei) - count($composita)) > 0">
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='VwBsp']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[@subentrytype='XSatz']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
                    </xsl:apply-templates>
                    <xsl:apply-templates mode="subentry"
                                         select="$subs[wd:ref[
                                         @subentrytype='WIdiom'
                                         or @subentrytype='ZSprW'
                                         or @subentrytype='other']]">
                        <xsl:sort select="./wd:form/wd:reading/wd:hira/text()"/>
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
        <xsl:analyze-string select="."
                            regex="△(.)|/([×△])|×(.)|〈(.*?)〉|｛(.*?)｝|（([^（）]*?)）|（（([^（）]*?)）([^（）]*?)）">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(1)">
                        <span class="njok"><!-- non joyo on/kun -->
                            <xsl:value-of select="regex-group(1)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(2)">
                        <!-- pass through ×△ when escaped by slash -->
                        <xsl:value-of select="regex-group(2)"/>
                    </xsl:when>
                    <xsl:when test="regex-group(3)">
                        <span class="njk"><!-- non joyo kanji -->
                            <xsl:value-of select="regex-group(3)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(4)">
                        <span class="jjk"><!-- jukujikun joyo kanji -->
                            <xsl:value-of select="regex-group(4)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(5)">
                        <span class="fjjk"><!-- fuhyo jukujikun joyo kanji -->
                            <xsl:value-of select="regex-group(5)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(6)">
                        <span class="paren">
                            <xsl:value-of select="regex-group(6)"/>
                        </span>
                    </xsl:when>
                    <xsl:when test="regex-group(7)">
                        <span class="paren">
                            <span class="paren">
                                <xsl:value-of select="regex-group(7)"/>
                            </span>
                            <xsl:value-of select="regex-group(8)"/>
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
        <xsl:param name="hatsuon" select="./wd:form/wd:reading/wd:hatsuon"/>
        <xsl:param name="accent" select="./wd:form/wd:reading/wd:accent"/>
        <xsl:variable name="yomi">
            <!--
                  * entferne störende Symbole
                  * typographische Korrekturen/Vereinheitlichung
                  * behalte fullwidth space für differenzierte $accent_change_marker Konversion
                -->
            <xsl:value-of select="
                                    replace(
                                    translate(
                                    translate(
                                    replace(
                                    replace($hatsuon,'\[Akz\]',$accent_change_marker),
                                    'DinSP','･'),
                                    '&lt;>/[]1234567890: GrJoDevNinSsuPWap_＿',''),
                                    &quot;・·'’&quot;, '･･￨￨'),
                                    'う゛','ゔ')
                                "/>
        </xsl:variable>

        <xsl:choose>
            <xsl:when test="$accent">
                <xsl:for-each select="$accent">
                    <xsl:choose>
                        <xsl:when test="position() = 1">
                            <span class="pron accent" data-accent-id="{position()}">
                                <xsl:call-template name="call_mark_accent">
                                    <xsl:with-param name="yomi" select="$yomi"/>
                                </xsl:call-template>
                            </span>
                        </xsl:when>
                        <xsl:otherwise>
                            <span class="pron accent hidden" data-accent-id="{position()}">
                                <xsl:call-template name="call_mark_accent">
                                    <xsl:with-param name="yomi" select="$yomi"/>
                                </xsl:call-template>
                            </span>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="insert_divider">
                    <!-- entferne nicht benötigtes full-width space -->
                    <xsl:with-param name="t"
                                    select="translate($yomi, '　', '')"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="call_mark_accent">
        <xsl:param name="yomi"/>
        <xsl:choose>
            <!-- Akzentangabe mit mehrfachem Akzentwechsel -->
            <xsl:when test="contains(., '—')">
                <!-- Auftrennen der Lesung am accent_change_marker -->
                <xsl:variable name="y" select="tokenize($yomi,$accent_change_marker)"/>
                <!--
                    Auftrennen Akzentangaben am 'em dash' und markiere den Akzent für
                    den korrespondierenden Lesungsteil.
                -->
                <xsl:for-each select="tokenize(.,'—')">
                    <xsl:variable name="pos" select="position()"/>
                    <xsl:variable name="yomi_part">
                        <xsl:value-of select="$y[$pos]"/>
                        <!-- middle dot nur für leerzeichenlose Teile -->
                        <xsl:if test="position() &lt; last() and not(ends-with($y[$pos], '　'))">
                            <xsl:text>･</xsl:text>
                        </xsl:if>
                    </xsl:variable>
                    <xsl:call-template name="mark_accent">
                        <xsl:with-param name="accent"
                                        select="number(.)"/>
                        <!-- entferne nicht mehr benötigtes full-width space -->
                        <xsl:with-param name="yomi"
                                        select="translate($yomi_part, '　', '')"/>
                    </xsl:call-template>
                </xsl:for-each>
            </xsl:when>
            <xsl:otherwise>
                <!-- Akzentangabe mit einfachem Akzentwechsel -->
                <xsl:call-template name="mark_accent">
                    <xsl:with-param name="accent"
                                    select="number(.)"/>
                    <!-- konvertiere accent_change_marker in einfachen halfwidth middle dot -->
                    <!-- entferne nicht mehr benötigtes full-width space -->
                    <xsl:with-param name="yomi"
                                    select="translate(
                                    translate($yomi, $accent_change_marker,'･'),
                                    '　', '')"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="mark_accent">
        <xsl:param name="accent"/>
        <xsl:param name="yomi"/>
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
        <!-- erste More aus zwei Kana, z.B. しゃ -->
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
                        <!-- String nach erstem Kana ohne Nicht-Kana-Zeichen bis Akzent - 1, da bei zweitem Kana beginnend-->
                        <xsl:variable name="str1"
                                      select="substring($hiragana,2,string-length($hiragana))"/>
                        <!-- String nach erstem Kana bis Akzent -->
                        <xsl:variable name="temp" select="wd:get_accented_part($str1, $accent)"/>
                        <!-- Anzahl der nicht als Mora zählenden Zeichen -->
                        <xsl:variable name="count"
                                      select="string-length($temp)-string-length(translate($temp,$letters,''))"/>
                        <!-- Länge des Strings nach der Akzentuierung -->
                        <xsl:variable name="trail"
                                      select="string-length(substring-after($str1, $temp))"/>
                        <xsl:choose>
                            <xsl:when test="$trail=0">
                                <span class="t r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana, 2, $count + $accent)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana, 2 + $count + $accent)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:when>
                            <xsl:otherwise>
                                <span class="t r">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana, 2, $count + $accent - 1)"/>
                                    </xsl:call-template>
                                </span>
                                <span class="b">
                                    <xsl:call-template name="insert_divider">
                                        <xsl:with-param name="t"
                                                        select="substring($hiragana, 2 + $count + $accent - 1)"/>
                                    </xsl:call-template>
                                </span>
                            </xsl:otherwise>
                        </xsl:choose>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:sense/wd:accent">
        <!-- Akzent nur verarbeiten durch explizites Aufrufen von sense_accent -->
    </xsl:template>

    <xsl:template name="sense_accent">
        <xsl:if test="./wd:accent">
            <xsl:for-each select="./wd:accent">
                <span class="senseaccent" title="Akzent/アクセント">
                    <xsl:value-of select="."/>
                </span>
            </xsl:for-each>
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- subentry -->
    <xsl:template mode="subentry" match="wd:entry">
        <xsl:variable name="title">
            <xsl:call-template name="get_subentry_title">
                <xsl:with-param name="entry" select="."/>
            </xsl:call-template>
        </xsl:variable>
        <div class="subheadword" id="{@id}">
            <xsl:call-template name="get_subentry_type"/>
            <xsl:variable name="isHaseigo">
                <xsl:choose>
                    <xsl:when test="count(wd:ref[
                    not(@subentrytype='head')
                    and not(@subentrytype='tail')
                    and not(@subentrytype='VwBsp')
                    and not(@subentrytype='WIdiom')
                    and not(@subentrytype='XSatz')
                    and not(@subentrytype='ZSprW')
                    and not(@subentrytype='other')
                    ]) > 0">
                        <xsl:call-template name="get_short_hasei">
                            <xsl:with-param name="type" select="wd:ref/@subentrytype"/>
                        </xsl:call-template>
                    </xsl:when>
                </xsl:choose>
            </xsl:variable>
            <!-- Untereintrag hat Untereinträge? dann als Link -->
            <ruby>
                <xsl:if test="string-length($isHaseigo) > 0">
                    <xsl:attribute name="class" select="'long'"/>
                </xsl:if>
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
            <xsl:if test="string-length($isHaseigo) > 0">
                <ruby class="short">
                    <rb>
                        <xsl:choose>
                            <xsl:when test="key('refs', @id)">
                                <a href="x-dictionary:r:{@id}">
                                    <xsl:value-of select="concat('〜', $isHaseigo)"/>
                                </a>
                            </xsl:when>
                            <xsl:otherwise>
                                <xsl:value-of select="concat('〜', $isHaseigo)"/>
                            </xsl:otherwise>
                        </xsl:choose>
                    </rb>
                </ruby>
            </xsl:if>
            <xsl:text>｜</xsl:text>
            <xsl:choose>
                <xsl:when test="./wd:sense/wd:sense">
                    <ol class="master">
                        <xsl:for-each select="./wd:sense">
                            <xsl:apply-templates mode="compact" select="."/>
                        </xsl:for-each>
                    </ol>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:choose>
                        <xsl:when test="count(./wd:sense[not(@related='true')])>1">
                            <ol class="senses">
                                <xsl:for-each select="./wd:sense">
                                    <xsl:apply-templates mode="compact" select="."/>
                                </xsl:for-each>
                            </ol>
                        </xsl:when>
                        <xsl:otherwise>
                            <ol class="senses single">
                                <xsl:for-each select="./wd:sense">
                                    <xsl:apply-templates mode="compact" select="."/>
                                </xsl:for-each>
                            </ol>
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:otherwise>
            </xsl:choose>
        </div>
    </xsl:template>

    <xsl:template name="get_subentry_title">
        <xsl:param name="entry"/>
        <xsl:choose>
            <xsl:when test="$entry/wd:form/wd:orth[@midashigo]">
                <xsl:apply-templates mode="simple" select="$entry/wd:form/wd:orth[@midashigo][1]"/>
            </xsl:when>
            <xsl:when test="$entry/wd:form/wd:orth[not(@irr)]">
                <xsl:apply-templates mode="simple" select="$entry/wd:form/wd:orth[not(@irr) and not(@midashigo)][1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="simple" select="$entry/wd:form/wd:orth[1]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get_short_hasei">
        <xsl:param name="type"/>
        <xsl:choose>
            <xsl:when test="$type='sa'">
                <xsl:text>さ</xsl:text>
            </xsl:when>
            <xsl:when test="$type='suru'">
                <xsl:text>する</xsl:text>
            </xsl:when>
            <xsl:when test="$type='na'">
                <xsl:text>な</xsl:text>
            </xsl:when>
            <xsl:when test="$type='ni'">
                <xsl:text>に</xsl:text>
            </xsl:when>
            <xsl:when test="$type='no'">
                <xsl:text>の</xsl:text>
            </xsl:when>
            <xsl:when test="$type='da'">
                <xsl:text>だ</xsl:text>
            </xsl:when>
            <xsl:when test="$type='de'">
                <xsl:text>で</xsl:text>
            </xsl:when>
            <xsl:when test="$type='kara'">
                <xsl:text>から</xsl:text>
            </xsl:when>
            <xsl:when test="$type='e'">
                <xsl:text>へ</xsl:text>
            </xsl:when>
            <xsl:when test="$type='shite'">
                <xsl:text>して</xsl:text>
            </xsl:when>
            <xsl:when test="$type='shita'">
                <xsl:text>した</xsl:text>
            </xsl:when>
            <xsl:when test="$type='teki'">
                <xsl:text>的</xsl:text>
            </xsl:when>
            <xsl:when test="$type='to'">
                <xsl:text>と</xsl:text>
            </xsl:when>
            <xsl:when test="$type='taru'">
                <xsl:text>たる</xsl:text>
            </xsl:when>
            <xsl:when test="$type='garu'">
                <xsl:text>がる</xsl:text>
            </xsl:when>
            <xsl:when test="$type='ge'">
                <xsl:text>げ</xsl:text>
            </xsl:when>
            <xsl:when test="$type='ku'">
                <xsl:text>く</xsl:text>
            </xsl:when>
            <xsl:when test="$type='mi'">
                <xsl:text>み</xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="get_subentry_type">
        <xsl:choose>
            <xsl:when test="wd:ref[@subentrytype='head']">
                <xsl:if test="position()=1">
                    <div>►</div>
                </xsl:if>
                <xsl:text>　</xsl:text>
            </xsl:when>
            <xsl:when test="wd:ref[@subentrytype='tail']">
                <xsl:if test="position()=1">
                    <div>◀</div>
                </xsl:if>
                <xsl:text>　</xsl:text>
            </xsl:when>
            <xsl:when test="wd:ref[@subentrytype='VwBsp']">
                <xsl:if test="position()=1">
                    <div>◇</div>
                </xsl:if>
                <xsl:text>　</xsl:text>
            </xsl:when>
            <xsl:when
                    test="wd:ref[@subentrytype='WIdiom' or @subentrytype='ZSprW' or @subentrytype='other' or @subentrytype='XSatz']">
                <xsl:if test="position()=1">
                    <div>&#160;</div>
                </xsl:if>
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
        <xsl:variable name="yomi" select="./wd:form/wd:reading/wd:hira"/>
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
        <xsl:choose>
            <xsl:when test="./wd:sense">
                <li class="master sense">
                    <xsl:call-template name="sense_accent"/>
                    <xsl:apply-templates select="./wd:descr"/>
                    <xsl:choose>
                        <xsl:when test="count(./wd:sense[not(@related)])>1">
                            <ol class="senses">
                                <xsl:for-each select="./wd:sense">
                                    <xsl:apply-templates mode="compact" select="."/>
                                </xsl:for-each>
                            </ol>
                        </xsl:when>
                        <xsl:otherwise>
                            <ol class="senses single">
                                <xsl:apply-templates mode="compact" select="./wd:sense"/>
                            </ol>
                        </xsl:otherwise>
                    </xsl:choose>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="../wd:usg"/>
            </xsl:otherwise>
        </xsl:choose>

        <xsl:call-template name="sense_content"/>
    </xsl:template>

    <xsl:template mode="compact" match="wd:sense[empty(./wd:sense) and not(@related)]">
        <xsl:call-template name="sense_accent"/>
        <xsl:apply-templates select="./wd:descr"/>
        <xsl:choose>
            <xsl:when test="following-sibling::wd:sense[1][@related]">
                <li>
                    <xsl:variable name="this_sense" select="."/>
                    <ul class="related">
                        <!-- this sense -->
                        <li class="sense">
                            <xsl:call-template name="sense_content"/>
                        </li>
                        <!-- all following @related senses, in particular
                        * directly following sense
                        * related sense with a directly preceding related sense
                        -->
                        <xsl:for-each
                                select="following-sibling::wd:sense[
                                @related and (
                                preceding-sibling::wd:sense[1]=$this_sense or preceding-sibling::wd:sense[1][@related])
                                ]">
                            <li class="sense related">
                                <xsl:call-template name="sense_content"/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li class="sense">
                    <xsl:call-template name="sense_content"/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <xsl:template mode="compact" match="wd:sense[empty(./wd:sense) and @related]"/>

    <xsl:template name="sense_content">
        <xsl:apply-templates select="wd:usg"/>
        <xsl:apply-templates select="wd:trans"/>
        <xsl:if test="./wd:seasonword">
            <xsl:apply-templates select="./wd:seasonword"/>
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

    <!--
         general sense handling
    
    -->


    <!-- Mastersense -->
    <xsl:template match="wd:sense[./wd:sense]">
        <li class="master sense">
            <xsl:call-template name="sense_accent"/>
            <xsl:apply-templates select="./wd:descr"/>
            <xsl:choose>
                <xsl:when test="count(./wd:sense[not(@related)])>1">
                    <ol class="senses">
                        <xsl:for-each select="./wd:sense">
                            <xsl:apply-templates select="."/>
                        </xsl:for-each>
                    </ol>
                </xsl:when>
                <xsl:otherwise>
                    <ol class="senses single">
                        <xsl:apply-templates select="./wd:sense"/>
                    </ol>
                </xsl:otherwise>
            </xsl:choose>
        </li>
    </xsl:template>

    <!--
    Senses ohne Mastersense und nicht @related
    -->
    <xsl:template match="wd:sense[empty(./wd:sense) and not(@related)]">
        <xsl:choose>
            <xsl:when test="following-sibling::wd:sense[1][@related]">
                <li>
                    <xsl:variable name="this_sense" select="."/>
                    <ul class="related">
                        <!-- this sense -->
                        <li class="sense">
                            <xsl:call-template name="sense_accent"/>
                            <xsl:apply-templates select="./wd:descr"/>
                            <xsl:apply-templates mode="core" select="."/>
                        </li>
                        <!-- all following @related senses, in particular
                        * directly following sense
                        * related sense with a directly preceding related sense
                        -->
                        <xsl:for-each
                                select="following-sibling::wd:sense[
                                @related and (
                                preceding-sibling::wd:sense[1]=$this_sense or preceding-sibling::wd:sense[1][@related])
                                ]">
                            <li class="sense related">
                                <xsl:call-template name="sense_accent"/>
                                <xsl:apply-templates select="./wd:descr"/>
                                <xsl:apply-templates mode="core" select="."/>
                            </li>
                        </xsl:for-each>
                    </ul>
                </li>
            </xsl:when>
            <xsl:otherwise>
                <li class="sense">
                    <xsl:call-template name="sense_accent"/>
                    <xsl:apply-templates select="./wd:descr"/>
                    <xsl:apply-templates mode="core" select="."/>
                </li>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="wd:sense[empty(./wd:sense) and @related]"/>

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
                            <xsl:if test="position()&lt;last()">
                                <xsl:text>; </xsl:text>
                            </xsl:if>
                        </xsl:for-each>
                        <xsl:text>)</xsl:text>
                    </span>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="wd:usg"/>
                <xsl:apply-templates select="wd:trans"/>
                <xsl:if test="wd:seasonword">
                    <xsl:apply-templates select="wd:seasonword"/>
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
        <xsl:apply-templates select="./wd:link[@type='picture']"/>
    </xsl:template>

    <xsl:template match="wd:seasonword">
        <xsl:choose>
            <xsl:when test="@type='spring'">
                <xsl:call-template name="season-template">
                    <xsl:with-param name="ja">春</xsl:with-param>
                    <xsl:with-param name="de">Frühling</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type='summer'">
                <xsl:call-template name="season-template">
                    <xsl:with-param name="ja">夏</xsl:with-param>
                    <xsl:with-param name="de">Sommer</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type='autumn'">
                <xsl:call-template name="season-template">
                    <xsl:with-param name="ja">秋</xsl:with-param>
                    <xsl:with-param name="de">Herbst</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type='winter'">
                <xsl:call-template name="season-template">
                    <xsl:with-param name="ja">冬</xsl:with-param>
                    <xsl:with-param name="de">Winter</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="@type='newyear'">
                <xsl:call-template name="season-template">
                    <xsl:with-param name="ja">新年</xsl:with-param>
                    <xsl:with-param name="de">Neujahr</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="season-template">
        <xsl:param name="ja"/>
        <xsl:param name="de"/>
        <span class="season {@type}" xml:lang="ja" title="季語">
            <xsl:if test="@part">
                <xsl:choose>
                    <xsl:when test="@part='bud'">
                        <xsl:text>芽 </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='flower'">
                        <xsl:text>花 </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='fruit'">
                        <xsl:text>実 </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='leaf'">
                        <xsl:text>葉 </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:value-of select="$ja"/>
        </span>
        <span class="season {@type}" xml:lang="de" title="Jahreszeitenwort">
            <xsl:if test="@part">
                <xsl:choose>
                    <xsl:when test="@part='bud'">
                        <xsl:text>Knospe </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='flower'">
                        <xsl:text>Blüte </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='fruit'">
                        <xsl:text>Frucht </xsl:text>
                    </xsl:when>
                    <xsl:when test="@part='leaf'">
                        <xsl:text>Blatt </xsl:text>
                    </xsl:when>
                </xsl:choose>
            </xsl:if>
            <xsl:value-of select="$de"/>
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
            <xsl:when test="@numerus='sg'">
                <xsl:text>Singularetantum</xsl:text>
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
            <xsl:when test="@numerus='sg'">
                <xsl:text>絶対単数</xsl:text>
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
                <xsl:text>sächlich oder weiblich</xsl:text>
            </xsl:when>
            <xsl:when test="@genus='mnf'">
                <xsl:text>männlich oder sächlich oder weiblich</xsl:text>
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
            <xsl:when test="@genus='mnf'">
                <xsl:text>男性／中性／女性</xsl:text>
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
                <span class="dom">
                    <xsl:apply-templates/>
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
                            <xsl:if test="lower-case(@reg)=@reg and not(ends-with(@reg,'.'))">
                                <xsl:text>.</xsl:text>
                            </xsl:if>
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


    <!-- breadcrumps to parent(s) -->
    <xsl:template match="wd:ref" mode="parent">
        <xsl:variable name="id" select="@id"/>
        <xsl:variable name="entry" select="//wd:entry[@id = $id]"/>
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

        <!-- if parent has parent, log self reference -->
        <xsl:if test="$entry/wd:ref[@type='main' and $id = @id]">
            <xsl:message>
                <xsl:text>self-reference: </xsl:text>
                <xsl:value-of select="$id"/>
            </xsl:message>
        </xsl:if>
        <xsl:if test="$entry/wd:ref[@type='main' and $id != @id]">
            <span class="parents parent">
                <xsl:apply-templates mode="parent" select="$entry/wd:ref[@type='main']"/>
            </span>
        </xsl:if>

        <a href="x-dictionary:r:{@id}" class="reflink parent">
            <xsl:copy-of select="$title"/>
        </a>
        <xsl:if test="position() lt last()">
            <xsl:text>・</xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- reference links -->
    <xsl:template match="wd:ref">
        <xsl:if test="position()>1">
            <xsl:text> </xsl:text>
        </xsl:if>
        <a href="x-dictionary:r:{@id}" title="{./wd:jap}" class="reflink {@type}">
            <xsl:apply-templates select="./wd:transcr"/>
            <xsl:apply-templates select="./wd:jap"/>
        </a>
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
            <div class="caption">
                <xsl:value-of select="text()"/>
            </div>
        </div>
    </xsl:template>

    <xsl:template match="wd:link[@type='url']">
        <div class="url">
            <xsl:choose>
                <!-- current standard case
                <link type="url" url="http://www.foo.bar/"/>
                 -->
                <xsl:when test="@url">
                    <a href="{@url}">
                        <xsl:value-of select='@url'/>
                    </a>
                </xsl:when>
                <!-- legacy support
                 <link type="url">http://www.hoge.piyo/</link><
                -->
                <xsl:when test="string-length(.) > 0">
                    <a href="{.}">
                        <xsl:value-of select='.'/>
                    </a>
                </xsl:when>
                <xsl:otherwise>
                    <!-- safe guard -->
                </xsl:otherwise>
            </xsl:choose>
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

    <xsl:template match="wd:ruigos">
        <div class="ruigos">
            <span class="label" xml:lang="ja">
                <b>類語</b>
            </span>
            <span class="label" xml:lang="de">
                <b>Synonyme</b>
            </span>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="wd:ruigo">
        <xsl:variable name="id" select="./@id"/>
        <xsl:variable name="ruigo_entry" select="//wd:entry[@id eq $id]"/>
        <ruby>
            <rb>
                <a class="ruigo" href="x-dictionary:r:{./@id}">
                    <xsl:call-template name="get_subentry_title">
                        <xsl:with-param name="entry" select="$ruigo_entry"/>
                    </xsl:call-template>
                </a>
            </rb>
            <rt>
                <xsl:call-template name="reading_from_extended_yomi">
                    <xsl:with-param name="hatsuon" select="$ruigo_entry/wd:form/wd:reading/wd:hatsuon"/>
                    <xsl:with-param name="accent" select="$ruigo_entry/wd:form/wd:reading/wd:accent"/>
                </xsl:call-template>
            </rt>
        </ruby>
        <xsl:if test="position() lt last()">
            <xsl:text>・</xsl:text>
        </xsl:if>
    </xsl:template>

    <xsl:template match="wd:*">
        <span class="{name(.)}">
            <xsl:apply-templates/>
        </span>
    </xsl:template>
</xsl:stylesheet>
