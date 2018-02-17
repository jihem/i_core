//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#ifndef I_CORE_I_CORE_H
#define I_CORE_I_CORE_H

#include <list>
#include <map>
#include "i_ret.h"

class i_core
{

private:
    int e;
    std::map<std::string,std::list<i_var>*> c;
    std::list<i_var>::iterator i;
    std::list<i_var> *p;
    std::list<i_ret> r;
    std::list<double> s;
    std::map<std::string,double> v;
    std::map<std::string, void (i_core::*)()> f;
    int n;
public:
    i_core();
    ~i_core();
    void vpush(std::string n);
    void vpop(std::string n);
    void call(i_var i);
    void eval(std::string t);
    void exec();
    void ret();
    int state(int e);
    void word(i_var w);
    void _add();
    void _sub();
    void _mlt();
    void _div();
    void _abs();
    void _flr();
    void _cos();
    void _sin();
    void _sqr();
    void _dup();
    void _llt();
    void _lgt();
    void _leq();
    void _lnt();
    void _shw();
};

#endif //I_CORE_I_CORE_H
