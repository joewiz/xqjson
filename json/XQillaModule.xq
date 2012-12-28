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

module namespace xqilla="http://xqilla.sourceforge.net/Functions";

(:----------------------------------------------------------------------------------------------------:)
(: JSON parsing :)

declare function xqilla:parse-json($json as xs:string)
  as element()?
{
  let $res := xqilla:parseValue(xqilla:tokenize($json))
  return
    if(exists(remove($res,1))) then xqilla:parseError($res[2])
    else element json {
      $res[1]/@*,
      $res[1]/node()
    }
};

declare %private function xqilla:parseValue($tokens as element(token)*)
{
  let $token := $tokens[1]
  let $tokens := remove($tokens,1)
  return
    if($token/@t = "lbrace") then (
      let $res := xqilla:parseObject($tokens)
      let $tokens := remove($res,1)
      return (
        element res {
          attribute type { "object" },
          $res[1]/node()
        },
        $tokens
      )
    ) else if ($token/@t = "lsquare") then (
      let $res := xqilla:parseArray($tokens)
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
        text { xqilla:unescape-json-string($token) }
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
    ) else xqilla:parseError($token)
};

declare %private function xqilla:parseObject($tokens as element(token)*)
{
  let $token1 := $tokens[1]
  let $tokens := remove($tokens,1)
  return
    if(not($token1/@t = "string")) then xqilla:parseError($token1) else
      let $token2 := $tokens[1]
      let $tokens := remove($tokens,1)
      return
        if(not($token2/@t = "colon")) then xqilla:parseError($token2) else
          let $res := xqilla:parseValue($tokens)
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
              let $res := xqilla:parseObject($tokens)
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
            ) else xqilla:parseError($token)
};

declare %private function xqilla:parseArray($tokens as element(token)*)
{
  let $res := xqilla:parseValue($tokens)
  let $tokens := remove($res,1)
  let $item := element item {
    $res[1]/@*,
    $res[1]/node()
  }
  let $token := $tokens[1]
  let $tokens := remove($tokens,1)
  return
    if($token/@t = "comma") then (
      let $res := xqilla:parseArray($tokens)
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
    ) else xqilla:parseError($token)
};

declare %private function xqilla:parseError($token as element(token))
  as empty-sequence()
{
  error(xs:QName("xqilla:PARSEJSON01"),
    concat("Unexpected token: ", string($token/@t), " (""", string($token), """)"))
};

declare %private function xqilla:tokenize($json as xs:string)
  as element(token)*
{
  let $tokens := ("\{", "\}", "\[", "\]", ":", ",", "true", "false", "null", "\s+",
    '"([^"\\]|\\"|\\\\|\\/|\\b|\\f|\\n|\\r|\\t|\\u[A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9][A-Fa-f0-9])*"',
    "-?(0|[1-9][0-9]*)(\.[0-9]+)?([eE][+-]?[0-9]+)?")
  let $regex := string-join(for $t in $tokens return concat("(",$t,")"),"|")
  for $match in analyze-string($json, $regex)/*
  return
    if($match/self::*:non-match) then xqilla:token("error", string($match))
    else if($match/*:group/@nr = 1) then xqilla:token("lbrace", string($match))
    else if($match/*:group/@nr = 2) then xqilla:token("rbrace", string($match))
    else if($match/*:group/@nr = 3) then xqilla:token("lsquare", string($match))
    else if($match/*:group/@nr = 4) then xqilla:token("rsquare", string($match))
    else if($match/*:group/@nr = 5) then xqilla:token("colon", string($match))
    else if($match/*:group/@nr = 6) then xqilla:token("comma", string($match))
    else if($match/*:group/@nr = 7) then xqilla:token("true", string($match))
    else if($match/*:group/@nr = 8) then xqilla:token("false", string($match))
    else if($match/*:group/@nr = 9) then xqilla:token("null", string($match))
    else if($match/*:group/@nr = 10) then () (:ignore whitespace:)
    else if($match/*:group/@nr = 11) then
      let $v := string($match)
      let $len := string-length($v)
      return xqilla:token("string", substring($v, 2, $len - 2))
    else if($match/*:group/@nr = 13) then xqilla:token("number", string($match))
    else xqilla:token("error", string($match))
};

declare %private function xqilla:token($t, $value)
{
  <token t="{$t}">{ string($value) }</token>
};

(:----------------------------------------------------------------------------------------------------:)
(: JSON serializing :)

declare function xqilla:serialize-json($json-xml as element()?)
  as xs:string?
{
  if(empty($json-xml)) then () else

  string-join(
    xqilla:serializeJSONElement($json-xml)
  ,"")
};

declare %private function xqilla:serializeJSONElement($e as element())
  as xs:string*
{
  if($e/@type = "object") then xqilla:serializeJSONObject($e)
  else if($e/@type = "array") then xqilla:serializeJSONArray($e)
  else if($e/@type = "null") then "null"
  else if($e/@type = "boolean") then string($e)
  else if($e/@type = "number") then string($e)
  else ('"', xqilla:escape-json-string($e), '"')
};

declare %private function xqilla:serializeJSONObject($e as element())
  as xs:string*
{
  "{",
  $e/*/(
    if(position() = 1) then () else ",",
    '"', xqilla:escape-json-string(@name), '":',
    xqilla:serializeJSONElement(.)
  ),
  "}"
};

declare %private function xqilla:serializeJSONArray($e as element())
  as xs:string*
{
  "[",
  $e/*/(
    if(position() = 1) then () else ",",
    xqilla:serializeJSONElement(.)
  ),
  "]"
};

(:----------------------------------------------------------------------------------------------------:)
(: JSON unescaping :)

declare function xqilla:unescape-json-string($val as xs:string)
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
        codepoints-to-string(xqilla:decode-hex-string(substring($match, 3)))
      else string($match)
  ,"")
};

declare function xqilla:escape-json-string($val as xs:string)
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
declare function xqilla:decode-hex-string($val as xs:string)
  as xs:integer
{
  xqilla:decodeHexStringHelper(string-to-codepoints($val), 0)
};

declare %private function xqilla:decodeHexChar($val as xs:integer)
  as xs:integer
{
  let $tmp := $val - 48 (: '0' :)
  let $tmp := if($tmp <= 9) then $tmp else $tmp - (65-48) (: 'A'-'0' :)
  let $tmp := if($tmp <= 15) then $tmp else $tmp - (97-65) (: 'a'-'A' :)
  return $tmp
};

declare %private function xqilla:decodeHexStringHelper($chars as xs:integer*, $acc as xs:integer)
  as xs:integer
{
  if(empty($chars)) then $acc
  else xqilla:decodeHexStringHelper(remove($chars,1), ($acc * 16) + xqilla:decodeHexChar($chars[1]))
};
