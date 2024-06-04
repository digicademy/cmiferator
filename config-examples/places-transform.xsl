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

    <!-- place -->
    
    <xsl:template match="tei:place">
        <xsl:element xmlns="http://www.tei-c.org/ns/1.0" name="placeName">
            <xsl:attribute name="ref">
                <!-- only GeoNames is allowed -->
                <!-- only retain one norm data URI -->
                <xsl:value-of select="tei:idno[matches(text(), 'geonames\.org')][1]/text()/normalize-space()"/>
            </xsl:attribute>
            <xsl:value-of select="tei:placeName[@type = 'reg']/text()/normalize-space()"/>
        </xsl:element>
    </xsl:template>

    <!--<xsl:template match="tei:placeName">
        <xsl:variable name="key" select="@key"/>
        <xsl:variable name="ref" select="$places/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id = $key]/tei:idno[matches(text(), 'geonames.org')][1]/text()/normalize-space()"/>
        <xsl:variable name="name" select="$places/tei:TEI/tei:text/tei:body/tei:listPlace/tei:place[@xml:id = $key]/tei:placeName[@type = 'reg']/text()/normalize-space()"/>
        <placeName xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:if test="$ref != ''">
                <xsl:attribute name="ref">
                    <xsl:value-of select="$ref"/>
                </xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$name"/>
        </placeName>
    </xsl:template>-->

</xsl:stylesheet>