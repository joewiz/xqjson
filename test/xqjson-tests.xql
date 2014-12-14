xquery version "3.0";

module namespace xj="http://exist-db.org/xquery/test/xqjson";

import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";

declare namespace test="http://exist-db.org/xquery/xqsuite";

declare variable $xj:json {
    '{"firstName":"John","lastName":"Smith","address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":10021},"phoneNumbers":["212 732-1234","646 123-4567"]}'
};

declare variable $xj:json-xml {
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
};

declare
    %test:assertTrue
function xj:parse-json() {
    deep-equal(xqjson:parse-json($xj:json), $xj:json-xml)
};

declare
    %test:args('{"firstName":"John","lastName":"Smith","address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":10021},"phoneNumbers":["212 732-1234","646 123-4567"]}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="number">10021</pair></pair><pair name="phoneNumbers" type="array"><item type="string">212 732-1234</item><item type="string">646 123-4567</item></pair></json>')
function xj:parse-json2($json as xs:string) {
    xqjson:parse-json($json)
};

declare
    %test:assertTrue
function xj:serialize-json() {
    xqjson:serialize-json($xj:json-xml) eq $xj:json
};


declare
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="number">10021</pair></pair><pair name="phoneNumbers" type="array"><item type="string">212 732-1234</item><item type="string">646 123-4567</item></pair></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Smith","address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":10021},"phoneNumbers":["212 732-1234","646 123-4567"]}')
function xj:serialize-json2($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};