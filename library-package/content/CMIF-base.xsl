<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:c8r="http://www.digitale-akademie.de/cmiferator" exclude-result-prefixes="#all" version="3.0">
    
    <!-- 
    (:
    : CMIFerator
    : 
    : Developed by Julian Jarosch
    : Academy of Sciences and Literature | Mainz
    : Digital Academy
    :
    : Base template of a CMIF file.
    :
    : @author Julian Jarosch
    : @email <Julian.Jarosch@adwmainz.de>
    : @licence MIT
    :)
    -->
    
    
    
    <!-- O P T I O N S -->
    
    <xsl:output indent="yes" method="xml" version="1.0" encoding="UTF-8" omit-xml-declaration="no"/>
    
    
    
    <!-- P A R A M E T E R S -->
    
    <!-- get configuration file path -->
    <xsl:param name="config-filepath"/>
    
    
    
    <!-- V A R I A B L E S -->
    
    <!-- load configuration file and immediately select relevant node -->
    <xsl:variable name="config" select="doc($config-filepath)/c8r:configuration/c8r:header"/>
    
    
    
    <!-- T E M P L A T E -->
    
    <xsl:template match="/">
        <xsl:processing-instruction name="xml-model">href="https://raw.githubusercontent.com/TEI-Correspondence-SIG/CMIF/master/schema/cmi-customization.rng" type="application/xml" schematypens="http://relaxng.org/ns/structure/1.0"</xsl:processing-instruction>
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title>
                            <xsl:value-of select="normalize-space( string-join( $config/c8r:title/child::text() ) )"/>
                        </title>
                        <editor>
                            <xsl:copy-of select="$config/c8r:editor/child::node()"/>
                        </editor>
                    </titleStmt>
                    <publicationStmt>
                        <publisher>
                            <xsl:copy-of select="$config/c8r:publisher/child::element()"/>
                        </publisher>
                        <idno type="url">
                            <xsl:value-of select="$config/c8r:url/child::text()"/>
                        </idno>
                        <date>
                            <xsl:attribute name="when">
                                <!-- get system date-time and format as date -->
                                <xsl:value-of select="adjust-date-to-timezone(current-date(), ())"/>
                            </xsl:attribute>
                        </date>
                        <availability>
                            <licence target="https://creativecommons.org/licenses/by/4.0/">This file is licensed under the terms of the Creative-Commons-License CC BY 4.0</licence>
                        </availability>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl type="online">
                            <xsl:attribute name="xml:id">
                                <xsl:value-of select="$config/c8r:uuid/child::text()"/>
                            </xsl:attribute>
                            <xsl:copy-of select="$config/c8r:source/child::node()"/>
                        </bibl>
                    </sourceDesc>
                </fileDesc><xsl:text>
        </xsl:text>
                <xsl:comment>this CMIF was wrapped by the CMIFerator</xsl:comment><xsl:text>
        </xsl:text>
                <xsl:comment>https://github.com/digicademy/cmiferator</xsl:comment>
                <profileDesc>
                    <xsl:copy-of select="descendant-or-self::tei:correspDesc"/>
                </profileDesc>
            </teiHeader>
            <text>
                <body>
                    <p/>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
</xsl:stylesheet>