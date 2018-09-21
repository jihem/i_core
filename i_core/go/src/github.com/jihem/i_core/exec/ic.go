package main

import (
	"github.com/jihem/i_core/core"
	"fmt"
	"os"
	"bufio"
	"io/ioutil"
	"errors"
	"path/filepath"
)

func main() {
	var txt = "I_C( °)RE 0.7 Jean-Marc 'jihem' Quéré [codyssea.com] 2016-2018"

	switch len(os.Args) {
	case 1:
		fmt.Print(txt)
		myCore := core.NewCore()
		cin := bufio.NewScanner(os.Stdin)
		for txt != "" {
			fmt.Print("\n> ")
			cin.Scan()
			txt = cin.Text()
			if txt != "" {
				//myCore := core.NewCore()
				myCore.SetC(" ", make([]core.Variant, 0))
				myCore.Eval(txt)
				e := myCore.Exec()
				if e != nil {
					fmt.Println(e.Error())
					myCore.Dump()
				}
			}
		}
	case 3:
		var e error
		switch os.Args[1] {
		case "-e":
			txt = os.Args[2]
		case "-f":
			if b, e := ioutil.ReadFile(os.Args[2]); e == nil {
				txt = string(b)
			} else {
				e = errors.New("file i/o error")
			}
		}
		if e==nil {
			myCore := core.NewCore()
			myCore.Eval(txt)
			e = myCore.Exec()
			if e != nil {
				fmt.Println(e.Error())
				myCore.Dump()
			}
		}
	default:
		var f=filepath.Base(os.Args[0])
		fmt.Println(txt)
		fmt.Println("Usage:")
		fmt.Println(f)
		fmt.Println(f+" -e \"program line\"")
		fmt.Println(f+" -f \"filename.ic\"")
	}
	/*
	:LP # . 1 - # ?LP ; 5 LP 0 .
	:SA # . 1 - ; :LP SA # ?LP ; 5 LP 0 .
	:SA 1 2 + ; SA SA + .
	:L 1 - # # . .s ?: >_ ; 5 L
	:L 1 - # # . .s ?L ; 5 L >_
	:dice rnd * flr 1 + . ; 6 dice
	*/
}
