// Copyright 2017 Jonas Bojesen. All Rights Reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'dart:html';

import '../custom_element/html_import_manager.dart';
import '../custom_element/element_tag_bundle.dart';

import 'mdc_webjs_path.dart';
import 'mdc_js_interop.dart' as mdcjs;


class MdcTemporaryDrawerDart extends HtmlElement {

  mdcjs.MDCTemporaryDrawer _jsTemporaryDrawer;
  static final TagMdcDartWrapCss tagBundle =  new TagMdcDartWrapCss(MDC_WEBJS_PATH, MdcTemporaryDrawerDart);

  static registerElement(){
    HtmlImportManager.registerBundleElement(tagBundle);
  }

  MdcTemporaryDrawerDart.created() : super.created() {
    print('MdcTemporaryDrawerDart.created');
    classes.add(tagBundle.mdcTagName);
    _jsTemporaryDrawer = new mdcjs.MDCTemporaryDrawer(this);
  }

  void open(final bool open){
   _jsTemporaryDrawer.open = open;
  }
}
