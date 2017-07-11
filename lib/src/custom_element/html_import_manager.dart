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

import '../util/log_mdcda.dart';
import 'element_tag_bundle.dart';

class HtmlImportManager {

  static final LogMdcda _log = new LogMdcda.fromType(HtmlImportManager);

  static const String IMPORT = 'import';
  static const String STYLESHEET = 'stylesheet';

  static const String CSS_EXT = '.css';

  static const String ID_HTML_LINK = 'id_link_mdccustom';

  static const String ATTR_BIND_PRIFX = 'mdcda-bind-';
  static const String REG_TEMPLATE = 'reg-template';
  static const String REG_TEMPLATE_SELECTOR = '#reg-template';

  static LinkElement insertLink(final String fileName){

    LinkElement linkE = new LinkElement();
    linkE.href = fileName;
    linkE.rel = _relFromFileName(fileName);
    _getBaseLink().append(linkE);

    //Then get element from the document in order to load.
    return getLink(fileName);
  }

  static String _relFromFileName(final String fileName){
    if (fileName.endsWith(CSS_EXT)){
      //css - stylesheet.
      return STYLESHEET;
    }

    //html (other) - import.
    return IMPORT;
  }

  static LinkElement getLink(final String fileName) {
    final String relStr = _relFromFileName(fileName);
    //html - import, css stylesheet
    return _getBaseLink().querySelector('link[rel="' + relStr + '"][href="' + fileName + '"]');
  }

  static MetaElement _getBaseLink(){
    MetaElement baseE = document.head.querySelector('meta[id="' + ID_HTML_LINK  + '"]');

    if (baseE == null){
      baseE = new MetaElement();
      baseE.id = ID_HTML_LINK;
      document.head.append(baseE);
    }
    return baseE;
  }

  //Register the template element
  static registerBundleElement(final ElementTagBundle tagWrap) {

    _log.info(() => 'registerBundleElement file : ' + tagWrap.fileName);
    //print('HtmlImportManager.registerBundleElement file : ' + tagWrap.fileName);
    //Load the html file which contains both js and css
    LinkElement linkE = HtmlImportManager.insertLink(tagWrap.fileName);
    //Need to handle async load
    linkE.onLoad.listen((Event e) {
      _log.info(() => 'registerBundleElement file : ' + tagWrap.fileName + ', '
              + tagWrap.elementType.toString() + ', ' + tagWrap.elementTag);

      //Tag the targets in template and store modified template.
      if (tagWrap is TagBundleCustomDart){
        _tagTargetsInTemplate(tagWrap);
      }

      if (tagWrap.extend == null){
        document.registerElement(tagWrap.elementTag, tagWrap.elementType);
      }else {
        document.registerElement(tagWrap.elementTag, tagWrap.elementType, extendsTag: tagWrap.extend);
      }

    });
  }

  static Node nodeFromTemplate(final TagBundleCustomDart tagWrap){
    _log.info(() => 'nodeFromTemplate : ' + tagWrap.elementTag);
    TemplateElement tempE = _getBaseLink().querySelector(REG_TEMPLATE_SELECTOR + tagWrap.elementTag);
    return document.importNode(tempE.content, true);
  }

  static void _tagTargetsInTemplate(final TagBundleCustomDart tagWrap) {
    LinkElement linkElement = HtmlImportManager.getLink(tagWrap.htmlFileName);
    TemplateElement templateE = linkElement.import.querySelector('template');

    if (templateE == null){
      //htmlfile doesn't contain template element
      return;
    }

    final String attBindTag = ATTR_BIND_PRIFX + tagWrap.elementTag;
    List<Element> baseL = CustomElementReg.getChildCustomElements(templateE.content);
    _log.debug(() => '_tagTargetsInTemplate : '
        + tagWrap.elementTag +  ', number of targets : ' + baseL.length.toString());
    //Mark target classes with attribute.
    baseL.forEach((final Element b) { b.attributes[attBindTag] = '';  });

    templateE.id = REG_TEMPLATE + tagWrap.elementTag;
    _getBaseLink().append(templateE);
  }

  static String attrStrTargetTag(final Element e) {
    return ATTR_BIND_PRIFX + e.tagName;
  }

}