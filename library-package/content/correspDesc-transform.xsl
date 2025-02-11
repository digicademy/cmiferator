<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c8r="http://www.digitale-akademie.de/cmiferator" exclude-result-prefixes="#all" version="3.0">
    
    <!-- 
    (:
    : CMIFerator
    : 
    : Developed by Julian Jarosch
    : Academy of Sciences and Literature | Mainz
    : Digital Academy
    :
    : Stylesheet for transforming TEI P5 to the CMIF subset.
    :
    : @author Julian Jarosch
    : @email <Julian.Jarosch@adwmainz.de>
    : @licence MIT
    :)
    -->
    
    
    
    <!-- O P T I O N S -->
    
    <xsl:output indent="yes" method="xml" omit-xml-declaration="yes"/>
    
    
    
    <!-- P A R A M E T E R S -->
    
    <!-- get configuration file path -->
    <xsl:param name="config-filepath"/>
    
    
    
    <!-- V A R I A B L E S -->
    
    <!-- load configuration file -->
    <xsl:variable name="config" select="doc($config-filepath)/c8r:configuration"/>
    <xsl:variable name="unknown"><xsl:text>Unbekannt</xsl:text></xsl:variable>
    <xsl:variable name="date_regex"><xsl:text>^\d{4}(-\d{2}){0,2}$</xsl:text></xsl:variable>
    
    
    <!-- T E M P L A T E S -->
    
    <!-- root -->
    
    <xsl:template match="/">
        <!-- this specifies the “usual” practice and might potentially exclude TEI Corpus or TEI nested within tei:text -->
        <xsl:apply-templates select="tei:TEI/tei:teiHeader/tei:profileDesc/tei:correspDesc"/>
    </xsl:template>
    
    
    <!-- correspDesc -->
    
    <xsl:template match="tei:correspDesc[1]">
        <correspDesc xmlns="http://www.tei-c.org/ns/1.0" source="#{$config/c8r:header/c8r:uuid/child::text()}">
            <xsl:attribute name="ref">
                <!-- concatenate the permalink from a namespace / base URL and the xml:id of the file -->
                <!-- TODO: it may be better to not do this, and instead take the complete permalink from an <idno> within the file -->
                <!-- if the latter, that may need to be configured using an XPath -->
                <xsl:value-of select="$config/c8r:namespace/child::text() || ./ancestor::tei:TEI/@xml:id"/>
            </xsl:attribute>
            <!-- correspAction[@type = 'sent'] must always be included -->
            <xsl:if test="not(tei:correspAction[@type = 'sent'])">
                <correspAction type="sent">
                    <persName><xsl:value-of select="$unknown"/></persName>
                </correspAction>
            </xsl:if>
            <!-- correspAction[@type = 'received'] must always be included -->
            <xsl:if test="not(tei:correspAction[@type = 'received'])">
                <correspAction type="received">
                    <persName><xsl:value-of select="$unknown"/></persName>
                </correspAction>
            </xsl:if>
            <xsl:apply-templates select="(tei:correspAction | tei:note)"/>
        </correspDesc>
    </xsl:template>
    <!-- only keep one correspDesc per file (pick the first one) -->
    <xsl:template match="tei:correspDesc[position() &gt; 1]"/>
    
    
    <!-- correspAction -->
    
    <xsl:template match="tei:correspAction">
        <!-- only correspActions sent and received are allowed in CMIF – discard all others -->
        <xsl:if test="@type = ('sent', 'received')">
            <xsl:variable name="type" select="@type"/>
            <correspAction xmlns="http://www.tei-c.org/ns/1.0" type="{$type}">
                <!-- if no persName element is present, a “dummy” element with a fixed content needs to be inserted -->
                <xsl:if test="not(tei:persName)">
                    <persName><xsl:value-of select="$unknown"/></persName>
                </xsl:if>
                <xsl:apply-templates select="(tei:date | tei:persName | tei:orgName | tei:placeName)"/>
            </correspAction>
        </xsl:if>
    </xsl:template>
    
    
    <!-- date -->
    
    <xsl:template match="tei:date[1]">
        <!-- check if any of the dating attributes are present and not empty -->
        <xsl:if test="normalize-space(string-join(@when | @from | @to | @notBefore | @notAfter))">
            <!-- restrict to allowed combinations of attributes -->
            <!-- at the same time, check conformance of attribute content to date format (RegEx) -->
            <xsl:choose>
                <xsl:when test="matches(@when, $date_regex) and not(matches(@from, $date_regex)) and not(matches(@to, $date_regex)) and not(matches(@notBefore, $date_regex)) and not(matches(@notAfter, $date_regex))">
                    <!-- only @when -->
                    <date xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:copy select="@when"/>
                    </date>
                </xsl:when>
                <xsl:when test="(matches(@from, $date_regex) or matches(@to, $date_regex)) and not(matches(@notBefore, $date_regex)) and not(matches(@notAfter, $date_regex))">
                    <!-- one or two out of @from and @to -->
                    <date xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:apply-templates select="@from"/>
                        <xsl:apply-templates select="@to"/>
                    </date>
                </xsl:when>
                <xsl:when test="matches(@notBefore, $date_regex) or matches(@notAfter, $date_regex)">
                    <!-- one or two out of @notBefore and @notAfter -->
                    <date xmlns="http://www.tei-c.org/ns/1.0">
                        <xsl:apply-templates select="@notBefore"/>
                        <xsl:apply-templates select="@notAfter"/>
                    </date>
                </xsl:when>
                <!-- if there is an unexpected combination of attributes – e.g. a well-formed @from and a well-formed @notAfter – no <date> will be output -->
            </xsl:choose>
            
        </xsl:if>
    </xsl:template>
    <!-- only keep one date per correspAction (pick the first one) -->
    <xsl:template match="tei:correspAction/tei:date[position() &gt; 1]"/>
    
    <!-- date attributes -->
    
    <xsl:template match="tei:date/(@from | @to | @notBefore | @notAfter)">
        <xsl:if test="matches(., $date_regex)">
            <xsl:copy/>
        </xsl:if>
    </xsl:template>
    
    <!-- persName -->
    
    <xsl:template match="tei:persName">
        <persName xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="normalize-space(@ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="@ref"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </persName>
    </xsl:template>
    
    
    <!-- orgName -->
    
    <xsl:template match="tei:orgName">
        <orgName xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="normalize-space(@ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="@ref"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </orgName>
    </xsl:template>
    
    
    <!-- placeName -->
    
    <xsl:template match="tei:placeName">
        <placeName xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="normalize-space(@ref)">
                <xsl:attribute name="ref">
                    <xsl:value-of select="@ref"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="."/>
        </placeName>
    </xsl:template>
    
    
    <!-- note -->
    
    <xsl:template match="tei:note[1]">
        <xsl:if test="./tei:ref[@type][@target]">
            <note xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:apply-templates select="tei:ref"/>
            </note>
        </xsl:if>
    </xsl:template>
    <xsl:template match="tei:note[position() &gt; 1]"/>
    
    
    <!-- ref -->
    
    <xsl:template match="tei:ref">
        <xsl:if test=".[matches(@type, '^https://lod.academy/cmif/vocab/terms#')][normalize-space(@target)]">
            <ref xmlns="http://www.tei-c.org/ns/1.0">
                <xsl:attribute name="type">
                    <xsl:value-of select="@type"/>
                </xsl:attribute>
                <xsl:attribute name="target">
                    <xsl:value-of select="@target"/>
                </xsl:attribute>
                <xsl:value-of select="."/>
            </ref>
        </xsl:if>
    </xsl:template>
    
    
</xsl:stylesheet>