
import 'dart:html';

import "package:test/test.dart";

import '../../../lib/src/util/load_sync_starter.dart';

import 'host_elem.dart';
import 'target_elem.dart';
import 'target_elemb.dart';

main() async {
  print('======= Start of minimal_bind test =======');

  TargetElem.registerElement();
  TargetElemb.registerElement();
  HostElem.registerElement();

  const List<String> htmlFiles = const ['target_elem.html', 'target_elemb.html', 'host_elem.html'];
  await new LoadSyncStarter().startLoadOfElement(startUnitTest, htmlFiles);
  print('======= End of minial test =======');
}

void startUnitTest(){
  print('main_std::startUnitTest()');
  HostElem hostElem = document.body.querySelector('host-elem');
  TargetElem targetElem = document.body.querySelector('target-elem');
  TargetElemb targetElemb = document.body.querySelector('target-elemb');

  test("Get host-elem", () {
    expect(hostElem, isNotNull);
  });

  test("Get target-elem", () {
    expect(targetElem, isNotNull);
  });

  test("target-elem has attribute a1", () {
    expect(targetElem.getAttribute('a1'), '[[v1]]');
  });

  test("target-elem has property a1 inital updated from host-elem property v1 update", () {
    expect(targetElem.a1, -17);
  });

  test("target-elem has property a1 updated from host-elem property v1 update to 211", () {
    hostElem.v1 = 211;
    hostElem.updateProps([HostElemPropBind.V1]);
    expect(targetElem.a1, 211);
  });

  test("Two-way binding from target-elemb b1 to host-elem v1", () {
    targetElemb.updateProps([TargetElembPropBind.B1]);
    hostElem.updateProps([HostElemPropBind.V1]);
    expect(hostElem.v1, 808);
  });

  test("text binding in target node content.", () {
    expect(targetElemb.text, contains('808'));
  });

  //Structured bindings

  test("Two-way binding to target-elemb s1 from host-elem personClient.name", () {
    //expect(targetElemb.s1, null);
    //hostElem.updateProps([HostElemPropBind.PERSON_NAME]);
    targetElemb.updateProps([TargetElembPropBind.S1]);
    expect(targetElemb.s1, 'Hans');
  });


  test("Two-way binding from target-elemb b2 to host-elem personClient.age", () {
    targetElemb.updateProps([TargetElembPropBind.B2]);
    hostElem.updateProps([HostElemPropBind.PERSON_AGE]);
    expect(hostElem.personClient.age, 28);
  });

}



