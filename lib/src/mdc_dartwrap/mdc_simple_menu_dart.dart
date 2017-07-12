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

import '../custom_element/html_import_manager.dart';
import '../custom_element/element_tag_bundle.dart';
import 'package:mdcdalight/src/binding/bind_base_ctrl.dart';
import '../binding/binding_types.dart';
import '../util/log_mdcda.dart';

import 'mdc_js_interop.dart' as mdcjs;
import 'mdc_webjs_path.dart';

class MdcSimpleMenuDartPropBind implements IPropBind {

  int selected = 0;

  //// Binding instrumentation section ////
  static const String SELECTED = 'selected';

  static const Map<String, int> _propNameMap = const {SELECTED : 0};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(SELECTED, () => selected, (final int i){ selected = i; })];
}

class MdcSimpleMenuDart extends HtmlElement with MdcSimpleMenuDartPropBind, BindBaseCtrl implements ICustomBindElement {

  static final LogMdcda _log = new LogMdcda.fromType(MdcSimpleMenuDart);

  static final TagMdcDartWrapCss tagBundle =  new TagMdcDartWrapCss(MDC_WEBJS_PATH, MdcSimpleMenuDart);

  static registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  mdcjs.MDCSimpleMenu _jsSimpleMenu;

  MdcSimpleMenuDart.created() : super.created() {
    _log.debug('created');
    classes.add(tagBundle.mdcTagName);
    _jsSimpleMenu = new mdcjs.MDCSimpleMenu(this);
    addEventListener('MDCSimpleMenu:selected', handleSelected);
    createBindFromElement(this);
  }

  void set open(final bool open) => _jsSimpleMenu.open = open;

  bool get open => _jsSimpleMenu.open;

  void handleSelected(final CustomEvent event){
    _log.debug('handleSelected : ' + event.detail['index'].toString());
    selected = event.detail['index'];
    updateProps([MdcSimpleMenuDartPropBind.SELECTED]);
  }

}
