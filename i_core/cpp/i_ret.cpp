//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#include "i_ret.h"

i_ret::i_ret(std::list<i_var> *p,std::list<i_var>::iterator i) {
    this->p=p;
    this->i=i;
};

i_ret::~i_ret() {
};

std::list<i_var>::iterator i_ret::getI() {
    return this->i;
};

std::list<i_var> *i_ret::getP() {
    return this->p;
};