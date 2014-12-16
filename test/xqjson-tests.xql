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


(: Advanced - A JSON object, containing the full range of name/value pairs, arrays, and string and number types :)

declare
    %test:args('{"firstName":"John","lastName":"Smith","isAlive":true,"age":25,"height_cm":167.6,"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"},"phoneNumbers":[{"type":"home","number":"212 555-1234"},{"type":"office","number":"646 555-4567"}],"children":[],"spouse":null}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="isAlive" type="boolean">true</pair><pair name="age" type="number">25</pair><pair name="height_cm" type="number">167.6</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair><pair name="phoneNumbers" type="array"><item type="object"><pair name="type" type="string">home</pair><pair name="number" type="string">212 555-1234</pair></item><item type="object"><pair name="type" type="string">office</pair><pair name="number" type="string">646 555-4567</pair></item></pair><pair name="children" type="array"/><pair name="spouse" type="null"/></json>')
function xj:parse-json-complex($json as xs:string) {
    xqjson:parse-json($json)
};

declare
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="isAlive" type="boolean">true</pair><pair name="age" type="number">25</pair><pair name="height_cm" type="number">167.6</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair><pair name="phoneNumbers" type="array"><item type="object"><pair name="type" type="string">home</pair><pair name="number" type="string">212 555-1234</pair></item><item type="object"><pair name="type" type="string">office</pair><pair name="number" type="string">646 555-4567</pair></item></pair><pair name="children" type="array"/><pair name="spouse" type="null"/></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Smith","isAlive":true,"age":25,"height_cm":167.6,"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"},"phoneNumbers":[{"type":"home","number":"212 555-1234"},{"type":"office","number":"646 555-4567"}],"children":[],"spouse":null}')
function xj:serialize-json-complex($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};
