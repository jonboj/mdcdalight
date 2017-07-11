import 'dart:html';

import '../../../lib/src/binding/bind_base_ctrl.dart';
import '../../../lib/src/custom_element/html_import_manager.dart';
import '../../../lib/src/custom_element/element_tag_bundle.dart';

import 'elem_depth_prop_bind.dart';

class ElemDepth2 extends HtmlElement with ElemDepthPropBind, BindBaseCtrl implements ICustomBindElement {

  static const String PATH = '';
  static final TagBundleCustomDart tagBundle = new TagBundleCustomDart(PATH, ElemDepth2);

  static void registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  ElemDepth2.created(): super.created(){
    print('ElemDepth2.created()');
    final Node n = HtmlImportManager.nodeFromTemplate(tagBundle);
    this.append(n);

    createBindFromElement(this);
  }
}
