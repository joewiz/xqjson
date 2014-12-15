xquery version "3.0";

module namespace xj="http://exist-db.org/xquery/test/xqjson";

import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";

declare namespace test="http://exist-db.org/xquery/xqsuite";


(: Simple - A JSON object, containing a single name/value pair :)

declare 
    %test:args('{"firstName":"John"}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair></json>')
function xj:parse-json-object-one-pair($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair></json>')
    %test:assertEquals('{"firstName":"John"}')
function xj:serialize-json-object-one-pair($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: Intermediate - A JSON object, containing two name/value pairs :)

declare 
    %test:args('{"firstName":"John","lastName":"Doe"}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Doe</pair></json>')
function xj:parse-json-object-two-pairs($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Doe</pair></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Doe"}')
function xj:serialize-json-object-two-pairs($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: Advanced - A JSON object, containing name/value pairs, arrays, and string and number types :)

declare
    %test:args('{"firstName":"John","lastName":"Smith","address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":10021},"phoneNumbers":["212 732-1234","646 123-4567"]}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="number">10021</pair></pair><pair name="phoneNumbers" type="array"><item type="string">212 732-1234</item><item type="string">646 123-4567</item></pair></json>')
function xj:parse-json-complex($json as xs:string) {
    xqjson:parse-json($json)
};

declare
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="number">10021</pair></pair><pair name="phoneNumbers" type="array"><item type="string">212 732-1234</item><item type="string">646 123-4567</item></pair></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Smith","address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":10021},"phoneNumbers":["212 732-1234","646 123-4567"]}')
function xj:serialize-json-complex($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};
