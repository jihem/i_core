//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#ifndef I_CORE_I_RET_H
#define I_CORE_I_RET_H

#include <list>
#include "i_var.h"
class i_ret {
private:
    std::list<i_var> *p;
    std::list<i_var>::iterator i;
public:
    i_ret(std::list<i_var> *p,std::list<i_var>::iterator i);
    ~i_ret();

    std::list<i_var>::iterator getI();
    std::list<i_var> *getP();
};

#endif //I_CORE_I_RET_H
