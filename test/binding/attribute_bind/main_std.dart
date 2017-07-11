
import 'dart:html';

import "package:test/test.dart";

import '../../../lib/src/util/load_sync_starter.dart';

import 'host_elem.dart';
import 'target_elem.dart';

main() async {
  print('======= Start of attribute bind test =======');

  TargetElem.registerElement();
  HostElem.registerElement();

  await new LoadSyncStarter().startLoadOfElement(startUnitTest, ['target_elem.html', 'host_elem.html']);
  print('======= End of attribute bind test =======');
}

void startUnitTest(){
  print('main_std::startUnitTest()');
  HostElem hostElem = document.body.querySelector('host-elem');
  TargetElem targetElemProp = document.getElementById('id_propbind');
  TargetElem targetElemLiteral = document.getElementById('id_literalbind');

  //Test property binding
  test("Get host-elem", () {
    expect(hostElem, isNotNull);
  });

  test("Get target-elem", () {
    expect(targetElemProp, isNotNull);
  });

  //Oneway
  test("One way - target-elem pi1", () {
    expect(targetElemProp.ponei1, -17);
  });

  test("One way - target-elem pstr1", () {
    expect(targetElemProp.poneStr1, 'Ciao');
  });

  test("One way - target-elem plist1", () {
    expect(targetElemProp.poneList1, [101, 0, -77]);
  });

  //Twoway
  test("Two way - host-elem i1", () {
    targetElemProp.updateProps(['ptwoi1', 'ptwoStr1', 'ptwoList1']);
    hostElem.updateProps(['i1', 'str1', 'list1']);
    expect(hostElem.i1, 1007);
  });

  test("Two way - host-elem str1", () {
    expect(hostElem.str1, 'Hello Two way');
  });

  test("Two way - host-elem list1", () {
    expect(hostElem.list1, [300, 1, 9999, 7]);
  });

  //Test literal binding
  test("Get literal target-elem", () {
    expect(targetElemLiteral, isNotNull);
  });

  test("One way - literal target-elem pi1", () {
    expect(targetElemLiteral.ponei1, -23);
  });

  test("One way - literal target-elem pstr1", () {
    expect(targetElemLiteral.poneStr1, 'I am a literal!');
  });

  test("One way - literal target-elem plist1", () {
    expect(targetElemLiteral.poneList1, [3, 5, 6]);
  });


}



