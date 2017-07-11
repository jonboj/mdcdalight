import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';

class Person {
  String name;
  int age;
  Person(final String n, final int years){
    name = n;
    age = years;
  }
}

class HostElemPropBind implements IPropBind {

  int v1 = -17;
  Person personClient = new Person('Hans', 7);

  //// Binding instrumentation section ////
  static const String V1 = 'v1';
  static const String PERSON_NAME = 'personClient.name';
  static const String PERSON_AGE = 'personClient.age';

  static const Map<String, int> _propNameMap = const {V1 : 0, PERSON_NAME : 1, PERSON_AGE : 2};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(V1, () => v1, (final int i){ v1 = i; }),
    new PropertyBindSet(PERSON_NAME, () => personClient.name, (final String s){ personClient.name = s; }),
    new PropertyBindSet(PERSON_AGE, () => personClient.age, (final int i){ personClient.age = i; })];
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
