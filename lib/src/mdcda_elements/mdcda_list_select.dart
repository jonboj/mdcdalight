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

import 'package:mdcdalight/src/binding/bind_base_ctrl.dart';
import '../custom_element/element_tag_bundle.dart';
import '../custom_element/html_import_manager.dart';
import '../binding/binding_types.dart';
import '../binding/list_repeat_parse.dart';
import '../util/utils.dart';
import '../util/log_mdcda.dart';

import 'mdcda_event_util.dart';
import 'mdcda_elements_path.dart';

class SelectState {
  final int index;
  final bool state;
  const SelectState(final int this.index, final bool this.state);
}

class SelectChangeEvent extends MdcdaEvent {
  static const int SELECT_NOT_DEFINED = -1;//When selected value is undefined, used at e.g. registration.
  static const String LOC_TYPE = 'list-select-change';
  final int index;
  final bool state;
  //SelectChangeEvent with argument in constructor is used to obtain from class.
  const SelectChangeEvent()
      : index = SELECT_NOT_DEFINED, state = false, super(LOC_TYPE);

  SelectChangeEvent.fromSelect(final int this.index, final bool this.state)
      : super(LOC_TYPE);
}

const TypeFilter<MdcdaListSelect, Element> typeFilterMdcdaListSelect = const TypeFilter<MdcdaListSelect, Element>();

class MdcdaListSelectPropBind<T> implements IPropBind {
  List<T> dataList = [];
  int selected = 0;

  //// Binding instrumentation section ////
  static const String DATA_LIST = 'data-list';
  static const String SELECTED = 'selected';

  static const Map<String, int> _propNameMap = const {DATA_LIST : 0, SELECTED : 1};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
     new PropertyBindSet(DATA_LIST, () => dataList, (final List<T> l){dataList = l;}),
     new PropertyBindSet(SELECTED, () => selected, (final int i){ selected = i; })];
}

class MdcdaListSelect<T> extends TemplateElement with MdcdaListSelectPropBind, BindBaseCtrl implements ICustomBindElement {

  static final LogMdcda _log = new LogMdcda.fromType(MdcdaListSelect);

  static const String TEMPLATE_TAG = 'template';
  static const String CSS_SELECTED = 'mdcda-selected';

  static final TagBundleCustomDart tagBundle =
     new TagBundleCustomDart(MDCDA_ELEMENTS_PATH, MdcdaListSelect)..extendClass = TEMPLATE_TAG;

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  static List<MdcdaListSelect> childMdcdaListSelect(final Element e) =>
      typeFilterMdcdaListSelect.list(e.querySelectorAll(TEMPLATE_TAG));

  DivElement _container;

  MdcdaListSelect.created(): super.created(){
    _log.debug('created()');
    //Just css styling
    Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    append(n);

    createBindFromElement(this);
    registerPropNotification(MdcdaListSelectPropBind.SELECTED, selectItem);
  }

  void attached(){
    print('MdcdaListSelect.attached id : ' + id);
  }

  void fillList(){
    updateProps([MdcdaListSelectPropBind.SELECTED]);
    _log.debug('fillList dataList : ' + dataList.toString());
    List<Node> nodeList = buildStampNodeList(content, dataList);
    if (_container != null){
      _container.remove();
    }
    _container = new DivElement();
    parent.append(_container);
    _container.onClick.listen(clickHandler);

    nodeList.forEach((final Node n){ _container.append(n); });
    selectItem();
  }

  void selectItem(){
    const String SELECTED_ATTRIBUTE = 'aria-selected';
    _log.debug('selectItem : ' + selected.toString());
    List<DivElement> lDivs = divElemFilter.list(_container.childNodes);

    if (lDivs.isEmpty){
      //No elements in list
      return;
    }

    lDivs[selected].attributes[SELECTED_ATTRIBUTE] = '';
    List<DivElement> removeSelected = lDivs.where((final DivElement e) => e.attributes.containsKey(SELECTED_ATTRIBUTE)).toList();
    removeSelected.remove(lDivs[selected]);
    removeSelected.forEach((final DivElement e){e.attributes.remove(SELECTED_ATTRIBUTE);});

    SelectChangeEvent e = new SelectChangeEvent.fromSelect(selected, true);
    _log.debug('selectItem send event : ' + e.type);
    MdcdaEventUtil.dispatch(this, e);
  }

  void clickHandler(final MouseEvent e){
    _log.debug('clickHandler target : ' + e.target.toString());
    final List<DivElement> elems = divElemFilter.list(_container.childNodes);
    selected = elems.indexOf(e.target);
    _log.debug('clickHandler selected : ' + selected.toString());
    updateProps([MdcdaListSelectPropBind.SELECTED]);
    selectItem();
  }
}
