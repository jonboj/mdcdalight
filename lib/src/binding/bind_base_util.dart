// Copyright 2017 Jonas Bojesen. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.


//Small util class for parsing of attribute bindings.
class AttrBindTags {
  final String _startTag;
  final String _endTag;
  final int _length;
  const AttrBindTags(final String this._startTag, final String this._endTag)
      : _length =  _startTag.length + _endTag.length;

  //If no value return empty String.
  String parseValueStr(final attrValue){
    if (attrValue == null){
      //Nothing to match.
      return '';
    }

    if (attrValue.startsWith(_startTag) && attrValue.endsWith(_endTag) && attrValue.length > _length) {
      //Pick token between brackets e.g. [[...]].
      return attrValue.substring(_startTag.length, attrValue.length - _endTag.length);
    }
    //No match.
      return '';
  }
}

//Memory optimization of Map<String, "Property"> since identical for all instances of a class,
// static to index of list used.
class PropertyListStrIndex<T> {

  final Map<String, int> _strMap;//For memory optimization only reference to static map.
  final List<String> _keysAttrFormat;
  final List<T> _values;
  const PropertyListStrIndex(final Map<String, int> this._strMap,
                             final List<T> this._values,
                             final List<String> this._keysAttrFormat);

  T operator[](final String indexStr) => _values[_strMap[indexStr]];
  operator[]=(final String indexStr, final T t) => _values[_strMap[indexStr]] = t;
  String propKeyFromAttrFormat(final String attrStr) => _strMap.keys.elementAt(_keysAttrFormat.indexOf(attrStr));

  Iterable<String> get keys => _strMap.keys;

  List<String> get attrKeys => _keysAttrFormat;
}

String property2Attr(final String propStr){
    //Insert '-' before uppercase
    final String withTag =
      propStr.replaceAllMapped(new RegExp(r'[A-Z]'), (Match m) => '-' + m[0].toString());
    return withTag.toLowerCase();
}
