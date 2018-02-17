#rem
 i_core
 Jean-Marc "jihem" QUERE - @wdwave
#end

#Import "<std>"

Using std..

#Import "assets/scripts/sample.ic"


Class ICoreRet
  Field p:List<Variant>
  Field i:Int
  Method New(p:List<Variant>,i:Int)
    Self.p=p
    Self.i=i
  End
End

Class ICore
  Field e:Int
  Field c:Map<String,List<Variant>>
  Field i:Int
  Field p:List<Variant>
  Field r:List<ICoreRet>
  Field s:List<Double>
  Field v:Map<String,Double>
  Field f:Map<String,Void()>
  Field n:Int

  Method New()
	  Self.e=3
	  Self.c=New Map<String,List<Variant>>
	  Self.c.Add(" ",New List<Variant>)
	  Self.p=Self.c.Get(" ")
	  Self.i=0
	  Self.r=New List<ICoreRet>
	  Self.s=New List<Double>
	  Self.v=New Map<String,Double>
	  Self.f=New Map<String,Void()>
	  Self.n=0
	  
      f.Add("+",Self._add)
	  f.Add("-",Self._sub)
	  f.Add("*",Self._mlt)
	  f.Add("/",Self._div)
	  f.Add("abs",Self._abs)
	  f.Add("flr",Self._flr)
	  f.Add("cos",Self._cos)
	  f.Add("sin",Self._sin)
	  f.Add("sqr",Self._sqr)
	  f.Add("#",Self._dup)
	  f.Add("<",Self._llt)
	  f.Add(">",Self._lgt)
	  f.Add("=",Self._leq)
	  f.Add("!",Self._lnt)				
      f.Add(".",Self._shw)
      
  End
  
  Method Ret()
    Local r:ICoreRet
    If Self.r.Count()>0 Then 
      r=Self.r.Last
      Self.p=r.p
      Self.i=r.i
      Self.r.RemoveLast()
    End 
  End
  
  Method SPop:Double()
    Local r:Double=0
    If Self.s.Count()>0 Then
      r=Self.s.Last
      Self.s.RemoveLast()
    End    
    'Print("----"+String(r))    
    Return r
  End
    
  Method SPush(v:Double)
    Self.s.Add(v)  
  End
  
  Method VPop(v:String)
	If Self.v.Contains(v) Then 
	  Self.v[v]=Self.SPop()
	Else
	  Self.v.Add(v,Self.SPop())
	End
  End
  
  Method VPush(v:String)
	If Self.v.Contains(v) Then 
	  Self.SPush(Self.v[v])
	Else
	  Self.SPush(0)
	End  
  End
  
  Method Call(i:Variant)
  	Local c:Bool=True
  	
	'If i.Type="Double" Then	  	
	'Print("->"+String(Cast<Double>(i)))
	'Else
	'Print("->"+Cast<String>(i))
	'End  	
	'For Local ii:Int=0 Until Self.s.Count()
	'  Print(String(ii)+" - "+ String(Cast<Double>(Self.s.ToArray()[ii])))
	'End  	 	
  	
  	Self.n=n+1
  	If i.Type="Double" Then	
  	  Self.SPush(Cast<Double>(i))
  	Else 	
  	  If Self.f.Contains(Cast<String>(i)) Then 
  	    Self.f[Cast<String>(i)]()
  	  Else
  	    If c And Cast<String>(i).Slice(0,1)=">" Then 
		  Self.VPop(Cast<String>(i).Slice(1,Cast<String>(i).Length))
  	      c=False
  	    End
  	    If c And Cast<String>(i).Slice(0,1)="<" Then 
		  Self.VPush(Cast<String>(i).Slice(1,Cast<String>(i).Length))
		  c=False
		End
  	    If c And Cast<String>(i).Slice(0,1)="?" Then 
		  If Self.SPop()<>0 Then 
		    i=Cast<String>(i).Slice(1,Cast<String>(i).Length)
		  Else
		    c=False
		  End
		End
		If c And Self.c.Contains(Cast<String>(i)) Then 
		  Self.r.Add(New ICoreRet(Self.p,Self.i+1))
		  Self.p=Self.c[Cast<String>(i)]
		  Self.i=-1
		End					
  	  End
  	End

	'Print("---")
	'For Local ii:Int=0 Until Self.s.Count()
	'  Print(String(ii)+" - "+ String(Cast<Double>(Self.s.ToArray()[ii])))
	'End  	 
	'Print("")	
	'  	
  	
  End
  
  Method Exec()
	Self.r=New List<ICoreRet>
	Self.r.Add(New ICoreRet(Self.c[" "],0))
	Self.s=New List<Double>
	Self.v=New Map<String,Double>
	Self.n=0  
	While Self.r.Count()>0
	  Self.Ret()
	  While Self.i<Self.p.Count() '<=
	    Self.Call(Self.p.ToArray()[Self.i])
	    Self.i=Self.i+1
	  End
	End
	Self.e=3
  End
  
  Method StepByStep()
    If Self.e=0 Then 
	  Self.r=New List<ICoreRet>
	  Self.r.Add(New ICoreRet(Self.c[" "],0))
	  Self.s=New List<Double>
	  Self.v=New Map<String,Double>
	  Self.n=0  
      Self.e=1
    End
    If Self.e=1 Then
      If Self.r.Count()>0 Then 
        Self.Ret()
        Self.e=2
      Else
      	Self.e=3
      End
    End
    If Self.e=2 Then
      If Self.i<Self.p.Count() Then ' <=
        Self.Call(Self.p.ToArray()[Self.i])
        Self.i=Self.i+1
      End
    End
  End
  
  Method Word(w:Variant)
    Local c:String,k:String
    If w.Type="String" Then    
      If Cast<String>(w).StartsWith(":") Then 
        k=Cast<String>(w).Slice(1,Cast<String>(w).Length)
        If Self.c.Contains(k) Then 
          Self.c[k]=New List<Variant>
        Else
          Self.c.Add(k,New List<Variant>)
        End
        Self.p=Self.c[k]
      Elseif Cast<String>(w)=";" Then 
        Self.p=Self.c[" "]
      Else      
        Self.p.Add(w)        
      End
    Else   
	    Self.p.Add(w)
    End
  End
  
  Method Eval(t:String)
    Local w:String="",n:Bool=True,p:Bool=True,c:String
    t=t+" "
    For Local i:Int=0 Until t.Length
      c=t.Slice(i,i+1)
      If c=" " Then 
        If w.Length>0 Then 
          If n Then 
            Self.Word(Double(w))
          Else
            Self.Word(w)
          End            
          w=""
          n=True
        End
      Else
        If (c<"0" Or c>"9") And Not(w.Length=0 And c="-" And t.Slice(i+1,i+2)<>" ") And Not(w.Length>0 And p And c=".") Then 
          n=False
          If c="." Then 
            p=False
          End  
        End 
        w=w+c
      End
    End
    Self.e=0
  End
  
  Method State:Int(e:Int=-1)
    If e<>-1 Then 
	  Self.e=e
    End
    Return e
  End
  
  Method _add()
    Self.SPush(Self.SPop()+Self.SPop()) 
  End
  
  Method _sub()
    Local s:Double=Self.SPop(),n:Double=Self.SPop()
    Self.SPush(n-s) 
  End 
  
  Method _mlt()
    Self.SPush(Self.SPop()*Self.SPop()) 
  End 
  
  Method _div()
    Local d:Double=Self.SPop(),n:Double=Self.SPop()
    Self.SPush(n/d) 
  End 
  
  Method _abs()
    Self.SPush(Abs(Self.SPop()))
  End
  
  Method _flr()
    Self.SPush(Floor(Self.SPop()))
  End
  
  Method _cos()
    Self.SPush(Cos(Self.SPop()))
  End
  
  Method _sin()
    Self.SPush(Sin(Self.SPop()))
  End
  
  Method _sqr()
    Self.SPush(Sqrt(Self.SPop()))
  End
  
  Method _dup()
    Self.SPush(Self.s.Last)
  End
  
  Method _llt()
  	If Self.SPop()>Self.SPop() Then
  	  Self.SPush(Double(1))
  	Else
  	  Self.SPush(Double(0))  	
  	End
  End
  
  Method _lgt()
  	If Self.SPop()<Self.SPop() Then
  	  Self.SPush(Double(1))
  	Else
  	  Self.SPush(Double(0))  	
  	End
  End
  
  Method _leq()
  	If Self.SPop()=Self.SPop() Then
  	  Self.SPush(Double(1))
  	Else
  	  Self.SPush(Double(0))  	
  	End
  End
  
  Method _lnt()
  	If Self.SPop()<>0 Then
  	  Self.SPush(Double(0))
  	Else
  	  Self.SPush(Double(1))  	
  	End  
  End
  
  '--function i:_cls() cls() end
  '--function i:_shw() print(self:spop()) end i['_.']=i._shw
  'function i:_cls() mc:cls() end
  'function i:_shw() mc:print(self:spop()) end i['_.']=i._shw
  Method _shw()
     Print(Self.SPop())
  End
End

Function Main()
  Local s:String=LoadString("asset::sample.ic")
  'Print(s)
  
  Local ic:ICore=New ICore 
  's=":b # 5 * . ; :a # . b 1 - # ?a ; 5 a ."
  ic.Eval(s)
  ic.Exec()
End