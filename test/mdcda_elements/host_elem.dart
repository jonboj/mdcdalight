import 'dart:html';

import '../../lib/src/binding/bind_base_ctrl.dart';
import '../../lib/src/binding/binding_types.dart';
import '../../lib/src/binding/list_repeat_parse.dart';
import '../../lib/src/custom_element/html_import_manager.dart';
import '../../lib/src/custom_element/element_tag_bundle.dart';

import '../../lib/src/mdcda_elements/mdcda_list_select.dart';


class Person {
  final String name;
  final int age;

  const Person(final String this.name, final int this.age);
}


class PersonWrap extends Person implements IListItemBind {
  static const String NAME = 'name';
  static const String AGE = 'age';

  const PersonWrap(final String name, final int age)
      : super(name, age);

  Map<String, PropertyBind> bindListAt() =>
      buildAccessMap([bindAtFactory(NAME, name), bindAtFactory(AGE, age)]);
}

class HostElemPropBind implements IPropBind {

  List<int> list1 =  [101, 0, -77];
  List<String> listterms =  ['light', 'stronger', 'hot', 'burning', 'melting!'];
  List<PersonWrap> listpersons = [new PersonWrap('Hans', 113), new PersonWrap('Grete', 111)];
  //// Binding instrumentation section ////
  static const String LIST1 = 'list1';
  static const String LISTTERMS = 'listterms';
  static const String LISTPERSONS = 'listpersons';

  static const Map<String, int> _propNameMap = const {LIST1 : 0, LISTTERMS : 1, LISTPERSONS : 2};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp =>
      [new PropertyBindSet(LIST1, () => list1, (final List<int> l){list1 = l;}),
       new PropertyBindSet(LISTTERMS, () => listterms, (final List<String> l){listterms = l;}),
       new PropertyBindSet(LISTPERSONS, () => listpersons, (final List<PersonWrap> p){listpersons = p;})];
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

  void attached(){
    print('HostElem.attached()');
    List<MdcdaListSelect> repElemList = MdcdaListSelect.childMdcdaListSelect(this);
    repElemList.forEach((final MdcdaListSelect repElem){
      repElem.fillList();
    });
  }

  void addIntToList(final int i){
    list1.add(i);
    List<MdcdaListSelect> repElemList = MdcdaListSelect.childMdcdaListSelect(this);
    repElemList.forEach((final MdcdaListSelect repElem){
      repElem.fillList();
    });
  }

  void addPerson(final Person p){
    listpersons.add(new PersonWrap(p.name, p.age));
    List<MdcdaListSelect> repElemList = MdcdaListSelect.childMdcdaListSelect(this);
    repElemList.forEach((final MdcdaListSelect repElem){
      repElem.fillList();
    });
  }

}
