import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';

class TargetElemPropBind implements IPropBind {

  int ponei1;
  String poneStr1;
  List<int> poneList1;

  int ptwoi1 = 1007;
  String ptwoStr1 = 'Hello Two way';
  List<int> ptwoList1 = [300, 1, 9999, 7];

  //// Binding instrumentation section ////
  //One way properties
  static const String ONEW_I1 = 'ponei1';
  static const String ONEW_STR1 = 'poneStr1';
  static const String ONEW_LIST1 = 'poneList1';

  //Two way properties
  static const String TWOW_I1 = 'ptwoi1';
  static const String TWOW_STR1 = 'ptwoStr1';
  static const String TWOW_LIST1 = 'ptwoList1';

  static const Map<String, int> _propNameMap = const {ONEW_I1 : 0, ONEW_STR1 : 1, ONEW_LIST1 : 2,
                                                     TWOW_I1 : 3, TWOW_STR1 : 4, TWOW_LIST1 : 5};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;

  List<PropertyBindSet> get bindProp => [new PropertyBindSet(ONEW_I1, () => ponei1, (final int i) { ponei1 = i; }),
    new PropertyBindSet(ONEW_STR1, () => poneStr1, (final String s) { poneStr1 = s; }),
    new PropertyBindSet(ONEW_LIST1, () => poneList1, (final List<int> l){ poneList1 = l; }),

    new PropertyBindSet(TWOW_I1, () => ptwoi1, (final int i) => ptwoi1 = i),
    new PropertyBindSet(TWOW_STR1, () => ptwoStr1, (final String s) => ptwoStr1 = s),
    new PropertyBindSet(TWOW_LIST1, () => ptwoList1, (final List<int> l) => ptwoList1 = l)];
}

class TargetElem extends HtmlElement with TargetElemPropBind, BindBaseCtrl implements ICustomBindElement {

  static const String PATH = '';
  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(PATH, TargetElem);


  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  TargetElem.created(): super.created(){
    print('TargetElem.created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.append(n);

    createBindFromElement(this);
  }

}
