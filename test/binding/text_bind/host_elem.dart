import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';


class HostElemPropBind implements IPropBind, IComputedBind {

  int i1 = -17;
  int i2 = 347;
  String str1 = 'Ciao';
  List<int> list1 =  [101, 0, -77];
  String computedStr(final int i) => 'HostElemPropBind.computedStr : ' + i.toString();

  //// Binding instrumentation section ////
  static const String I1 = 'i1';
  static const String I2 = 'i2';
  static const String STR1 = 'str1';
  static const String LIST1 = 'list1';
  static const String COMPUTED_STR_I2 = 'computedStr(i2)';

  static const Map<String, int> _propNameMap = const {I1 : 0, I2 : 1,STR1 : 2, LIST1 : 3};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [new PropertyBindSet(I1, () => i1, (final int i){i1 = i;}),
                                         new PropertyBindSet(I2, () => i2, (final int i){i2 = i;}),
                                         new PropertyBindSet(STR1, () => str1, (final String s){ str1 = s;}),
                                         new PropertyBindSet(LIST1, () => list1, (final List<int> l){list1 = l;})];

  Function get _computedStrF => () => this.computedStr(i2);
  Map<String, ComputedBind> get bindComputed =>
      {COMPUTED_STR_I2 : new ComputedBind(COMPUTED_STR_I2, _computedStrF, [I2])};
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

  //Override of method from mixin binding.
  String computedStr(final int i) => 'HostElem.computedStr : ' + i.toString();
}
