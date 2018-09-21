package core

import (
	"strconv"
	"errors"
	"math"
	"strings"
)

type cret struct {
	p string
	i int
}

type core struct {
	f map[string]func(self *core) error
	v map[string]Variant
	p string
	r []cret
	i int
	n int
	c map[string][]Variant
	e int
	s []Variant
	a []Variant
}

type Core interface {
	Eval(s string)
	Exec() error
	C() map[string][]Variant
	SetC(s string, v []Variant)
	StepByStep() error
	State() int
	SetState(e int)
	Dump()
}

func NewCore() Core {
	c := &core{}
	_rst(c)
	/*
		c.c = make(map[string][]Variant)
		c.c[" "] = make([]Variant, 0)
		c.v = make(map[string]Variant)
		c.r = make([]cret, 0)
		c.s = make([]Variant, 0)
		c.a = make([]Variant, 0)
		c.p = " "
		c.e = 3
		c.i = 0
		c.n = 0
	*/
	c.f = map[string]func(c *core) error{
		"<<":    _acc,
		">>":    _acc,
		"#":     _uop,
		"!":     _uop,
		"+":     _bop,
		"-":     _bop,
		"*":     _bop,
		"/":     _bop,
		"min":   _bop,
		"max":   _bop,
		"avg":   _bop,
		"abs":   _fn1,
		"flr":   _fn1,
		"cos":   _fn1,
		"sin":   _fn1,
		"sqr":   _fn1,
		"str":   _fn1,
		"[":     _fn1,
		"]":     _fn1,
		"len":   _fn2,
		"val":   _fn2,
		"val?":  _fn2,
		"rnd":   _si1,
		"<":     _cmp,
		">":     _cmp,
		"=":     _cmp,
		".":     _shw,
		"..":    _shw,
		".?":    _shw,
		".c":    _sdc,
		".s":    _sdr,
		".f":    _sdf,
		"load":  _lfl,
		"reset": _rst,
	}
	return c
}

func (c *core) ret() {
	l := len(c.r) - 1
	if l >= 0 {
		c.p = c.r[l].p
		c.i = c.r[l].i
		c.r = c.r[0:l]
	}
}

func (c *core) spop() (Variant, error) {
	var e error
	var v Variant
	l := len(c.s) - 1
	if l >= 0 {
		v = c.s[l]
		c.s = c.s[0:l]
	} else {
		v = NewVariant()
		e = errors.New("stack empty")
	}
	return v, e
}

func (c *core) spush(v Variant) {
	c.s = append(c.s, v)
}

func (c *core) apop() (Variant, error) {
	var e error
	var v Variant
	l := len(c.a) - 1
	if l >= 0 {
		v = c.a[l]
		c.a = c.a[0:l]
	} else {
		v = NewVariant()
		e = errors.New("stack empty")
	}
	return v, e
}

func (c *core) apush(v Variant) {
	c.a = append(c.a, v)
}

func (c *core) vpop(s string) error {
	var e error
	var v Variant
	if v, e = c.spop(); e == nil {
		c.v[s] = v
	}
	return e
}

func (c *core) vpush(s string) error {
	var e error
	if v, i := c.v[s]; i {
		c.spush(v)
	} else {
		e = errors.New("var '" + s + "' not defined")
	}
	return e
}

func (c *core) Eval(s string) {
	t := NewTokenizer()
	t.Parse(s + "  ")
	for _, t := range t.Tokens() {
		// fmt.Printf("'%v' (%v)\n", t.Text(), t.Class())
		switch t.Class() {
		case 0:
			switch t.Text()[0:1] {
			case ":":
				if len(c.c[c.p]) == 0 {
					delete(c.c, c.p)
				}
				// namespace management => :a ... :b ; ; => a, a.b
				k := t.Text()[1:len(t.Text())]
				c.c[k] = make([]Variant, 0)
				c.p = k
			case ";":
				if len(c.c[c.p]) == 0 {
					delete(c.c, c.p)
				}
				c.p = " "
			default:
				v := NewVariant()
				v.SetTerm(t.Text())
				c.c[c.p] = append(c.c[c.p], v)
			}
		case 1, 2:
			v := NewVariant()
			switch t.Class() {
			case 1:
				f, _ := strconv.ParseFloat(t.Text(), 64)
				v.SetNumber(f)
			case 2:
				v.SetString(t.Text())
			}
			c.c[c.p] = append(c.c[c.p], v)
			// case 3:
		}
	}
}

func (c *core) State() int {
	return c.e
}

func (c *core) SetState(e int) {
	c.e = e
}

func (c *core) call(v Variant) error {
	var e error
	var b bool
	var s Variant
	c.n++
	switch v.Class() {
	case 0:
		t, _ := v.Term()
		if f, i := c.f[t]; i {
			e = f(c)
		} else {
			l := len(t)
			switch t[0:1] {
			case ">":
				e = c.vpop(t[1:l])
				b = true
			case "<":
				e = c.vpush(t[1:l])
				b = true
			case "?":
				if s, e = c.spop(); e == nil {
					n, _ := s.Number()

					t0, t1 := "", ""
					t = t[1:l]
					if strings.Contains(t, "!") {
						ta := strings.Split(t, "!")
						t1 = ta[0]
						t0 = ta[1]
					} else {
						t1 = t
					}

					if n == 0 {
						t = t0
					} else {
						t = t1
					}

					switch t {
					case "":
						b = true
					case ":":
						c.i = -1
						b = true
					case ";":
						c.i = len(c.c[c.p])
						b = true
					}

				}
			}
			if !b {
				if _, i := c.c[t]; i {
					c.r = append(c.r, cret{p: c.p, i: c.i + 1})
					c.p = t
					c.i = -1
				} else {
					e = errors.New("fnc '" + t + "' not defined")
				}
			}
		}
	case 1, 2:
		c.spush(v)
		// case 3:
	}
	return e
}

func (c *core) C() map[string][]Variant {
	return c.c
}

func (c *core) SetC(s string, v []Variant) {
	c.c[s] = v
}

func (c *core) StepByStep() error {
	var e error
	switch c.e {
	case 0:
		c.v = make(map[string]Variant)
		c.r = make([]cret, 0)
		c.r = append(c.r, cret{p: " ", i: 0})
		c.s = make([]Variant, 0)
		c.e = 1
		c.n = 0
	case 1:
		if len(c.r) > 0 {
			c.ret()
			c.e = 2
		} else {
			c.e = 3
		}
	case 2:
		if c.i < len(c.c[c.p]) {
			e = c.call(c.c[c.p][c.i])
			c.i++
		}
	}
	return e
}

func (c *core) Exec() error {
	var e error
	c.v = make(map[string]Variant)
	c.r = make([]cret, 0)
	c.r = append(c.r, cret{p: " ", i: 0})
	c.s = make([]Variant, 0)
	c.a = make([]Variant, 0)
	c.n = 0
	for len(c.r) > 0 && e == nil {
		c.ret()
		for c.i < len(c.c[c.p]) && e == nil {
			e = c.call(c.c[c.p][c.i])
			c.i++
		}
	}
	c.e = 3
	return e
}

var _TRUE Variant
var _FALSE Variant
var _DG2RD float64

func init() {
	_TRUE = NewVariant()
	_TRUE.SetNumber(1)
	_FALSE = NewVariant()
	_FALSE.SetNumber(0)
	_DG2RD = math.Pi / 180
}
