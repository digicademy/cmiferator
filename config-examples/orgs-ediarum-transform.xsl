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

    <!-- organization -->
    
    <xsl:template match="tei:org">
        <xsl:element xmlns="http://www.tei-c.org/ns/1.0" name="orgName">
            <xsl:value-of select="tei:orgName[@type = 'reg']/text()/normalize-space()"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>