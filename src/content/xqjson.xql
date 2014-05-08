xquery version "3.0";

(:
 : Copyright (c) 2010-2011
 :     John Snelson. All rights reserved.
 :
 : Licensed under the Apache License, Version 2.0 (the "License");
 : you may not use this file except in compliance with the License.
 : You may obtain a copy of the License at
 :
 :     http://www.apache.org/licenses/LICENSE-2.0
 :
 : Unless required by applicable law or agreed to in writing, software
 : distributed under the License is distributed on an "AS IS" BASIS,
 : WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 : See the License for the specific language governing permissions and
 : limitations under the License.
 :)

(:
    20121227 Adam Retter changed namespace prefix from xqilla to xqjson
    20121227 Adam Retter patched parseArray to support empty arrays
    20121227 Adam Retter patched parseObject to support empty objects
    20130210 Joe Wicentowski changed namespace to include 'xqjson'
    20130612 Joe Wicentowski patched tokenize to handle long string arrays
    20130613 Leif-Jöran Olsson patched decodeHexChar to correctly handle a-f chars.
    20130614 Refactoring suggestion for performance of same function by Michael Westbay.
    20140507 @Albicocca helped fix bug where commas were output when serializing JSON.
:)

module namespace xqjson="http://xqilla.sourceforge.net/lib/xqjson";

(:----------------------------------------------------------------------------------------------------:)
(: JSON parsing :)

declare function xqjson:parse-json($json as xs:string)
  as element()?
{
  let $res := xqjson:parseValue(xqjson:tokenize($json))
  return
    if(exists(remove($res,1))) then xqjson:parseError($res[2])
    else element json {
      $res[1]/@*,
      $res[1]/node()
    }
};

declare %private function xqjson:parseValue($tokens as element(token)*)
{
  let $token := $tokens[1]
  let $tokens := remove($tokens,1)
  return
    if($token/@t = "lbrace") then (
      let $res := xqjson:parseObject($tokens)
      let $tokens := remove($res,1)
      return (
        element res {
          attribute type { "object" },
          $res[1]/node()
        },
        $tokens
      )
    ) else if ($token/@t = "lsquare") then (
      let $res := xqjson:parseArray($tokens)
      let $tokens := remove($res,1)
      return (
        element res {
          attribute type { "array" },
          $res[1]/node()
        },
        $tokens
      )
    ) else if ($token/@t = "number") then (
      element res {
        attribute type { "number" },
        text { $token }
      },
      $tokens
    ) else if ($token/@t = "string") then (
      element res {
        attribute type { "string" },
        text { xqjson:unescape-json-string($token) }
      },
      $tokens
    ) else if ($token/@t = "true" or $token/@t = "false") then (
      element res {
        attribute type { "boolean" },
        text { $token }
      },
      $tokens
    ) else if ($token/@t = "null") then (
      element res {
        attribute type { "null" }
      },
      $tokens
    ) else xqjson:parseError($token)
};

declare %private function xqjson:parseObject($tokens as element(token)*)
{
  let $token1 := $tokens[1]
  let $tokens := remove($tokens,1)
  return
    if($token1/@t eq "rbrace")then (
        element res {
        },
        $tokens
    ) else if(not($token1/@t = "string")) then xqjson:parseError($token1) else
      let $token2 := $tokens[1]
      let $tokens := remove($tokens,1)
      return
        if(not($token2/@t = "colon")) then xqjson:parseError($token2) else
          let $res := xqjson:parseValue($tokens)
          let $tokens := remove($res,1)
          let $pair := element pair {
            attribute name { $token1 },
            $res[1]/@*,
            $res[1]/node()
          }
          let $token := $tokens[1]
          let $tokens := remove($tokens,1)
          return
            if($token/@t = "comma") then (
              let $res := xqjson:parseObject($tokens)
              let $tokens := remove($res,1)
              return (
                element res {
                  $pair,
                  $res[1]/node()
                },
                $tokens
              )
            ) else if($token/@t = "rbrace") then (
              element res {
                $pair
              },
              $tokens
            ) else xqjson:parseError($token)
};

declare %private function xqjson:parseArray($tokens as element(token)*)
{
    if($tokens[1]/@t = "rsquare") then (
    (: empty array! :)
    
    element res {},
    remove($tokens, 1)
  ) else
    let $res := xqjson:parseValue($tokens)
    let $tokens := remove($res,1)
    let $item := element item {
      $res[1]/@*,
      $res[1]/node()
    }
    let $token := $tokens[1]
    let $tokens := remove($tokens,1)
    return
      if($token/@t = "comma") then (
        let $res := xqjson:parseArray($tokens)
        let $tokens := remove($res,1)
        return (
          element res {
            $item,
            $res[1]/node()
          },
          $tokens
        )
      ) else if($token/@t = "rsquare") then (
        element res {
          $item
        },
        $tokens
      ) else xqjson:parseError($token)
};

