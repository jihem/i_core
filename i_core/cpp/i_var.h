//
// Created by Jean-Marc 'jihem' QUERE on 01/03/2017.
//
#ifndef I_CORE_I_VAR_H
#define I_CORE_I_VAR_H

class i_var {
private:
    union u_var {
        char c[10];
        double d;
        int i;
    };
public:
    enum u_type {
        CHR=0,
        DBL=1,
        INT=2
    };
private:
    u_var value;
    u_type type;
public:
    i_var();
    ~i_var();

    int getType();
    char* getC();
    double getD();
    int getI();
    void setC(char *c);
    void setD(double d);
    void setI(int i);
};

#endif //I_CORE_I_VAR_H
