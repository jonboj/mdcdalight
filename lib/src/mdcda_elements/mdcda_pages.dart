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
import '../custom_element/html_import_manager.dart';
import 'package:mdcdalight/src/binding/bind_base_ctrl.dart';
import '../custom_element/element_tag_bundle.dart';
import '../binding/binding_types.dart';

import 'mdcda_elements_path.dart';

class MdcdaPagesPropBind implements IPropBind {

  int selectedPage = 0;

  //// Binding instrumentation section ////
  static const String SELECTED_PAGE = 'selected-page';

  static const Map<String, int> _propNameMap = const {SELECTED_PAGE : 0};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(SELECTED_PAGE, () => selectedPage, (final int i){ selectedPage = i; })];
}

class MdcdaPages extends HtmlElement with MdcdaPagesPropBind, BindBaseCtrl implements ICustomBindElement {

  static final LogMdcda _log = new LogMdcda.fromType(MdcdaPages);

  static const String CSS_SELECTED = 'mdcda-selected';

  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(MDCDA_ELEMENTS_PATH, MdcdaPages);

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  MdcdaPages.created(): super.created(){
    _log.debug('created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.createShadowRoot().append(n);

    //TODO investigate why createBindFromElement in created breaks instantion of AirList element.
    //Only Dartium - not Chrome. Test with Dartium 50.
    registerPropNotification(MdcdaPagesPropBind.SELECTED_PAGE, selectPage);
  }

  void attached(){
    _log.debug('attached()');
    //TODO investigate why
    createBindFromElement(this);
    selectPage();
  }

  void selectPage(){
    _log.debug('selectPage : ' + selectedPage.toString());
    List<DivElement> lDivs = divElemFilter.list(childNodes);

    lDivs[selectedPage].classes.add(CSS_SELECTED);
    List<DivElement> removeSelected = lDivs.where((final DivElement e) => e.classes.contains(CSS_SELECTED)).toList();
    removeSelected.remove(lDivs[selectedPage]);
    removeSelected.forEach((final DivElement e){e.classes.remove(CSS_SELECTED);});
  }
}
