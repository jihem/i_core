//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#include <iostream>
#include "i_core.h"

using namespace std;

int main()
{
    i_core ic;
//  ic.eval(":DEMO 5 6 + . ; DEMO");
//  ic.eval("5 >A <A <A + .");
//  ic.eval(":LOOP # . 1 - # ?LOOP ; 5 LOOP");
    ic.eval(":b # 5 * . ; :a # . b 1 - # ?a ; 5 a .");
    ic.exec();
    return EXIT_SUCCESS;
}
