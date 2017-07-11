import 'dart:html';

import "package:test/test.dart";

import '../../../lib/src/util/load_sync_starter.dart';

import 'host_elem.dart';
import 'elem_depth0.dart';
import 'elem_depth1.dart';
import 'elem_depth2.dart';
import 'elem_depth3.dart';
import 'elem_bottom.dart';
import 'elem_depth_prop_bind.dart';

//Test of transitive bindings. Host sends to targets with oneway bindings,
//receives from targets with twoway bindings. Setup in a chain of three targets,
//where last target updates host.i1, this triggers and update of first target
//which triggers a new chain of update.


main() async {
  print('======= Start of chain bind test =======');

  ElemBottom.registerElement();
  ElemDepth3.registerElement();
  ElemDepth2.registerElement();
  ElemDepth1.registerElement();
  ElemDepth0.registerElement();
  HostElem.registerElement();

  const List<String> htmlFiles = const ['host_elem.html', 'elem_depth0.html',
                                        'elem_depth1.html', 'elem_depth2.html', 'elem_depth3.html', 'elem_bottom.html'];
  await new LoadSyncStarter().startLoadOfElement(startUnitTest, htmlFiles);
  print('======= End of chain bind test =======');
}

void startUnitTest(){
  print('main_std::startUnitTest()');
  ElemDepth0 elemDepth0 = document.body.querySelector('elem-depth0');
  ElemDepth1 elemDepth1 = document.body.querySelector('elem-depth1');
  ElemDepth2 elemDepth2 = document.body.querySelector('elem-depth2');
  ElemDepth3 elemDepth3 = document.body.querySelector('elem-depth3');
  ElemBottom elemBottom = document.body.querySelector('elem-bottom');
  HostElem hostElem = document.body.querySelector('host-elem');

  test("Get host-elem", () {
    expect(hostElem, isNotNull);
  });

  test("Get elem-depth0", () {
    expect(elemDepth0, isNotNull);
  });

  test("Get elem-depth1", () {
    expect(elemDepth1, isNotNull);
  });

  test("Get elem-depth2", () {
    expect(elemDepth2, isNotNull);
  });

  test("Get elem-depth3", () {
    expect(elemDepth3, isNotNull);
  });

  test("Get elem-bottom", () {
    expect(elemBottom, isNotNull);
  });

  //First ping in chain.
  test("elem-depth0 pdown 0", () {
    expect(elemDepth0.pdown, 0);
  });

  test("elem-depth1 pdown 0", () {
    //Send down from elem-depth0
    elemDepth0.updateProps([ElemDepthPropBind.PDOWN]);
    expect(elemDepth1.pdown, 0);
  });

  test("elem-depth2 pdown 0", () {
    //Send down from elem-depth1
    elemDepth1.updateProps([ElemDepthPropBind.PDOWN]);
    expect(elemDepth2.pdown, 0);
  });

  test("elem-depth3 pdown 0", () {
    //Send down from elem-depth2
    elemDepth2.updateProps([ElemDepthPropBind.PDOWN]);
    expect(elemDepth3.pdown, 0);
  });

  test("elem-bottom pdown 0", () {
    //Send down from elem-depth3
    elemDepth3.updateProps([ElemDepthPropBind.PDOWN]);
    expect(elemBottom.pdown, 0);
  });

  test("elem-bottom pup 0", () {
    expect(elemBottom.pup, 0);
  });

  test("elem-depth3 pup null", () {
    expect(elemDepth3.pup, isNull);
  });

  test("elem-depth3 pup 0", () {
    elemDepth3.updateProps([ElemDepthPropBind.PUP]);
    expect(elemDepth3.pup, 0);
  });

  test("elem-depth2 pup 0", () {
    elemDepth2.updateProps([ElemDepthPropBind.PUP]);
    expect(elemDepth2.pup, 0);
  });

  test("elem-depth1 pup 0", () {
    elemDepth1.updateProps([ElemDepthPropBind.PUP]);
    expect(elemDepth1.pup, 0);
  });

  test("elem-depth0 pup 0", () {
    elemDepth0.updateProps([ElemDepthPropBind.PUP]);
    expect(elemDepth0.pup, 0);
  });

  test("host-elem i2 null", () {
    expect(hostElem.i2, isNull);
  });

  test("host-elem i2 update to 0", () {
    hostElem.updateProps([HostElemPropBind.I2]);
    expect(hostElem.i2, 0);
  });

  test("loop ping 10 times", () {
    for(int i = 0; i < 20; ++i){
      hostElem.i1++;

      ///////// Send down new value ///////////
      hostElem.updateProps([HostElemPropBind.I1]);

      //Send down from elem-depth0
      elemDepth0.updateProps([ElemDepthPropBind.PDOWN]);

      //Send down from elem-depth1
      elemDepth1.updateProps([ElemDepthPropBind.PDOWN]);

      //Send down from elem-depth2
      elemDepth2.updateProps([ElemDepthPropBind.PDOWN]);

      //Send down from elem-depth3
      elemDepth3.updateProps([ElemDepthPropBind.PDOWN]);

      ///////// Send up ///////////

      //Get value from level below elem-depth3
      elemDepth3.updateProps([ElemDepthPropBind.PUP]);

      //Get value from level below elem-depth2
      elemDepth2.updateProps([ElemDepthPropBind.PUP]);

      //Get value from level below elem-depth1
      elemDepth1.updateProps([ElemDepthPropBind.PUP]);

      //Get value from level below elem-depth0
      elemDepth0.updateProps([ElemDepthPropBind.PUP]);

      //Update twoway binding at host
      hostElem.updateProps([HostElemPropBind.I2]);
    }
    expect(elemDepth0.pdown, 20);
    expect(elemDepth0.pup, 20);
    expect(elemDepth1.pdown, 20);
    expect(elemDepth1.pup, 20);
    expect(elemDepth2.pdown, 20);
    expect(elemDepth2.pup, 20);
    expect(elemDepth3.pdown, 20);
    expect(elemDepth3.pup, 20);
    expect(elemBottom.pdown, 20);
    expect(elemBottom.pup, 20);
    expect(hostElem.i1, 20);
    expect(hostElem.i2, 20);
  });


}



