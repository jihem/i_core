//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#include <iostream>
#include <cstring>
//#include <list>
#include "i_core.h"

i_core::i_core() {
    this->e=3;
    this->c.insert(std::make_pair(" ", new std::list<i_var>()));
    this->p=this->c.at(" ");
    this->i=this->p->end();
    this->n=0;
    this->f.insert(std::make_pair("+",&i_core::_add));
    this->f.insert(std::make_pair("-",&i_core::_sub));
    this->f.insert(std::make_pair("*",&i_core::_mlt));
    this->f.insert(std::make_pair("/",&i_core::_div));
    this->f.insert(std::make_pair("abs",&i_core::_abs));
    this->f.insert(std::make_pair("flr",&i_core::_flr));
    this->f.insert(std::make_pair("cos",&i_core::_cos));
    this->f.insert(std::make_pair("sin",&i_core::_sin));
    this->f.insert(std::make_pair("sqr",&i_core::_sqr));
    this->f.insert(std::make_pair("#",&i_core::_dup));
    this->f.insert(std::make_pair("<",&i_core::_llt));
    this->f.insert(std::make_pair(">",&i_core::_lgt));
    this->f.insert(std::make_pair("=",&i_core::_leq));
    this->f.insert(std::make_pair("!",&i_core::_lnt));
    this->f.insert(std::make_pair(".",&i_core::_shw));
}

i_core::~i_core() {
    std::map<std::string,std::list<i_var>*>::iterator i;
    for (i=this->c.begin(); i!=this->c.end(); ++i) {
        delete i->second;
    }
    c.clear();
}

void i_core::eval(std::string t) {
    std::list<std::string> lw;

    std::string s="";

    size_t last = 0;
    size_t next = 0;
    while ((next = t.find(" ", last)) != std::string::npos) {
        lw.push_back(t.substr(last, next-last));
        last = next + 1;
    }
    lw.push_back(t.substr(last));

    while (!lw.empty()) {
        i_var w;
        s=(std::string)lw.front();
        try {
            double d;
            size_t test;
            d=std::stod (s,&test);
            w.setD(d);
            this->word(w);
        }
        catch (const std::invalid_argument& ia) {
            char *c = new char[s.length() + 1];
            strcpy(c, s.c_str());
            w.setC(c);
            delete [] c;
            this->word(w);
        }
        lw.pop_front();
    }
    this->e=0;
}

void i_core::word(i_var w) {
    if (w.getType()==w.CHR) {
        char *s=w.getC();
        switch (s[0]) {
            case ':':
                s++;
                if (this->c.find(s)!= c.end())
                {
                    std::cout << ":!!:" << s << std::endl;
                    delete c.at(s);
                    c.at(s)=new std::list<i_var>();
                } else
                {
                    std::cout << ":??:" << s << std::endl;
                    this->c.insert(std::make_pair(s, new std::list<i_var>()));
                }
                this->p=c.at(s);
                break;
            case ';':
                this->p=c.at(" ");
                //...
                break;
            default:
                this->p->push_back(w);
                break;
        }
        std::cout << "X-->" << w.getC() << std::endl;
    }
    else
    {
        std::cout << "--->" << w.getD() << std::endl;
        this->p->push_back(w);
    }
}

void i_core::ret() {
    if (! this->r.empty()) {
        i_ret r=this->r.back();
        this->r.pop_back();
        this->p=r.getP();
        this->i=r.getI();
    }
}

void i_core::vpush(std::string n)
{
    double r=0.0d;
    std::map<std::string,double>::iterator i=this->v.find(n);
    if (i!=this->v.end())
    {
        r=i->second;
    }
    this->s.push_back(r);
}

void i_core::vpop(std::string n)
{
    double d=this->s.back();
    this->s.pop_back();

    std::map<std::string,double>::iterator i=this->v.find(n);
    if (i!=this->v.end())
    {
        i->second=d;
    }
    else
    {
        this->v.insert(std::make_pair(n,d));
    }
}

void i_core::call(i_var i) {
    bool c=true;
    this->n++;
    if (i.getType()==i.CHR) {
        char *iC=i.getC();

// dump stack

        std::cout << "EX->" << i.getC() << std::endl;
        auto fnc=f.find(i.getC());
        if (fnc!=f.end()) {
            ((*this).*(fnc->second))();
            this->i++;
        } else {
            if (c && i.getC()[0]=='>')
            {
                this->vpop(std::string(i.getC()+1));
                this->i++;
                c=false;
            }

            if (c && i.getC()[0]=='<')
            {
                this->vpush(std::string(i.getC()+1));
                this->i++;
                c=false;
            }
            if (c && i.getC()[0]=='?')
            {
                double d=0.0d;
                if (! this->s.empty()) {
                    d=this->s.back();
                    this->s.pop_back();
                }
                if (d!=0.0d)
                {
                    iC++;
                } else
                {
                    this->i++;
                    c=false;
                }
            }
            if (c && this->c.find(std::string(iC))!=this->c.end())
            {
              this->r.push_back(*(new i_ret(this->p,++this->i)));
              this->p=this->c.find(std::string(iC))->second;
              this->i=p->begin();
            }

        }

    } else {
        std::cout << "E-->" << i.getD() << std::endl;
        this->s.push_back(i.getD());
        this->i++;
    }
}


void i_core::exec() {
    this->r.clear();
    this->r.push_back(*(new i_ret(this->c.at(" "),this->c.at(" ")->begin())));
    this->s.clear();
    this->n=0;
    while (! this->r.empty()) {
        this->ret();
        while (this->i!=p->end()) {
            this->call(*(this->i));
        }
    }
    this->e=3;
}

int i_core::state(int e=-1) {
    if (e!=-1) {
        this->e=e;
    }
    return this->e;
}

void i_core::_add() { double d,e=this->s.back();this->s.pop_back();d=this->s.back();this->s.pop_back();this->s.push_back(d+e); }
void i_core::_sub() { double d,e=this->s.back();this->s.pop_back();d=this->s.back();this->s.pop_back();this->s.push_back(d-e); }
void i_core::_mlt() { double d,e=this->s.back();this->s.pop_back();d=this->s.back();this->s.pop_back();this->s.push_back(d*e); }
void i_core::_div() { double d,e=this->s.back();this->s.pop_back();d=this->s.back();this->s.pop_back();this->s.push_back(d/e); }
void i_core::_abs() { double d;d=this->s.back();this->s.pop_back();this->s.push_back(abs(d));}
void i_core::_flr() {}
void i_core::_cos() {}
void i_core::_sin() {}
void i_core::_sqr() {}
void i_core::_dup() { if (!this->s.empty()) { double d=this->s.back();  this->s.push_back(d); } }
void i_core::_llt() {}
void i_core::_lgt() {}
void i_core::_leq() {}
void i_core::_lnt() {}
void i_core::_shw() { double d;d=this->s.back();this->s.pop_back();std::cout << d << std::endl; }

