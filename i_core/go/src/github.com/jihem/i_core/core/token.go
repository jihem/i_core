package core

type token struct {
	text  string
	class int
}

type Token interface {
	Text() string
	SetText(text string)
	Class() int
	SetClass(class int)
}

func NewToken(text string, class int) Token {
	return &token{text: text, class: class}
}

func (t *token) Text() string {
	return t.text
}

func (t *token) SetText(text string) {
	t.text = text
}

func (t *token) Class() int {
	return t.class
}

func (t *token) SetClass(class int) {
	t.class = class
}
