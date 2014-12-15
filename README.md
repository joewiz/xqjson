# Parsing JSON into XQuery

An XQuery module for parsing and serializing JSON, originally
written by John Snelson, with minor bug fixes applied, and packaged in the 
[EXPath Package format](http://www.expath.org/spec/pkg) for convenient installation in any XQuery implementation that 
support it. 

## Documentation 

Snelson's [original article](http://john.snelson.org.uk/post/48547628468/parsing-json-into-xquery) is the official documentation. The information below focuses on how to install this module and get up and running.

## Requirements and Compatibility

The [original module](http://xqilla.hg.sourceforge.net/hgweb/xqilla/xqilla/file/6458513c94c0/src/functions/XQillaModule.xq)
was designed for use with [XQilla](http://xqilla.sourceforge.net/HomePage), but since it is written in pure XQuery 3.0, 
it is compatible with other XQuery 3.0 processors.  It has been tested with eXist 2.0+.  

You can download the core module from the `src/content/` directory and import it in your own XQuery. 
For many systems, it is more convenient to install the module as an [EXPath Package](http://expath.org/modules/pkg/) (.xar file). 
A pre-built package is available on the [Releases](https://github.com/joewiz/xqjson/releases) page. 
To build the source into a package, you will need [Apache Ant](http://ant.apache.org/). 
To install the package, you need an implementation of XQuery that [supports](http://expath.org/modules/pkg/implems) the EXPath Package system.

## Installation for eXist-db

To install in eXist-db, clone this repository and run ant, which will construct an EXPath Archive (.xar) file in the 
project's build folder. Then install the package via the eXist-db Package Manager, or place it in eXist-db's 'autodeploy' folder.

## Usage

### Import the module

    import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";

Note that the original module used "xqilla" as the module's namespace prefix, but this module uses "xqjson" instead, 
and the original module used "http://xqilla.sourceforge.net/Functions" as the module's namespace, but this module has 
adopted the more specific "http://xqilla.sourceforge.net/lib/xqjson".

### xqjson:parse-json($json as xs:string?) as element()?

This function translates a JSON string into an XML representation.  

```xquery
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
```
    
This will return the following result:

```xml
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
```

### xqjson:serialize-json($json-xml as element()?) as xs:string?

This function reverses the above process.

## Reference: John Snelson's mapping of JSON into XML 

|JSON|type(JSON)|toXML(JSON)|
|----|----------|-----------|
|JSON|N/A|`<json type="`type(JSON)`">`toXML(JSON)`</json>`|
|`{ "key1": value1, "key2": value2 }`|object|`<pair name="key1" type="`*type(value1)*`">`*toXML(value1)*`</pair> <pair name="key2" type="`*type(value2)*`">`*toXML(value2)*`</pair>`|
|`[ value1, value2 ]`|array|`<item type="`*type(value1)*`">`*toXML(value1)*`</item> <item type="`*type(value2)*`">`*toXML(value2)*`</item>`|
|`"value"`|string|`value`|
|*number*|number|*number*|
|`true` / `false`|boolean|`true` / `false`|
|`null`|null|*empty*|

## Running the test suite

A test suite, written using the [XQSuite](http://exist-db.org/exist/apps/doc/xqsuite.xml) framework for 
eXist, can be run with the following command, assuming Apache Ant is installed (some properties in 
`build.xml` may need to be adapted to your system):

```bash
ant test
```

The result should show something like:

```xml
<testsuites>
    <testsuite package="http://exist-db.org/xquery/test/xqjson"
        timestamp="2014-12-14T01:13:38.684-05:00" failures="0" pending="0" tests="4" time="PT0.03S">
        <testcase name="parse-json" class="xj:parse-json"/>
        <testcase name="parse-json2" class="xj:parse-json2"/>
        <testcase name="serialize-json" class="xj:serialize-json"/>
        <testcase name="serialize-json2" class="xj:serialize-json2"/>
    </testsuite>
</testsuites>
```

If all is well, the `@failures` attribute should read `0`.
