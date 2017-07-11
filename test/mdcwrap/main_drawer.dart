import 'dart:html';

import '../../lib/src/mdc_dartwrap/mdc_css_loader.dart';
import '../../lib/src/mdc_dartwrap/mdc_temporary_drawer_dart.dart';
import '../../lib/src/util/load_sync_starter.dart';


main() async {
  await MdcCSSLoader.loadCss(MdcComp.BASE_COMP);
  MdcTemporaryDrawerDart.registerElement();

  //mdc.drawer.css already, but need to wait for registration to complete.
  await new LoadSyncStarter()
      .startLoadOfElement(setupHandler, ['packages/mdcdalight/mdc_web_js_v0_15_0/mdc.drawer.css']);
}

void setupHandler(){
  print('main.setupHandler');
  MdcTemporaryDrawerDart drawerE = document.querySelector('mdc-temporary-drawer-dart');

  document.querySelector('#id_menu_button').onClick.listen((final Event e){
    drawerE.open(true);
  });

  drawerE.addEventListener('MDCTemporaryDrawer:open', (final Event e){
    print('Received MDCTemporaryDrawer:open');
  });

  drawerE.addEventListener('MDCTemporaryDrawer:close', (final Event e){
    print('Received MDCTemporaryDrawer:close');
  });
}