xquery version "3.1";

(:
 : CMIFerator
 : 
 : function library
 : update, subset and wrap correspondence metadata
 : for ingest in the aggregation service correspSearch
 :
 : Developed by Julian Jarosch
 : Academy of Sciences and Literature | Mainz
 : Digital Academy
 :
 : @author Julian Jarosch
 : @email <Julian.Jarosch@adwmainz.de>
 : @licence MIT
:)

module namespace c8r = "http://www.digitale-akademie.de/cmiferator";

import module namespace transform = "http://exist-db.org/xquery/transform";

declare default element namespace "http://www.tei-c.org/ns/1.0";

declare %private variable $c8r:cmif-base-template := doc('./CMIF-base.xsl');
declare %private variable $c8r:correspDesc-transform := doc('./correspDesc-transform.xsl');


(:~
: This function wraps <correspDesc> elements in a standard
: CMIF structure.
:
: @param $files the TEI document(s) (one or more)
: to be wrapped in the CMIF template
: @param $config-filepath file path to the configuration file
: @return a complete CMIF file composed of the <correspDesc>
: elements passed to it combined with the metadata from the
: configuration file
:)

declare function c8r:wrap-cmif ($files as element(TEI)+, $config-filepath as xs:string) as document-node() {
    
    (: variant: load files from config parameter. currently not implemented :)
    (: let $files := collection($config/c8r:files)/tei:TEI :)
    
    let $correspDescs := c8r:correspDesc-transform($files, $config-filepath)
    let $cmif := transform:transform($correspDescs,
                                     $c8r:cmif-base-template,
                                     <parameters>
                                      <param name="config-filepath" 
                                             value="{$config-filepath}"/>
                                     </parameters>)
    let $cmif := document{$cmif}
    return $cmif
};

(:~
: This function extracts <correspDesc> elements from complete
: TEI files. The returned elements are subsetted for the CMIF
: standard.
:
: @param $files the TEI document(s) (one or more)
: from which to extract CMIF conformant <correspDesc> elements
: @param $config-filepath file path to the configuration file
: @return one or more <correspDesc> elements conforming to the
: CMIF standard (subset of TEI)
:)

declare function c8r:correspDesc-transform($files as element(TEI)+, $config-filepath as xs:string) as element(correspDesc)+ {
    let $correspDescs := transform:transform($files,
                                             $c8r:correspDesc-transform,
                                             <parameters>
                                              <param name="config-filepath"
                                                     value="{$config-filepath}"/>
                                             </parameters>)
    return $correspDescs
};

(:~
: This function updates references to indices within <correspAction>
: elements before passing them to the CMIF transformation.
:
: @param $files the TEI document(s) (one or more)
: from which to extract CMIF conformant <correspDesc> elements
: @param $config-filepath file path to the configuration file
: @return one or more complete TEI document(s).
:)

declare function c8r:correspAction-update($files as element(TEI)+, $config-filepath as xs:string) as element(TEI)+ {
    
    let $config := doc($config-filepath)/c8r:configuration
    
    (: get indices :)
    let $indices := map{
        'persons': c8r:load-index($config/c8r:indices/c8r:persons),
        'orgs': c8r:load-index($config/c8r:indices/c8r:organizations),
        'places': c8r:load-index($config/c8r:indices/c8r:places)
    }
    
    (: get stylesheets :)
    let $stylesheets := map{
        'persons': c8r:load-stylesheet($config/c8r:indices/c8r:persons),
        'orgs': c8r:load-stylesheet($config/c8r:indices/c8r:organizations),
        'places': c8r:load-stylesheet($config/c8r:indices/c8r:places)
    }
    
    return c8r:identity-transform($files, $indices, $stylesheets)

};

(: LOCAL HELPER FUNCTIONS :)

(: local function to get indices from file path in config :)

declare %private function c8r:load-index($config-parameter as element()) as document-node()* {
    (: select between resource and collection :)
    if ($config-parameter/c8r:resource/normalize-space())
    then doc($config-parameter/c8r:resource)
    else
        if ($config-parameter/c8r:collection/normalize-space())
        then collection($config-parameter/c8r:collection)
        else ()
};

