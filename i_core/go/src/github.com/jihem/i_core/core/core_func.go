package core

import (
	"fmt"
	"math"
	"errors"
	"math/rand"
	"strconv"
	"bufio"
	"os"
	"io/ioutil"
)

func _acc(c *core) error {
	var e error
	var s Variant

	f, _ := c.c[c.p][c.i].Term()
	switch f {
	case ">>":
		if s, e = c.spop(); e == nil {
			c.apush(s)
		}
	case "<<":
		if s, e = c.apop(); e == nil {
			c.spush(s)
		}
	}
	return e
}

func _uop(c *core) error {
	var e error
	var s Variant
	if s, e = c.spop(); e == nil {
		f, _ := c.c[c.p][c.i].Term()
		switch f {
		case "!":
			if s.Class() == 1 {
				s, _ := s.Number()
				if s == 0 {
					c.spush(_TRUE)
				} else {
					c.spush(_FALSE)
				}
			} else {
				e = errors.New("non-numeric literal")
			}
		case "#":
			c.spush(s)
			c.spush(s)
		}
	}
	return e
}

func _bop(c *core) error {
	var e error
	var s, n Variant
	if s, e = c.spop(); e == nil {
		if n, e = c.spop(); e == nil {
			if s.Class() == n.Class() {
				f, _ := c.c[c.p][c.i].Term()
				v := NewVariant()
				switch s.Class() {
				case 1:
					s, _ := s.Number()
					n, _ := n.Number()
					switch f {
					case "+":
						v.SetNumber(n + s)
					case "-":
						v.SetNumber(n - s)
					case "*":
						v.SetNumber(n * s)
					case "/":
						if s != 0 {
							v.SetNumber(n / s)
						} else {
							e = errors.New("divide by zero")
						}
					case "min":
						if s < n {
							v.SetNumber(s)
						} else {
							v.SetNumber(n)
						}
					case "max":
						if s > n {
							v.SetNumber(s)
						} else {
							v.SetNumber(n)
						}
					case "avg":
						v.SetNumber((n + s) / 2)
					}
				case 2:
					s, _ := s.String()
					n, _ := n.String()
					switch f {
					case "+":
						v.SetString(n + s)
					case "-":
						e = errors.New("operator not supported for strings")
					case "*":
						e = errors.New("operator not supported for strings")
					case "/":
						e = errors.New("operator not supported for strings")
					case "min":
						if s < n {
							v.SetString(s)
						} else {
							v.SetString(n)
						}
					case "max":
						if s > n {
							v.SetString(s)
						} else {
							v.SetString(n)
						}
					case "avg":
						e = errors.New("avg not supported for strings")
					}
					// case 3:
				}
				if v.Class() != 0 {
					c.spush(v)
				}
			} else {
				e = errors.New("mixed types")
			}
		}
	}
	return e
}

func _fn1(c *core) error {
	var e error
	var s, n Variant
	if s, e = c.spop(); e == nil {
		if s.Class() == 1 {
			s, _ := s.Number()
			f, _ := c.c[c.p][c.i].Term()
			v := NewVariant()
			switch f {
			case "abs":
				v.SetNumber(math.Abs(s))
			case "cos":
				s = math.Cos(_DG2RD * s)
				if math.Abs(s) < 1e-16 {
					s = 0
				}
				v.SetNumber(s)
			case "flr":
				v.SetNumber(math.Floor(s))
			case "sin":
				s = math.Sin(_DG2RD * s)
				if math.Abs(s) < 1e-16 {
					s = 0
				}
				v.SetNumber(s)
			case "sqr":
				if s >= 0 {
					v.SetNumber(math.Sqrt(s))
					c.spush(v)
				} else {
					e = errors.New("negative square root")
				}
			case "str":
				v.SetString(strconv.FormatFloat(s, 'f', -1, 64))
			case "[":
				if n, e = c.spop(); e == nil {
					if n.Class() == 2 {
						n, _ := n.String()
						s := int(s)
						if s >= 0 && s <= len(n) {
							v.SetString(n[s:])
						} else {
							e = errors.New("slice bound out of range")
						}
					} else {
						e = errors.New("non-numeric literal")
					}
				}
			case "]":
				if n, e = c.spop(); e == nil {
					if n.Class() == 2 {
						n, _ := n.String()
						s := int(s)
						if s >= 0 && s <= len(n) {
							v.SetString(n[0:s])
						} else {
							e = errors.New("slice bound out of range")
						}
					} else {
						e = errors.New("non-numeric literal")
					}
				}
			}
			if v.Class() != 0 {
				c.spush(v)
			}
		} else {
			e = errors.New("non-numeric literal")
		}
	}
	return e
}

