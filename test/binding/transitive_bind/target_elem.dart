import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';


abstract class TargetElemPropBind implements IPropBind {

  int pdown;
  int pup;
  //// Binding instrumentation section ////
  static const String PDOWN = 'pdown';
  static const String PUP = 'pup';
  static const Map<String, int> _propNameMap = const {PDOWN : 0, PUP : 1};
  static final List<String> _attrKeys = attrKeyFromProp(_propNameMap);

  Map<String, int> get propNameIndex => _propNameMap;
  List<String> get attrKeys => _attrKeys;
  List<PropertyBindSet> get bindProp => [
     new PropertyBindSet(PDOWN, () => pdown, (final int i){pdown = i; sendUp();}),
     new PropertyBindSet(PUP, () => pup, (final int i){pup = i;})];

  void sendUp();
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

  void sendUp(){
    pup = pdown;
    //print('TargetElem::sendUp() id : ' + id + ', ( ' + pdown.toString() + ', ' + pup.toString() + ' )' );
    updateProps([TargetElemPropBind.PUP]);
  }
}
