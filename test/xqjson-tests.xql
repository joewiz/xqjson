xquery version "3.0";

module namespace xj="http://exist-db.org/xquery/test/xqjson";

import module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";

declare namespace test="http://exist-db.org/xquery/xqsuite";

(: string :)

declare 
    %test:args('"John"')
    %test:assertEquals('<json type="string">John</json>')
    %test:args('{"firstName":"John"}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair></json>')
function xj:string-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="string">John</json>')
    %test:assertEquals('"John"')
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair></json>')
    %test:assertEquals('{"firstName":"John"}')
function xj:string-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: number :)

declare 
    %test:args('42')
    %test:assertEquals('<json type="number">42</json>')
    %test:args('42.0')
    %test:assertEquals('<json type="number">42.0</json>')
    %test:args('4.2E+1')
    %test:assertEquals('<json type="number">4.2E+1</json>')
    %test:args('{"answer":42}')
    %test:assertEquals('<json type="object"><pair name="answer" type="number">42</pair></json>')
function xj:number-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="number">42</json>')
    %test:assertEquals('42')
    %test:args('<json type="number">42.0</json>')
    %test:assertEquals('42.0')
    %test:args('<json type="number">4.2E+1</json>')
    %test:assertEquals('4.2E+1')
    %test:args('<json type="object"><pair name="answer" type="number">42</pair></json>')
    %test:assertEquals('{"answer":42}')
function xj:number-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: boolean :)

declare 
    %test:args('true')
    %test:assertEquals('<json type="boolean">true</json>')
    %test:args('false')
    %test:assertEquals('<json type="boolean">false</json>')
    %test:args('{"isAlive":true}')
    %test:assertEquals('<json type="object"><pair name="isAlive" type="boolean">true</pair></json>')
function xj:boolean-parse($json as xs:string) {
    xqjson:parse-json($json)
};


declare 
    %test:args('<json type="boolean">true</json>')
    %test:assertEquals('true')
    %test:args('<json type="boolean">false</json>')
    %test:assertEquals('false')
    %test:args('<json type="object"><pair name="isAlive" type="boolean">true</pair></json>')
    %test:assertEquals('{"isAlive":true}')
function xj:boolean-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: null :)

declare 
    %test:args('null')
    %test:assertEquals('<json type="null"/>')
    %test:args('{"spouse":null}')
    %test:assertEquals('<json type="object"><pair name="spouse" type="null"/></json>')
function xj:null-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="null"/>')
    %test:assertEquals('null')
    %test:args('<json type="object"><pair name="spouse" type="null"/></json>')
    %test:assertEquals('{"spouse":null}')
function xj:null-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: object :)

declare 
    %test:args('{}')
    %test:assertEquals('<json type="object"/>')
    %test:args('{"firstName":"John"}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair></json>')
    %test:args('{"firstName":"John","lastName":"Doe"}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Doe</pair></json>')
    %test:args('{"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"}}')
    %test:assertEquals('<json type="object"><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair></json>')
function xj:object-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair></json>')
    %test:assertEquals('{"firstName":"John"}')
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Doe</pair></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Doe"}')
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Doe</pair></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Doe"}')
    %test:args('<json type="object"><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair></json>')
    %test:assertEquals('{"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"}}')
function xj:object-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: array :)

declare 
    %test:args('[]')
    %test:assertEquals('<json type="array"/>')
    %test:args('[123,"abc",true]')
    %test:assertEquals('<json type="array"><item type="number">123</item><item type="string">abc</item><item type="boolean">true</item></json>')
function xj:array-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="array"/>')
    %test:assertEquals('[]')
    %test:args('<json type="array"><item type="number">123</item><item type="string">abc</item><item type="boolean">true</item></json>')
    %test:assertEquals('[123,"abc",true]')
function xj:array-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};


(: special characters :)

declare
    %test:args('{"char test":"\"\\\n\tA"}')
    %test:assertEquals('<json type="object"><pair name="char test" type="string">"\
	A</pair></json>')
function xj:special-characters-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare 
    %test:args('<json type="object"><pair name="char test" type="string">"\
	A</pair></json>')
    %test:assertEquals('{"char test":"\"\\\n\tA"}')
function xj:special-characters-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};

(: Complex - A JSON object, containing the full range of name/value pairs, arrays, and string and number types :)

declare
    %test:args('{"firstName":"John","lastName":"Smith","isAlive":true,"age":25,"height_cm":167.6,"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"},"phoneNumbers":[{"type":"home","number":"212 555-1234"},{"type":"office","number":"646 555-4567"}],"children":[],"spouse":null}')
    %test:assertEquals('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="isAlive" type="boolean">true</pair><pair name="age" type="number">25</pair><pair name="height_cm" type="number">167.6</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair><pair name="phoneNumbers" type="array"><item type="object"><pair name="type" type="string">home</pair><pair name="number" type="string">212 555-1234</pair></item><item type="object"><pair name="type" type="string">office</pair><pair name="number" type="string">646 555-4567</pair></item></pair><pair name="children" type="array"/><pair name="spouse" type="null"/></json>')
function xj:complex-example-parse($json as xs:string) {
    xqjson:parse-json($json)
};

declare
    %test:args('<json type="object"><pair name="firstName" type="string">John</pair><pair name="lastName" type="string">Smith</pair><pair name="isAlive" type="boolean">true</pair><pair name="age" type="number">25</pair><pair name="height_cm" type="number">167.6</pair><pair name="address" type="object"><pair name="streetAddress" type="string">21 2nd Street</pair><pair name="city" type="string">New York</pair><pair name="state" type="string">NY</pair><pair name="postalCode" type="string">10021-3100</pair></pair><pair name="phoneNumbers" type="array"><item type="object"><pair name="type" type="string">home</pair><pair name="number" type="string">212 555-1234</pair></item><item type="object"><pair name="type" type="string">office</pair><pair name="number" type="string">646 555-4567</pair></item></pair><pair name="children" type="array"/><pair name="spouse" type="null"/></json>')
    %test:assertEquals('{"firstName":"John","lastName":"Smith","isAlive":true,"age":25,"height_cm":167.6,"address":{"streetAddress":"21 2nd Street","city":"New York","state":"NY","postalCode":"10021-3100"},"phoneNumbers":[{"type":"home","number":"212 555-1234"},{"type":"office","number":"646 555-4567"}],"children":[],"spouse":null}')
function xj:complex-example-serialize($json-xml as element(json)) {
    xqjson:serialize-json($json-xml)
};