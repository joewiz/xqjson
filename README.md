> With [XQuery 3.1's support of JSON parsing and serialization](https://www.w3.org/TR/xpath-functions-31/#json), this package is no longer being maintained. You are strongly encouraged to migrate your code to XQuery 3.1.

# Parsing JSON into XQuery

An XQuery module for parsing and serializing JSON, originally
written by John Snelson, with minor bug fixes applied, and packaged in the 
[EXPath Package format](http://www.expath.org/spec/pkg) for convenient installation in any XQuery implementation that 
supports it. 

## Documentation 

Snelson's [original article](http://john.snelson.org.uk/post/48547628468/parsing-json-into-xquery) is the official documentation. The information below focuses on how to install this module and get up and running. A table from Snelson's article about how each aspect of JSON is captured as XML is reproduced [below](#json-xml-mapping).

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

This function translates a valid JSON string into an XML representation.  

**Note:** This function assumes that the JSON string supplied is valid JSON. If you encounter an error with this function, please check to make sure your JSON is valid using a free, online validator like [jsonlint.com](http://jsonlint.com/).

### xqjson:serialize-json($json-xml as element()?) as xs:string?

This function reverses the above process. 

**Note**: The resulting JSON is not pretty-printed, and no effort is made to preserve whitespace when roundtripping from JSON to parsed XML back to serialized JSON.

## Examples

This example shows how the `parse-json()` function translates and captures JSON objects, arrays, strings, numbers, booleans, and nulls. (The JSON string was taken from [wikipedia](http://en.wikipedia.org/wiki/JSON#Data_types.2C_syntax_and_example).)

```xquery
let $json := 
    '{
        "firstName": "John",
        "lastName": "Smith",
        "isAlive": true,
        "age": 25,
        "height_cm": 167.6,
        "address": {
            "streetAddress": "21 2nd Street",
            "city": "New York",
            "state": "NY",
            "postalCode": "10021-3100"
        },
        "phoneNumbers": [
            {
                "type": "home",
                "number": "212 555-1234"
            },
            {
                "type": "office",
                "number": "646 555-4567"
            }
        ],
        "children": [],
        "spouse": null
    }')
return
    xqjson:parse-json($json)
```
    
This will return the following result:

```xml
<json type="object">
    <pair name="firstName" type="string">John</pair>
    <pair name="lastName" type="string">Smith</pair>
    <pair name="isAlive" type="boolean">true</pair>
    <pair name="age" type="number">25</pair>
    <pair name="height_cm" type="number">167.6</pair>
    <pair name="address" type="object">
        <pair name="streetAddress" type="string">21 2nd Street</pair>
        <pair name="city" type="string">New York</pair>
        <pair name="state" type="string">NY</pair>
        <pair name="postalCode" type="string">10021-3100</pair>
    </pair>
    <pair name="phoneNumbers" type="array">
        <item type="object">
            <pair name="type" type="string">home</pair>
            <pair name="number" type="string">212 555-1234</pair>
        </item>
        <item type="object">
            <pair name="type" type="string">office</pair>
            <pair name="number" type="string">646 555-4567</pair>
        </item>
    </pair>
    <pair name="children" type="array"/>
    <pair name="spouse" type="null"/>
</json>
```

Using xqjson:serialize-json() on this `<json>` element will return the original JSON, sans pretty printing:

```json
{"firstName":"John","lastName":"Smith","isAlive":true,"age":25,"height_cm":167.6,"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"},"phoneNumbers":[{"type":"home","number":"212 555-1234"},{"type":"office","number":"646 555-4567"}],"children":[],"spouse":null}
```

### JSON object with a single pair, illustrating string type

```json
{
    "firstName": "John"
}
```

```xml
<json type="object">
    <pair name="firstName" type="string">John</pair>
</json>
```

### JSON object with multiple pairs, illustrating string, number, and boolean types

```json
{
    "firstName": "John",
    "lastName": "Smith",
    "age": 25,
    "isAlive": true
}
```

```xml
<json type="object">
    <pair name="firstName" type="string">John</pair>
    <pair name="lastName" type="string">Smith</pair>
    <pair name="age" type="number">25</pair>
    <pair name="isAlive" type="boolean">true</pair>
</json>
```

### JSON array containing objects, which in turn contain pairs and arrays

```json
[
    {
        "label": "node1",
        "children": [
            "child1",
            "child2"
        ]
    },
    {
        "label": "node2",
        "children": ["child3"]
    }
]
```

```xml
<json type="array">
    <item type="object">
        <pair name="label" type="string">node1</pair>
        <pair name="children" type="array">
            <item type="string">child1</item>
            <item type="string">child2</item>
        </pair>
    </item>
    <item type="object">
        <pair name="label" type="string">node2</pair>
        <pair name="children" type="array">
            <item type="string">child3</item>
        </pair>
    </item>
</json>
```

### JSON object with a pair whose value is another object

```json
{
    "address": {
        "streetAddress": "21 2nd Street",
        "city": "New York",
        "state": "NY",
        "postalCode": "10021-3100"
    }
}
```

```xml
<json type="object">
    <pair name="address" type="object">
        <pair name="streetAddress" type="string">21 2nd Street</pair>
        <pair name="city" type="string">New York</pair>
        <pair name="state" type="string">NY</pair>
        <pair name="postalCode" type="string">10021-3100</pair>
    </pair>
</json>
```

### JSON object with a pair whose value is an array of objects

```json
{
    "phoneNumbers": [
        {
            "type": "home",
            "number": "212 555-1234"
        },
        {
            "type": "office",
            "number": "646 555-4567"
        }
    ]
}
```

```xml
<json type="object">
    <pair name="phoneNumbers" type="array">
        <item type="object">
            <pair name="type" type="string">home</pair>
            <pair name="number" type="string">212 555-1234</pair>
        </item>
        <item type="object">
            <pair name="type" type="string">office</pair>
            <pair name="number" type="string">646 555-4567</pair>
        </item>
    </pair>
</json>
```

### JSON Object with two pairs showing an empty array and a null value

```json
{
    "children": [],
    "spouse": null
}
```

```xml
<json type="object">
    <pair name="children" type="array"/>
    <pair name="spouse" type="null"/>
</json>
```


## JSON-XML Mapping 

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
        timestamp="2014-12-16T01:39:11.326-05:00" failures="0" pending="0" tests="38" time="PT0.191S">
        <testcase name="array-parse" class="xj:array-parse"/>
        <testcase name="array-serialize" class="xj:array-serialize"/>
        <!--more testcases...-->
    </testsuite>
</testsuites>
```

If all is well, the `@failures` attribute should read `0`.
