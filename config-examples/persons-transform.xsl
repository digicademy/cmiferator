<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0">

    <!-- 
    (:
    : CMIFerator
    : Developed by Julian Jarosch
    : Academy of Sciences and Literature | Mainz
    :
    : Stylesheet for transforming ediarum index structures to
    : CMIF-ready entity name elements.
    :
    : @author Julian Jarosch
    : @email <Julian.Jarosch@adwmainz.de>
    : @licence MIT
    :)
    -->



    <!-- O P T I O N S -->

    <xsl:output indent="no" method="xml" omit-xml-declaration="no"/>



    <!-- T E M P L A T E S -->

    <!-- person -->
    
    <xsl:template match="tei:person">
        <xsl:element xmlns="http://www.tei-c.org/ns/1.0" name="persName">
            <xsl:attribute name="ref">
                <!-- select norm data provider with highest priority -->
                <!-- only retain one norm data URI -->
                <xsl:variable name="ref" select="tei:idno[matches(string-join(text(), ''), 'd-nb\.info/gnd/|viaf.org/viaf/|id\.loc\.gov/authorities/|ark\.bnf\.fr/ark:/')][1]"/>
                <!-- make LoC URI scheme conform to correspSearch expectation -->
                <xsl:value-of select="replace($ref, 'id\.loc\.gov/authorities/', 'lccn.loc.gov/')"/>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="tei:persName[@type = 'reg']/tei:name/text()/normalize-space()">
                    <xsl:value-of select="tei:persName[@type = 'reg']/tei:name"/>
                </xsl:when>
                <xsl:when test="tei:persName[@type = 'reg']/(tei:forename | tei:surname)">
                    <xsl:value-of select="tei:persName[@type = 'reg']/tei:forename/text()/normalize-space()"/>
                    <xsl:text> </xsl:text>
                    <xsl:value-of select="tei:persName[@type = 'reg']/tei:surname/text()/normalize-space()"/>
                </xsl:when>
            </xsl:choose>
        </xsl:element>
    </xsl:template>

    <!--<xsl:template match="tei:persName">
        <xsl:variable name="key" select="@key"/>
        <xsl:variable name="ref" select="$persons/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id = $key]/tei:idno[matches(text(), 'd-nb\.info/gnd/|viaf.org/viaf/|id\.loc\.gov/authorities/')][1]/text()/normalize-space()"/>
        <xsl:variable name="name" select="$persons/tei:TEI/tei:text/tei:body/tei:listPerson/tei:person[@xml:id = $key]/tei:persName[@type = 'reg']/normalize-space(string-join((tei:forename, tei:surname, tei:name), ' '))"/>
        <xsl:choose>
            <xsl:when test="lower-case(normalize-space(@key)) = 'nn'">
                <persName xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:text>Unbekannt</xsl:text>
                </persName>
            </xsl:when>
            <xsl:when test="lower-case(normalize-space(.)) = 'nn'">
                <persName xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:attribute name="ref">
                        <xsl:value-of select="@key"/>
                    </xsl:attribute>
                    <xsl:text>Unbekannt</xsl:text>
                </persName>
            </xsl:when>
            <xsl:otherwise>
                <persName xmlns="http://www.tei-c.org/ns/1.0">
                    <xsl:if test="$ref != ''">
                        <xsl:attribute name="ref">
                            <xsl:value-of select="$ref"/>
                        </xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="$name"/>
                </persName>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>-->

</xsl:stylesheet>