declare %private function xqjson:parseError($token as element(token))
  as empty-sequence()
{
  error(xs:QName("xqjson:PARSEJSON01"),
    concat("Unexpected token: ", string($token/@t), " (""", string($token), """)"))
};

declare %private function xqjson:tokenize($json as xs:string)
  as element(token)*
{
  let $tokens := ("\{", "\}", "\[", "\]", ":", ",", "true", "false", "null", "\s+",
    '"(?>[^"\\]|\\"|\\\\|\\/|\\b|\\f|\\n|\\r|\\t|\\u[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])*"',
    "-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+\-]?[0-9]+)?")
  let $regex := string-join(for $t in $tokens return concat("(",$t,")"),"|")
  for $match in analyze-string($json, $regex)/*
  return
    if($match/self::*:non-match) then xqjson:token("error", string($match))
    else if($match/*:group/@nr = 1) then xqjson:token("lbrace", string($match))
    else if($match/*:group/@nr = 2) then xqjson:token("rbrace", string($match))
    else if($match/*:group/@nr = 3) then xqjson:token("lsquare", string($match))
    else if($match/*:group/@nr = 4) then xqjson:token("rsquare", string($match))
    else if($match/*:group/@nr = 5) then xqjson:token("colon", string($match))
    else if($match/*:group/@nr = 6) then xqjson:token("comma", string($match))
    else if($match/*:group/@nr = 7) then xqjson:token("true", string($match))
    else if($match/*:group/@nr = 8) then xqjson:token("false", string($match))
    else if($match/*:group/@nr = 9) then xqjson:token("null", string($match))
    else if($match/*:group/@nr = 10) then () (:ignore whitespace:)
    else if($match/*:group/@nr = 11) then
      let $v := string($match)
      let $len := string-length($v)
      return xqjson:token("string", substring($v, 2, $len - 2))
    else if($match/*:group/@nr = 12) then xqjson:token("number", string($match))
    else xqjson:token("error", string($match))
};

declare %private function xqjson:token($t, $value)
{
  <token t="{$t}">{ string($value) }</token>
};

(:----------------------------------------------------------------------------------------------------:)
(: JSON serializing :)

declare function xqjson:serialize-json($json-xml as element()?)
  as xs:string?
{
  if(empty($json-xml)) then () else

  string-join(
    xqjson:serializeJSONElement($json-xml)
  ,"")
};

declare %private function xqjson:serializeJSONElement($e as element())
  as xs:string*
{
  if($e/@type = "object") then xqjson:serializeJSONObject($e)
  else if($e/@type = "array") then xqjson:serializeJSONArray($e)
  else if($e/@type = "null") then "null"
  else if($e/@type = "boolean") then string($e)
  else if($e/@type = "number") then string($e)
  else ('"', xqjson:escape-json-string($e), '"')
};

declare %private function xqjson:serializeJSONObject($e as element())
  as xs:string*
{
  "{",
  for $el at $pos in $e/* return
 (
    if($pos = 1) then () else ",",
    '"', xqjson:escape-json-string($el/@name), '":',
    xqjson:serializeJSONElement($el)
  ),
  "}"
}; 

declare %private function xqjson:serializeJSONArray($e as element())
  as xs:string*
{
  "[",
  for $el at $pos in $e/* return
  (
    if($pos = 1) then () else ",",
    xqjson:serializeJSONElement($el)
  ),
  "]"
};

(:----------------------------------------------------------------------------------------------------:)
(: JSON unescaping :)

declare function xqjson:unescape-json-string($val as xs:string)
  as xs:string
{
  string-join(
    let $regex := '[^\\]+|(\\")|(\\\\)|(\\/)|(\\b)|(\\f)|(\\n)|(\\r)|(\\t)|(\\u[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])'
    for $match in analyze-string($val, $regex)/*
    return
      if($match/*:group/@nr = 1) then """"
      else if($match/*:group/@nr = 2) then "\"
      else if($match/*:group/@nr = 3) then "/"
      (: else if($match/*:group/@nr = 4) then "&#x08;" :)
      (: else if($match/*:group/@nr = 5) then "&#x0C;" :)
      else if($match/*:group/@nr = 6) then "&#x0A;"
      else if($match/*:group/@nr = 7) then "&#x0D;"
      else if($match/*:group/@nr = 8) then "&#x09;"
      else if($match/*:group/@nr = 9) then
        codepoints-to-string(xqjson:decode-hex-string(substring($match, 3)))
      else string($match)
  ,"")
};

declare function xqjson:escape-json-string($val as xs:string)
  as xs:string
{
  string-join(
    let $regex := '(")|(\\)|(/)|(&#x0A;)|(&#x0D;)|(&#x09;)|[^"\\/&#x0A;&#x0D;&#x09;]+'
    for $match in analyze-string($val, $regex)/*
    return
      if($match/*:group/@nr = 1) then "\"""
      else if($match/*:group/@nr = 2) then "\\"
      else if($match/*:group/@nr = 3) then "\/"
      else if($match/*:group/@nr = 4) then "\n"
      else if($match/*:group/@nr = 5) then "\r"
      else if($match/*:group/@nr = 6) then "\t"
      else string($match)
  ,"")
};

declare function xqjson:decode-hex-string($val as xs:string)
  as xs:integer
{
  xqjson:decodeHexStringHelper(string-to-codepoints($val), 0)
};

declare %private function xqjson:decodeHexChar($val as xs:integer)
  as xs:integer
{
  if ($val le 57) then $val - 48      (: Handle '0' to '9' by subtracting '0' :)
  else if ($val le 70) then $val - 55 (: Handle 'A' to 'F' by subtracting 'A' and adding 10 (-65 + 10) :)
  else $val - 87                      (: Handle 'a' to 'f' by subtracting 'a' and adding 10 (-97 + 10) :)
};

declare %private function xqjson:decodeHexStringHelper($chars as xs:integer*, $acc as xs:integer)
  as xs:integer
{
  if(empty($chars)) then $acc
  else xqjson:decodeHexStringHelper(remove($chars,1), ($acc * 16) + xqjson:decodeHexChar($chars[1]))
};