(: local function to get stylesheets from file path in config :)

declare %private function c8r:load-stylesheet($config-parameter as element()) as document-node()? {
    if ($config-parameter/c8r:stylesheet/normalize-space())
    then doc($config-parameter/c8r:stylesheet)
    else ()
};

(: local function to deep copy the document unchanged except for <correspAction> :)

declare %private function c8r:identity-transform($nodes as node()*, $indices as map(xs:string, document-node()*), $stylesheets as map(xs:string, document-node()?)) as node()* {
    for $node in $nodes
    return
        (: for some reason, only an if clause and not a case works here to separate <correspAction> :)
        if ($node/parent::correspAction)
        then c8r:correspAction-transform($node, $indices, $stylesheets)
        else
            typeswitch($node)
                (:case element(correspAction) return c8r:correspAction-transform($node, $indices, $stylesheets):) (: why does this work in lines 132–134 but not here? :)
                case element() return c8r:element-passthrough($node, $indices, $stylesheets)
                case text() return $node
                case comment() return $node
                case processing-instruction() return $node
                default return c8r:identity-transform($node/node(), $indices, $stylesheets)
};

(: local function to pass through elements unchanged :)

declare %private function c8r:element-passthrough($node as element(), $indices as map(xs:string, document-node()*), $stylesheets as map(xs:string, document-node()?)) as element() {
    element {QName($node/namespace-uri(), $node/name())} {($node/attribute(), c8r:identity-transform($node/node(), $indices, $stylesheets))}
};

(: local function to apply update functions to name elements within <correspAction> and deep copy the rest :)

declare %private function c8r:correspAction-transform($node as node(), $indices as map(xs:string, document-node()*), $stylesheets as map(xs:string, document-node()?)) as node()* {
    typeswitch($node)
        case element(persName) return c8r:persName-transform($node, $indices?persons, $stylesheets?persons)
        case element(orgName) return c8r:orgName-transform($node, $indices?orgs, $stylesheets?orgs)
        case element(placeName) return c8r:placeName-transform($node, $indices?places, $stylesheets?places)
        case element() return c8r:element-passthrough($node, $indices, $stylesheets)
        case text() return $node
        case comment() return $node
        case processing-instruction() return $node
        default return c8r:identity-transform($node/node(), $indices, $stylesheets)
};

(: local function to update person names from indices :)
(: this function currently does nothing besides providing strong typing :)
declare %private function c8r:persName-transform($element as element(persName), $index as document-node()*, $stylesheet as document-node()?) as element(persName) {
    c8r:name-transform($element, $index, $stylesheet)
};

(: local function to update organisation names from indices :)
(: this function currently does nothing besides providing strong typing :)
declare %private function c8r:orgName-transform($element as element(orgName), $index as document-node()*, $stylesheet as document-node()?) as element(orgName) {
    c8r:name-transform($element, $index, $stylesheet)
};

(: local function to update place names from indices :)
(: this function currently does nothing besides providing strong typing :)
declare %private function c8r:placeName-transform($element as element(placeName), $index as document-node()*, $stylesheet as document-node()?) as element(placeName) {
    c8r:name-transform($element, $index, $stylesheet)
};

(: local function to update a name element within <correspAction> from an index and using a stylesheet :)

declare %private function c8r:name-transform($element as element(), $index as document-node()*, $stylesheet as document-node()?) as element() {
    (: look up the corresponding index entry :)
    let $index-entry := $index/TEI/text/body/id($element/@key)
    (: optionally: XSLT transform index entry to the form it needs within <correspAction>, e.g. <person> to <persName> :)
    let $index-entry := if ($stylesheet) then transform:transform($index-entry, $stylesheet, <parameters/>) else $index-entry
    (: if the lookup yielded no result, return the input element unchanged :)
    return if ($index-entry) then $index-entry
    else $element
}