func _fn2(c *core) error {
	var e error
	var s Variant
	if s, e = c.spop(); e == nil {
		if s.Class() == 2 {
			s, _ := s.String()
			f, _ := c.c[c.p][c.i].Term()
			v := NewVariant()
			switch f {
			case "len":
				v.SetNumber(float64(len(s)))
			case "val", "val?":
				var f64 float64
				if f64, e = strconv.ParseFloat(s, 64); e == nil {
					v.SetNumber(f64)
					if f == "val?" {
						c.spush(v)
						v = NewVariant()
						v.SetNumber(1)
					}
				} else {
					if f == "val?" {
						v.SetNumber(0)
						e = nil
					} else {
						e = errors.New("string to numeric conversion error")
					}
				}
			}
			if v.Class() != 0 {
				c.spush(v)
			}
		} else {
			e = errors.New("non-numeric literal")
		}
	}
	return e
}

func _cmp(c *core) error {
	var e error
	var s, n Variant
	if s, e = c.spop(); e == nil {
		if n, e = c.spop(); e == nil {
			if s.Class() == n.Class() {
				f, _ := c.c[c.p][c.i].Term()
				switch s.Class() {
				case 1:
					s, _ := s.Number()
					n, _ := n.Number()
					switch f {
					case "<":
						if s > n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					case ">":
						if s < n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					case "=":
						if s == n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					}
				case 2:
					s, _ := s.String()
					n, _ := n.String()
					switch f {
					case "<":
						if s > n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					case ">":
						if s < n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					case "=":
						if s == n {
							c.spush(_TRUE)
						} else {
							c.spush(_FALSE)
						}
					}
					// case 3:
				}
			} else {
				e = errors.New("mixed types")
			}
		}
	}
	return e
}

func _si1(c *core) error {
	var e error
	s := NewVariant()
	f, _ := c.c[c.p][c.i].Term()
	switch f {
	case "rnd":
		s.SetNumber(rand.Float64())
		c.spush(s)
	}
	return e
}

func _shw(c *core) error {
	var e error
	var s Variant

	f, _ := c.c[c.p][c.i].Term()
	switch f {
	case ".", "..":
		if s, e = c.spop(); e == nil {
			switch s.Class() {
			case 1, 2:
				s, _ := s.String()
				if f == "." {
					fmt.Println(s)
				} else {
					fmt.Print(s)
				}
				// case 3:
			}
		}
	case ".?":
		cin := bufio.NewScanner(os.Stdin)
		cin.Scan()
		s = NewVariant()
		s.SetString(cin.Text())
		c.spush(s)
	}
	return e
}

func _rst(c *core) error {
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
	return nil
}

func _lfl(c *core) error {
	var e error
	var b []byte
	var s Variant
	if s, e = c.spop(); e == nil {
		if s.Class() == 2 {
			s, _ := s.String()
			var txt = ""
			if b, e = ioutil.ReadFile(s); e == nil {
				txt = string(b)
				myCore := NewCore()
				myCore.Eval(txt)
				e = myCore.Exec()
				l:=make(map[string] bool,0)
				l[c.p]=true
				for _,lr:= range c.r {
					l[lr.p]=true
				}
				for k, v := range myCore.C() {
					if _,i:=l[k]; !i {
						c.SetC(k, v)
					} else {
						l[k]=false
					}
				}
				delete(l," ")
				txt=""
				for k, v:=range l {
					if !v {
						txt=txt+k+" "
					}
				}

				if len(txt)>0 {
					e = errors.New(txt + "not overwritable")
				}

			} else {
				e = errors.New("file i/o error")
			}
		}
	}
	return e
}
