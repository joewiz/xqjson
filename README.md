# Parsing JSON into XQuery

An XQuery module for parsing and serializing JSON, 
[written and documented by John Snelson](http://john.snelson.org.uk/parsing-json-into-xquery), packaged in the 
[EXPath Package format](http://www.expath.org/spec/pkg) for convenient installation in XQuery implementation that 
support it. Minor bug-fixes have been added to support empty arrays and empty objects as allowed by the JSON specification.

## Requirements and Compatibility

The [original module](http://xqilla.hg.sourceforge.net/hgweb/xqilla/xqilla/file/6458513c94c0/src/functions/XQillaModule.xq)
was designed for use with [XQilla](http://xqilla.sourceforge.net/HomePage), but since it is written in pure XQuery 3.0, 
it is compatible with other XQuery 3.0 processors.  

This package has been tested with eXist 2.0RC (it is not compatible with eXist-db 1.x).  

To build this into an EXPath Package, you will need [Apache Ant](http://ant.apache.org/).  

To install the package, you need an implementation of XQuery that supports the EXPath Package system.

## Installation for eXist-db

To install in eXist-db, clone this repository and run ant, which will construct an EXPath Archive (.xar) file in the 
project's build folder. Then install the package via the eXist-db Package Manager, or place it in eXist-db's 'autodeploy' folder.

## Usage

### Import the module

    import module namespace xqjson="http://xqilla.sourceforge.net/Functions";

Note that the original module used "xqilla" as the module's namespace prefix, but this package uses "xqjson" instead.

### xqjson:parse-json($json as xs:string?) as element()?

This function translates a JSON string into an XML representation.  

    xqjson:parse-json('{
        "firstName": "John",
        "lastName": "Smith",
        "address": {
            "streetAddress": "21 2nd Street",
            "city": "New York",
            "state": "NY",
            "postalCode": 10021
        },
        "phoneNumbers": [
            "212 732-1234",
            "646 123-4567"
        ]
    }')
    
This will return the following result:

    <json type="object">
        <pair name="firstName" type="string">John</pair>
        <pair name="lastName" type="string">Smith</pair>
        <pair name="address" type="object">
            <pair name="streetAddress" type="string">21 2nd Street</pair>
            <pair name="city" type="string">New York</pair>
            <pair name="state" type="string">NY</pair>
            <pair name="postalCode" type="number">10021</pair>
        </pair>
        <pair name="phoneNumbers" type="array">
            <item type="string">212 732-1234</item>
            <item type="string">646 123-4567</item>
        </pair>
    </json>

### xqjson:serialize-json($json-xml as element()?) as xs:string?

This function reverses the above process.