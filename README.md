# CMIFerator

Generate [CMIF (Correspondence Metadata Interchange File)](https://correspsearch.net/en/documentation.html) from [eXist-db](http://exist-db.org/) based editions of letters (e.g. using [ediarum](https://www.ediarum.org/)) ready for ingest in [correspSearch](https://correspsearch.net/).

The CMIFerator is a library of XQuery functions you can use to build your own CMIF API endpoint. A minimal example of an endpoint is given below.

The CMIFerator is released as an eXist-db library package that can be installed using the eXist-db package manager. Its tested and intended environment is eXist-db.

Currently, the CMIFerator supports CMIF version 1.

The XSLT stylesheet which subsets TEI `<correspDesc>` elements for (strict) conformance to CMIF (version 1) may possibly be of interest outside of the CMIFerator, as a starting point for more individualised purposes. (However, currently it depends on the configuration file specific to the CMIFerator.)

## Documentation

The CMIFerator covers the following processing steps from normalised letter data to CMIF file:

1. Update `<correspAction>` elements in individual letter files with the most up-to-date information from index files (regularised person names, person identifiers, regularised place names …).
2. Subset `<correspDesc>` elements in individual letter files for (strict) conformance to the CMIF standard.
3. Wrap `<correspDesc>` elements in a CMIF template and fill in metadata.

Other steps you might require may, of course, be added individually into the endpoint – for example, the selection of which files to include into the CMIF.

### Functions

The CMIFerator is developed as a function library to make it modular and adaptable to diverse requirements. Only parts of its functionality may be relevant to you. For this use case, all component functions for smaller processing steps are made available in the library. Conceivably, the processing steps proposed by this library might in individual cases be interspersed with other steps.

At the same time, convenience wrapper functions are provided that wrap several or all processing steps in a single function. An all-in-one function may well be all you require.

#### update-correspAction()

Update `<persName>`, `<orgName>` and `<placeName>` elements within `<correspAction>` with normalised information from indices, e.g. regularised name forms or authority controlled identifiers.

##### Configuration parameters used by this function

This function uses the `<indices>` block in the configuration file. For each type of named entity that can appear in `<correspAction>` (persons, organizations, places), an index file path may be provided – either for a single file (`<resource>`) or a folder of files (`<collection>`).

Providing indices is optional – e.g. if no organizazions figure in your edition, you may omit them in the configuration.

The elements retrieved from the indices must be inserted as `<persName>`, `<orgName>` and `<placeName>` into `<correspAction>`. Typically, indices rather consist of `<person>` elements etc. (Or might follow some completely different, project-specific schema.) In this case, configure an XSLT stylesheet path in `<stylesheet>` to transform an individual entry from your project-specific index schema to TEI name elements. Stylesheets which transform ediarum indices are provided in the config-examples.

(If your indices *do* consist of TEI name elements such as `<persName>`, you may omit the stylesheet configuration parameter.)

#### subset-correspDesc()

Subset `<correspDesc>` elements in individual letter files for (strict) conformance to the CMIF standard. This subsetting (implemented in [correspDesc-transform.xsl](library-package/content/correspDesc-transform.xsl)) makes a number of assumptions and choices to ensure CMIF conformance:

* Only one `<correspDesc>` element per file is retained – the first one.
* Only one `<date>` element per `<correspAction>` is retained – the first one.
* Only date attributes conforming to the CMIF requirements are retained – all others are discarded.

If this behaviour is too restrictive for your use case, a possible solution might be to first do a project-specific transformation to re-order/select your desired elements.

For CMIF version 2 compatibility, the `<note>` and the `<ref>` elements in it are passed through by this function. (Currently, the CMIFerator contains no mechanism to create these elements.)

##### Configuration parameter used by this function

Currently, the CMIFerator makes the hard assumption that the permalinks for your letters will be concatenated from a base URL and the `@xml:id` attribute of the root `<TEI>` element. This may be subject to change in future versions.

#### wrap-CMIF()

The date of the CMIF file is generated at runtime.

##### Configuration parameters used by this function

This function uses the `<header>` block in the configuration file to fill in the `/TEI/teiHeader` template of the CMIF file.

#### Convenience wrappers

The wrapper `update-subset-wrap()` combines the three processing steps documented above into one convenient function. Similarly, if only parts of the processing flow proposed above apply to your use case, the wrappers `update-subset()` and `subset-wrap()` might cover what you need.

### Configuration (example)

The configuration file needs to be structured like this example:
```XML
<configuration xmlns="http://www.digitale-akademie.de/cmiferator">
    
    <!-- metadata of the CMIF file -->
    <header>
    
        <!-- plain text: title of the CMIF file – may be different from the project name -->
        <title>Die sozinianischen Briefwechsel:
            Zwischen Theologie, frühmoderner Naturwissenschaft und politischer Korrespondenz</title>
        
        <!-- XML fragment: name as plain text, can include the <email> element in TEI namespace -->
        <editor>Julian Jarosch <email xmlns="http://www.tei-c.org/ns/1.0">sbw@adwmainz.de</email></editor>
        
        <!-- XML fragment: one <ref> element in TEI namespace -->
        <publisher>
            <ref xmlns="http://www.tei-c.org/ns/1.0" target="http://www.adwmainz.de/">Akademie der Wissenschaften und der Literatur | Mainz</ref>
        </publisher>
        
        <!-- plain text: URL where the CMIF file is available online -->
        <url>https://gitlab.rlp.net/adwmainz/digicademy/sbw/csv-data-dump/-/raw/main/data/cmif/corresp.xml</url>
        
        <!-- plain text: UUID for the source -->
        <uuid>b3b22a15-9906-406b-aae1-7d7fa2292e71</uuid>
        
        <!-- XML fragment: content of the <bibl> element (in TEI namespace where necessary) -->
        <source>Die sozinianischen Briefwechsel:
                Zwischen Theologie, frühmoderner Naturwissenschaft und politischer Korrespondenz,
                erarbeitet und herausgegeben von Kęstutis Daugirdas und Andreas Kuczera.
                Johannes a Lasco Bibliothek Emden, 2020.
                <ref xmlns="http://www.tei-c.org/ns/1.0" target="https://sozinianer.de">https://sozinianer.de</ref></source>
    </header>
    
    <!-- prefix / base URL to construct the permalink -->
    <namespace>https://sozinianer.de/id/MAIN_</namespace>
    
    <!-- index files -->
    <!-- all parameters in this block are optional (though some are likely necessary) -->
    <indices>
        <persons>
            <resource>/db/apps/tei2json/xml/Register/Personen.xml</resource>
            <collection/>
            <stylesheet>/db/apps/tei2json/CMIFerate-config/persons-ediarum-transform.xsl</stylesheet>
        </persons>
        <organizations>
            <resource/>
            <collection/>
            <stylesheet/>
        </organizations>
        <places>
            <resource>/db/apps/tei2json/xml/Register/Orte.xml</resource>
            <collection/>
            <stylesheet>/db/apps/tei2json/CMIFerate-config/places-ediarum-transform.xsl</stylesheet>
        </places>
    </indices>
    
</configuration>
```

### Using the functions in an API endpoint

An example API endpoint using the CMIFerator:

```XQuery
xquery version "3.1";

import module namespace cmiferator = "http://www.digitale-akademie.de/cmiferator";

declare default element namespace "http://www.tei-c.org/ns/1.0";

let $config-filepath := '/db/apps/tei2json/CMIFerate-config/config.xml'

(: this assumes that all resources will be included in the CMIF – no exclusion criteria :)
let $letters := collection('/db/projects/sbw/data/Briefe')/TEI

return cmiferator:update-subset-wrap($letters, $config-filepath)
```

Perhaps some additional output options might prove useful to the API:
```XQuery
declare namespace output="http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:media-type "text/xml";
declare option output:omit-xml-declaration "no";
```