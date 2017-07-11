import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';


class TargetElembPropBind implements IPropBind {

  int b1 = 808;
  int b2 = 28;
  String s1;

  //// Binding instrumentation section ////
  static const String B1 = 'b1';
  static const String B2 = 'b2';
  static const String S1 = 's1';
  static const Map<String, int> _propNameMap = const {B1 : 0, B2 : 1, S1 : 2};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;

  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(B1, () => b1, (final int i){ b1 = i;}),
    new PropertyBindSet(B2, () => b2, (final int i){ b2 = i;}),
    new PropertyBindSet(S1, () => s1, (final String s){ s1 = s;})];
}

class TargetElemb extends HtmlElement with TargetElembPropBind, BindBaseCtrl implements ICustomBindElement {

  static const String PATH = '';
  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(PATH, TargetElemb);

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  TargetElemb.created(): super.created(){
    print('TargetElemb.created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.append(n);

    createBindFromElement(this);
  }

}
