import 'dart:html';

import "package:test/test.dart";

import '../../../lib/src/util/load_sync_starter.dart';

import 'host_elem.dart';
import 'target_elem.dart';

//Test of transitive bindings. Host sends to targets with oneway bindings,
//receives from targets with twoway bindings. Setup in a chain of three targets,
//where last target updates host.i1, this triggers and update of first target
//which triggers a new chain of update.

main() async {
  print('======= Start of transitive bind test =======');

  TargetElem.registerElement();
  HostElem.registerElement();

  await new LoadSyncStarter().startLoadOfElement(startUnitTest, ['target_elem.html', 'host_elem.html']);
  print('======= End of transitive bind test =======');
}

void startUnitTest(){
  print('main_std::startUnitTest()');
  HostElem hostElem = document.body.querySelector('host-elem');
  TargetElem targetElem0 = document.getElementById('id_t0');
  TargetElem targetElem1 = document.getElementById('id_t1');
  TargetElem targetElem2 = document.getElementById('id_t2');
  test("Get host-elem", () {
    expect(hostElem, isNotNull);
  });

  //First target - 0.
  test("Get target-elem 0", () {
    expect(targetElem0, isNotNull);
  });

  test("Get target-elem 0 pdown check", () {
    expect(targetElem0.pdown, 0);
  });

  test("Get host-elem i2 check", () {
    expect(hostElem.i2, null);
    hostElem.updateProps([HostElemPropBind.I2]);
    expect(hostElem.i2, 0);
  });

  //Second target - 1.
  test("Get target-elem 1", () {
    expect(targetElem1, isNotNull);
  });

  test("Get target-elem 1 pdown check", () {
    expect(targetElem1.pdown, 0);
  });

  test("Get host-elem i3 check", () {
    hostElem.updateProps([HostElemPropBind.I3]);
    expect(hostElem.i3, 0);
  });

  //Third target - 2.
  test("Get target-elem 2", () {
    expect(targetElem2, isNotNull);
  });

  test("Get target-elem 2 pdown check", () {
    expect(targetElem2.pdown, 0);
  });

  test("Get host-elem i4 check", () {
    hostElem.updateProps([HostElemPropBind.I4]);
    expect(hostElem.i4, 0);
  });

  test("Get target-elem 0 pdown check", () {
    expect(targetElem0.pdown, 1);
    expect(targetElem0.pup, 1);
  });

  test("Transition loop 10 times", () {
    //Loop updates
    for(int i = 0; i < 10; ++i){
      hostElem.updateProps([HostElemPropBind.I2]);
      hostElem.updateProps([HostElemPropBind.I3]);
      hostElem.updateProps([HostElemPropBind.I4]);
    }
    expect(targetElem0.pdown, 11);
    expect(targetElem0.pup, 11);
    expect(targetElem1.pdown, 10);
    expect(targetElem1.pup, 10);
    expect(targetElem2.pdown, 10);
    expect(targetElem2.pup, 10);
  });



}



