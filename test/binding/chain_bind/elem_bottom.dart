import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';
import '../../../lib/src/binding/binding_types.dart';

import 'elem_depth_prop_bind.dart';

class ElemBottom extends HtmlElement with ElemDepthPropBind, BindBaseCtrl implements ICustomBindElement {

  static const String PATH = '';
  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(PATH, ElemBottom);

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  List<PropertyBindSet> get bindProp => [
    new PropertyBindSet(ElemDepthPropBind.PDOWN, () => pdown, (final int i){pdown = i; sendUp();}),
    new PropertyBindSet(ElemDepthPropBind.PUP, () => pup, (final int i){pup = i;})];

  ElemBottom.created(): super.created(){
    print('ElemBottom.created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.append(n);

    createBindFromElement(this);
  }

  void sendUp(){
    pup = pdown;
    print('ElemBottom::sendUp() id : ' + id + ', ( ' + pdown.toString() + ', ' + pup.toString() + ' )' );
    updateProps([ElemDepthPropBind.PUP]);
  }
}
