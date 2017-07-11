import 'dart:html';

import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';

abstract class HostElemPropBind implements IPropBind {

  int i1 = 0;
  int i2;
  //// Binding instrumentation section ////
  static const String I1 = 'i1';
  static const String I2 = 'i2';

  static const Map<String, int> _propNameMap = const {I1 : 0, I2 : 1};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(I1, () => i1, (final int i) { i1 = i; }),
    new PropertyBindSet(I2, () => i2, (final int i) { i2 = i; })];
}

class HostElem extends HtmlElement with HostElemPropBind, BindBaseCtrl implements ICustomBindElement {

  static const String PATH = '';
  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(PATH, HostElem);

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  HostElem.created(): super.created(){
    print('HostElem.created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.append(n);

    createBindFromElement(this);
  }

}
