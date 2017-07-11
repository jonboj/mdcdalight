import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';


abstract class TargetElemPropBind implements IPropBind {

  int a1 = 101;
  //// Binding instrumentation section ////
  static const String A1 = 'a1';
  static const Map<String, int> _propNameMap = const {A1 : 0};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [new PropertyBindSet(A1, () => a1, (final int i){a1 = i;})];
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

  void printA1(){
    print('Value of a1 : ' + a1.toString());
  }

}
