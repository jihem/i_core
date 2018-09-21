package core

import (
	"fmt"
	"strings"
	"sort"
)

func _sdc(c *core) error {
	mk := make([]string, len(c.c))
	i := 0
	for k  := range c.c {
		mk[i] = k
		i++
	}
	sort.Strings(mk)

	fmt.Println("\n-cc-")
	for _,n:=range mk {
		c.CCDump(0, n, -1)
	}
	return nil
}

func _sdr(c *core) error {
	var l int

	fmt.Println("\n-ac-")
	c.SADump(c.a)
	fmt.Println("-sk-")
	c.SADump(c.s)
	fmt.Println("-rt-")
	l = len(c.r)
	c.CCDump(l, c.p, c.i-1)
	l--
	for l >= 0 {
		c.CCDump(l, c.r[l].p, c.r[l].i-1)
		l--
	}
	return nil
}

func _sdf(c *core) error {
	var s =" :a ; ?: ?; ?a!b >a <a"
	fmt.Println("-fn-")
	for k:=range c.f {
		s+=" "+k
	}
	f:=strings.Split(s[1:]," ")
	sort.Strings(f)
	fmt.Println(strings.Join(f," "))
	return nil
}

func (c *core) SADump(sa []Variant) {
	var l int
	var t string

	l = len(sa)
	l--
	for l >= 0 {
		switch sa[l].Class() {
		case 1:
			t, _ = sa[l].String()
		case 2:
			t, _ = sa[l].String()
			// case 3:
		}
		fmt.Printf("%04d :%s\n", l, t)
		l--
	}
}

func (c *core) CCDump(l int, cp string, ci int) {
	var s string
	s = fmt.Sprintf("%04d :%s -> ", l, cp)
	for i, v := range c.c[cp] {
		if i == ci {
			s += "["
		}
		switch v.Class() {
		case 0:
			t, _ := v.Term()
			s += t
		case 1:
			t, _ := v.String()
			s += t
		case 2:
			t, _ := v.String()
			s += "\"" + t + "\""
			// case 3:
		}
		if i == ci {
			s += "]"
		}
		s += " "
	}
	fmt.Println(s)
}

func (c *core) Dump() {
	_sdr(c)
}