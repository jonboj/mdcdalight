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

import 'dart:html';

import '../util/utils.dart';
import '../util/log_mdcda.dart';


//Small cache to build typename map for custom elements. Cache build in vm or dart2js debug mode,
// a builded cache used in dart2js minimized mode.
class CustomElementReg {

  static final LogMdcda _log = new LogMdcda.fromType(CustomElementReg);

  static Map<Type, String> _typeNameMap = new Map<Type, String>();
  static String _elementsQSelectorStr;

  static initWithDump(final Map<Type, String> dumpFromDebug){
    _typeNameMap = dumpFromDebug;
    _elementsQSelectorStr = elementsQuerySelector();
  }

  static String getTypeName(final Type t) {

    if (!_typeNameMap.containsKey(t)){
      //Only valid in non minimized mode, used to build const map for minimized mode.
      if (RuntimeEnv.minimized){
        _log.warn('getTypeName warning called in release mode with uncached type : '
            + t.runtimeType.toString());
      }
      _typeNameMap[t] = t.toString();

      //Update the query selector
      _elementsQSelectorStr = elementsQuerySelector();
    }
    return _typeNameMap[t];
  }

  static String dumpToDartMap(){
    Iterable<String> namesWithGoose = _typeNameMap.values.map((final String name) => "'" + name + "'");
    return new Map<Type, String>.fromIterables(_typeNameMap.keys, namesWithGoose).toString();
  }

  static String elementsQuerySelector(){

    //template elements with attribute 'is'.
    const String CSS_TEMPLATE_WORKAROUND = ', template[is]';

    final qSelectorsStr = _typeNameMap.values.map((final String classname)
                                     => ElementTagBundle.classNameToTag(classname)).toList().toString();
    //Hacky remove ] and [ from the list dump.
    return qSelectorsStr.substring(0, qSelectorsStr.length - 1).substring(1) + CSS_TEMPLATE_WORKAROUND;
  }

  static List<Element> getChildCustomElements(final DocumentFragment docFrag){
    if (_typeNameMap.isEmpty){
      return [];
    }
    return docFrag.querySelectorAll(_elementsQSelectorStr);
  }
}


//Handling name and syntax conventions between file, class, element and style names.
abstract class ElementTagBundle {

  final String _elementNameDart;
  final String _elementTag;
  final String _path;
  final Type _type;
  String extend = null;

  ElementTagBundle(final String this._path, final Type this._type)
      : _elementNameDart = CustomElementReg.getTypeName(_type),
        _elementTag = classNameToTag(CustomElementReg.getTypeName(_type)){}

  //AnElementClass => an-element-class
  static String classNameToTag(final String classname){
    //Insert '-' before uppercase
    final String withTag =
      classname.replaceAllMapped(new RegExp(r'[A-Z]'), (Match m) => '-' + m[0].toString());
    return withTag.toLowerCase().substring(1);//Remove first '-'
  }

  String get classNameDart => _elementNameDart;

  String get elementTag => _elementTag;

  Type get elementType => _type;

  String get fileName;//Implemented by subclasses.

  set extendClass(final String classTag) => extend = classTag;
}

//Tagging of pure dart custom elements
class TagBundleCustomDart extends ElementTagBundle {

  TagBundleCustomDart(final String path, final Type customElementClass):
        super(path, customElementClass);

  String get htmlFileName => _path + _elementTag.replaceAll('-', '_') + '.html';

  String get fileName => htmlFileName;
}

//Common tagging for html and css import
abstract class TagMdcDartWrap extends ElementTagBundle {

  static const String DART_ELEMENT_POSTFIX = 'Dart';
  static const String MDC_CLASS_PREFIX = 'MDC';

  final String _mdcClassName;

  TagMdcDartWrap(final String path, final Type customElementClass) :
        _mdcClassName = _removeDartPostfix(CustomElementReg.getTypeName(customElementClass)),
        super(path, customElementClass);

  static String _removeDartPostfix(final String className){
    return className.substring(0, className.length - DART_ELEMENT_POSTFIX.length);
  }

  static String _removeDartPostfix1(final String className){
    return className.substring(0, className.length - DART_ELEMENT_POSTFIX.length - 1);
  }

  //from MdcElement to MDCElement
  String get mdcClassName => MDC_CLASS_PREFIX + _mdcClassName.substring(MDC_CLASS_PREFIX.length);

  String get mdcTagName => _removeDartPostfix1(_elementTag);

}

//Css link to wrapped mdc
class TagMdcDartWrapCss extends TagMdcDartWrap {

  TagMdcDartWrapCss(final String path, final Type customElementClass)
      :super(path, customElementClass);

  String get mdcCssFileName {
    List<String> tokens = _elementTag.split('-');
    tokens.removeLast();//Last is 'dart', before package name.
    return _path + 'mdc.' + tokens.last + '.css';
  }

  String get fileName => mdcCssFileName;
}
