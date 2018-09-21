package core

import (
	"errors"
	"strconv"
)

type variant struct {
	value interface{}
	class int
}

type Variant interface {
	Class() int
	Term() (string,error)
	SetTerm(s string)
	Number() (float64, error)
	SetNumber(float64)
	String() (string, error)
	SetString(string)
}

func NewVariant() Variant {
	return &variant{}
}

func (v *variant) Class() int {
	return v.class
}

func (v *variant) Term() (string,error) {
	switch v.class {
	case 0:
		return v.value.(string), nil
	default:
		return "", errors.New("core.String: class " + strconv.Itoa(v.class) + ": invalid conversion")
	}
}

func (v *variant) SetTerm(s string) {
	v.value = s
	v.class = 0
}

func (v *variant) Number() (float64, error) {
	switch v.class {
	case 1:
		return v.value.(float64), nil
	case 2:
		f, e := strconv.ParseFloat(v.value.(string), 64)
		if e == nil {
			return f, e
		} else {
			return f, errors.New("core.Number: parsing \"" + v.value.(string) + "\": invalid syntax")
		}
	default:
		return 0, errors.New("core.Number: class " + strconv.Itoa(v.class) + ": invalid conversion")
	}
}

func (v *variant) SetNumber(f float64) {
	v.value = f
	v.class = 1
}

func (v *variant) String() (string, error) {
	switch v.class {
	case 1:
		return strconv.FormatFloat(v.value.(float64), 'f', -1, 64), nil
	case 2:
		return v.value.(string), nil
	default:
		return "", errors.New("core.String: class " + strconv.Itoa(v.class) + ": invalid conversion")
	}
}

func (v *variant) SetString(s string) {
	v.value = s
	v.class = 2
}
