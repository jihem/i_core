//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//

#include <cstring>
#include "i_var.h"

i_var::i_var() {
}

i_var::~i_var(){
}

int i_var::getType() {
    return this->type;
}

char* i_var::getC()
{
    return this->value.c;
}

double i_var::getD()
{
    return this->value.d;
}

int i_var::getI()
{
    return this->value.i;
}

void i_var::setC(char *c)
{
    this->type=this->CHR;
    strncpy(this->value.c,c,10);
}

void i_var::setD(double d)
{
    this->type=this->DBL;
    this->value.d=d;
}

void i_var::setI(int i)
{
    this->type=this->INT;
    this->value.i=i;
}