package core

import (
	"strconv"
)

func IsNumeric(s string) bool {
	_, err := strconv.ParseFloat(s, 64)
	return err == nil
}

var delimiters = map[string]int{
	"/*": 1,
	"*/": 2,
	"//": 3,
	"\t": 4,
	"\r": 4,
	"\n": 4,
	"\"": 5,
	"{":  6,
	"}":  7,
	" ":  8,
}

func getDelimiterId(s string) (int, bool) {
	var (
		id int
		is bool
	)
	for k, v := range delimiters {
		if k == s[:len(k)] {
			id = v
			is = true
			break
		}
	}
	return id, is
}

type tokenizer struct {
	tokens []Token
	stream string
	text   string
	class  int
}

type Tokenizer interface {
	Parse(string)
	Tokens() []Token
}

func NewTokenizer() Tokenizer {
	return &tokenizer{class: 2}
}

/*
	class
	0 - term
	1 - number
	2 - string
	3 - statement
*/

func (t *tokenizer) add() {
	if ((len(t.text) > 0 ) && (t.class > 1)) || (t.class==3) {

		if t.class == 2 && !IsNumeric(t.text) {
			t.class--
		}

		t.tokens = append(t.tokens, NewToken(t.text, t.class-1))
	}
	t.class = 2
	t.text = ""
}

func (t *tokenizer) Parse(s string) {
	var i int

	if len(s) > 0 {
		t.stream += s
		n := len(t.stream) - 1
		for p := 0; p < n; {
			i = 1
			m := t.stream[p : p+2]
			mId, mIs := getDelimiterId(m)
			if mIs {
				switch mId {
				case 1: //"/*"
					if t.class == 2 {
						t.class = 1
						i = 2
					}
				case 2: //"*/"
					if t.class == 1 {
						t.add()
						i = 2
					}
				case 3: //"//"
					if t.class == 2 {
						t.class = 0
						i = 2
					}
				case 4: //"\n"
					switch t.class {
					case 0,2:
						t.add()
					default:
						t.text+=m[0:1]
					}
				case 5: //"\""
					switch t.class {
					case 2:
						t.class = 3
					case 3:
						if m[1:2] != "\"" {
							t.add()
						} else {
							t.text += m[0:1]
							i = 2
						}
					default:
						t.text += m[0:1]
					}
				case 6: //"{"
					if t.class == 2 {
						t.add()
						t.class = 4
					} else {
						t.text += m[0:1]
					}
				case 7: //"}"
					if t.class == 4 {
						t.add()
					} else {
						t.text += m[0:1]
					}
				case 8: //" "
					if t.class == 2 {
						t.add()
					} else {
						t.text += m[0:1]
					}
				}
			} else {
				t.text += m[0:1]
			}
			p += i
		}
		if i != 2 {
			t.stream = t.stream[n : n+1]
		} else {
			t.stream = ""
		}
	}
}

func (t *tokenizer) Tokens() []Token {
	return t.tokens
}
