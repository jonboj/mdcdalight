import 'dart:html';

import "package:test/test.dart";

import '../../../lib/src/util/load_sync_starter.dart';

import 'host_elem.dart';

main() async {
  print('======= Start of text bind test =======');

  HostElem.registerElement();

  await new LoadSyncStarter().startLoadOfElement(startUnitTest, ['host_elem.html']);
  print('======= End of text bind test =======');
}

void startUnitTest(){
  print('main_std::startUnitTest()');
  HostElem hostElem = document.body.querySelector('host-elem');

  test("Get host-elem", () {
    expect(hostElem, isNotNull);
  });

  test("Int binding", () {
    DivElement divE = hostElem.querySelector('#id_i1');
    expect(divE.text, contains('-17'));
  });

  test("String binding", () {
    DivElement divE = hostElem.querySelector('#id_str1');
    expect(divE.text, contains('Ciao'));
  });

  test("List<int> binding", () {
    DivElement divE = hostElem.querySelector('#id_list1');
    expect(divE.text, contains('[101, 0, -77]'));
  });

  test("Combined binding", () {
    DivElement divE = hostElem.querySelector('#id_combined1');
    expect(divE.text, contains('[101, 0, -77]Ciao-17'));
  });

  test("Computed binding", () {
    DivElement divE = hostElem.querySelector('#id_computed');
    expect(divE.text, contains('value computedStr(i2) : HostElem.computedStr : 347'));
  });

}



