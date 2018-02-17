pico-8 cartridge // http://www.pico-8.com
version 16
__lua__
-- i_c●re editor 2.0
-- jean-marc "jihem" quere
local mg,vg,mc,mm,vm
--
c={}
function c:new(o)
 o={}
 setmetatable(o,self)
 self.__index=self
 return o
end

function c:cls()
 local i
 self.l={}
 for i=1,17 do
  add(self.l,'')
 end
end

function c:print(t)
 local l,i={}
 for i=1,16 do
  add(l,self.l[i+1])
 end
 add(l,t)
 self.l=l
end

function c:draw()
 local i
 color(6)
 for i=0,16 do
  print(self.l[i+1],46,10+i*7)
 end
end
-- i_c●re
i={}
function i:new(o) o=o or {} o.e=o.e or 3 o.c=o.c or {}	o.c[' ']=o.c[' '] or {}	o.p=o.c[' '] o.n=o.n or 0 setmetatable(o,self) self.__index=self return o end
function i:ret() local s,i,r={} if #self.r>0 then r=self.r[#self.r] for i=1,#self.r-1 do add(s,self.r[i]) end self.r=s end self.p,self.i=r[1],r[2] end
function i:spop() local r,s,i=0,{} if #self.s>0 then r=self.s[#self.s] for i=1,#self.s-1 do add(s,self.s[i]) end self.s=s end return r end
function i:spush(v) add(self.s,v) end
function i:vpop(v)	self.v[v]=self:spop() end
function i:vpush(v) self:spush(self.v[v]) end
function i:call(i) local c=true self.n+=1 if type(i)=='number' then add(self.s,i) else if self['_'..i]!=nil then	self['_'..i](self) else if c and sub(i,1,1)=='>' then self:vpop(sub(i,2,#i)) c=false end if c and sub(i,1,1)=='<' then self:vpush(sub(i,2,#i)) c=false end if c and sub(i,1,1)=='?' then if self:spop()!=0 then i=sub(i,2,#i) else c=false end end if c and self.c[i] then add(self.r,{self.p,self.i+1}) self.p=self.c[i] self.i=0 end end end end
function i:exec() self.n=0 self.s={} self.v={} self.r={{self.c[' '],1}} while #self.r>0 do self:ret() while self.i<=#self.p do self:call(self.p[self.i]) self.i+=1 end	end self.e=3 end
function i:step() if self.e==0 then self.n=0 self.s={} self.v={} self.r={{self.c[' '],1}} self.e=1 end if self.e==1 then if #self.r>0 then self:ret() self.e=2	else self.e=3	end end	if self.e==2 then	if self.i<=#self.p then self:call(self.p[self.i]) self.i+=1 else self.e=1	end	end end
function i:word(w) local c,k if sub(w,1,1)==':' then k=sub(w,2,#w) self.c[k]={} self.p=self.c[k] elseif w==';' then self.p=self.c[' '] else	add(self.p,w) end end
function i:eval(t) local w,n,p,c,i='',true,true t=t..' ' for i=1,#t do c=sub(t,i,i) if c==' ' then if #w>0 then if n then self:word(0+w) else self:word(w) end w,n='',true end else if (c<'0' or c>'9') and not(#w==0 and c=='-' and sub(t,i+1,i+1)!=' ') and not(#w>0 and p and c=='.') then n=false if c=='.' then p=false end end w=w..c end end self.e=0 end
function i:state(e) if e!=nil then self.e=e end return self.e end
-- 
function i:_add() self:spush(self:spop()+self:spop()) end i['_+']=i._add
function i:_sub() self:spush(-self:spop()+self:spop()) end i['_-']=i._sub
function i:_mlt() self:spush(self:spop()*self:spop()) end i['_*']=i._mlt
function i:_div() local d,n=self:spop(),self:spop() self:spush(n/d) end i['_/']=i._div
function i:_abs() self:spush(abs(self:spop())) end 
function i:_flr() self:spush(flr(self:spop())) end 
function i:_cos() self:spush(cos(self:spop()/360)) end 
function i:_sin() self:spush(sin(self:spop()/360)) end 
function i:_sqr() self:spush(sqrt(self:spop())) end 
function i:_dup() add(self.s,self.s[#self.s]) end i['_#']=i._dup
function i:_llt() if self:spop()>self:spop() then self:spush(1) else self:spush(0) end end i['_<']=i._llt
function i:_lgt() if self:spop()<self:spop() then self:spush(1) else self:spush(0) end end i['_>']=i._lgt
function i:_leq() if self:spop()==self:spop() then self:spush(1) else self:spush(0) end end i['_=']=i._leq
function i:_lnt() if self:spop()!=0 then self:spush(0) else self:spush(1) end end i['_!']=i._lnt
--function i:_cls() cls() end
--function i:_shw() print(self:spop()) end i['_.']=i._shw
function i:_cls() mc:cls() end
function i:_shw() mc:print(self:spop()) end i['_.']=i._shw
-- turtle object
t={}
function t:new(o)	o=o or {}	o.a=o.a or 0.25	o.p=o.p or true	o.c=o.c or 5	o.x=o.x or 63	o.y=o.y or 63	o.l={{o.x,o.y,o.c,o.p}}	setmetatable(o,self)	self.__index=self return o end
function t:mv(x,y) add(self.l,{x,y,self.c,self.p}) end
function t:fd(n) self.x=self.x+cos(self.a)*n self.y=self.y+sin(self.a)*n self:mv(self.x,self.y) end
function t:bd(n)	self:fd(-n) end
function t:tr(a)	self.a=self.a-a/360 end
function t:tl(a)	self:tr(-a) end
function t:cl(c) self.c=c end
function t:pu() self.p=false end
function t:pd() self.p=true end
function t:hd(a) self.a=a/360 end
function t:draw() local x,y for k,v in pairs(self.l) do  if k==1 then x,y=v[1],v[2] else if v[4] then line(x,y,v[1],v[2],v[3]) end x,y=v[1],v[2] end end circfill(x,y,2,8) line(x,y,x+cos(self.a)*2,y+sin(self.a)*2,10) end
-- turtle binding
function i:_fd() self.t:fd(self:spop()) end
function i:_bd() self.t:bd(self:spop()) end
function i:_tr() self.t:tr(self:spop()) end
function i:_tl() self.t:tl(self:spop()) end
function i:_cl() self.t:cl(self:spop()) end
function i:_pu() self.t:pu() end
function i:_pd() self.t:pd() end
function i:_hd() self.t:hd(self:spop()) end
function i:_mv() self.t.y,self.t.x=self:spop()+10,self:spop()+46 self.t:mv(self.t.x,self.t.y) end
-- editor
function iif(c,t,f) if c then return t else return f end end 
m={}
function m:new(o)
	o=o or {}
	o.i=o.i or {
		{'n','*',360},
		{'n','*',90},
		{'n','*',0},		
		{'v','>*','a'},
		{'v','<*','a'},
		{'o','+',''},
		{'o','-',''},
		{'o','*',''},
		{'o','/',''},
		{'o','#',''},
		{'o','.',''},		
		{'o','<',''},
		{'o','>',''},
		{'o','=',''},
		{'o','!',''},	
		{'m','abs',''},
		{'m','flr',''},
		{'m','cos',''},
		{'m','sin',''},
		{'m','sqr',''},
		{'l',':*','a'},
		{'l',';',''},
		{'l','*','a'},
		{'l','?*','a'},
		{'t','fd',''},
  {'t','bd',''},
  {'t','tr',''},
  {'t','tl',''},
  {'t','cl',''},
  {'t','pu',''},
  {'t','pd',''},
  {'t','hd',''},
  {'t','mv',''}}
 o.ip=o.ip or 0
 o.l=o.l or {
  {'e','<cp',''},
  {'e','>cp',''},
  {'e','clr',''}}
 o.lp=o.lp or 0
 o.c={n=3,v=3,o=6,m=5,l=9,t=13,e=8}
 o.m=1
 o.cmd=''
 o.mem=''
 o.sp=''
	setmetatable(o,self)
	self.__index=self
	return o
end

function m:rep(s,r)
 local n,i,c=''
 for i=1,#s do
  c=sub(s,i,i)
  if c=='*' then
   n=n..r
  else
   n=n..c
  end
 end
 return n
end

function m:f4d(n)
 return sub('000',#(''..n))..n
end

function m:f5d(n)
 return sub('0000',#(''..n))..n
end

function m:draw()
 local i,p,t
 
 rectfill(44,8,127,127,0)
 for i=2,14 do
 pal(i,1)
 end
 if #vg.t.l>1 then vg.t:draw() end	 
 pal()
 self.vm.t:draw() 

 if self.vm:state()==3 and self.sp=='' then
  self.sp=mg:spck(1)
  if self.sp==mg.sp then
   if mg.o[mg.op][2]==0 then
    mg.o[mg.op][2]=1
    mg.m=0 
   end
   mg.o[mg.op][3]=self.cmd 
  end
 end

 rectfill(0,0,127,6,0)
 print('i_c●re',0,0,6)
 print('●',12,0,8)
 pset(16,1,10)
 print('/    :',85,0,1)
 print(self:f4d(iif(self.lp<3,0,self.lp-2))..' '..self:f4d(#self.l-3),69,0,13)
 print(iif(self.vm.n>30000 or stat(0)>1000,'*****',self:f5d(self.vm.n)),109,0,9)
 line(0,7,127,7,6)
 line(43,8,43,127,13)
 --
 rectfill(0,8,42,127,1)
 line(21,8,21,127,13)
 --
 t=17*flr(self.ip/17)+1
 p=self.ip%17
 for i=0,16 do
  if self.i[t+i]!=nil then
   color(self.c[self.i[t+i][1]])
   if self.i[t+i][1]!='o' then
	   print(self:rep(self.i[t+i][2],self.i[t+i][3]),9,9+i*7)
	  else
	   print(self.i[t+i][2],9,9+i*7)
	  end
	  if i==p then
	   color(iif(self.m==1,7,5))
	   print('➡️',1,9+i*7) 
	  end
  end
 end
 --
 t=17*flr(self.lp/17)+1
 p=self.lp%17
 for i=0,16 do
  if self.l[t+i]!=nil then
   color(self.c[self.l[t+i][1]])
   if self.l[t+i][1]!='o' then
	   print(self:rep(self.l[t+i][2],self.l[t+i][3]),31,9+i*7)
	  else
	   print(self.l[t+i][2],31,9+i*7)
	  end
	  if i==p then
	   if self.m==3 then
	    color(8)
	    print('█',23,9+i*7)
	   else
	    color(iif(self.m==2,7,5))
	    print('➡️',23,9+i*7)
	   end
	  end
  end
 end

 i=4
 while i>0 and self.vm:state()!=3 do
   if self.vm.n>30000 or stat(0)>1000 then self.vm:state(3) end
   self.vm:step()
   i-=1
 end
 
end

function m:add()
 local l,i={}
 if self.lp<2 then self.lp=2 end
 for i=1,self.lp+1 do
  add(l,self.l[i])
 end
 add(l,{
  self.i[self.ip+1][1],
  self.i[self.ip+1][2],
  self.i[self.ip+1][3]
  })
 for i=self.lp+2,#self.l do
  add(l,self.l[i])
 end 
 self.l=l
 self.lp+=1
end

function m:del()
 local l,i={}
 if self.l[self.lp+1][1]!='e' then
	 for i=1,self.lp do
	  add(l,self.l[i])
	 end
	 for i=self.lp+2,#self.l do
	  add(l,self.l[i])
	 end 
	 self.l=l
	 self.lp-=1
 end
end

function m:clip(t)
 local w,n,p,c,i='',true,true

 self.l={
  {'e','<cp',''},
  {'e','>cp',''},
  {'e','clr',''}}
 self.lp=0

 if sub(t,#t,#t)!=' ' then t=t..' ' end

 for i=1,#t do
  c=sub(t,i,i)
  if c==' ' then
   if #w>0 then
    if n then
     add(self.l,{'n','*',0+w})
   else
     c=sub(w,1,1)
     if #w==2 and (c=='<' or c=='>') then
      add(self.l,{'v',c..'*',sub(w,2,2)})       
     elseif c=='+' or c=='-' or c=='*' or c=='/' or c=='#' or c=='.' or c=='>' or c=='<' or c=='=' or c=='!' then
      add(self.l,{'o',w,''})
     elseif w=='abs' or w=='flr' or w=='cos' or w=='sin' or w=='sqr' then
      add(self.l,{'m',w,''})
     elseif #w==2 and (c==':' or c=='?') then
      add(self.l,{'l',c..'*',sub(w,2,2)})
     elseif w==';' then
      add(self.l,{'l',w,''})
     elseif w=='a' or w=='b' or w=='c' then 
      add(self.l,{'l','*',w})
     elseif w=='fd' or w=='bd' or w=='tr' or w=='tl' or w=='cl' or w=='pu' or w=='pd' or w=='hd' or w=='mv' then
      add(self.l,{'t',w,''})
     end
   end
   w,n='',true
  end
  else
   if (c<'0' or c>'9') and not(#w==0 and c=='-' and sub(t,i+1,i+1)!=' ') and not(#w>0 and p and c=='.') then
    n=false
    if c=='.' then
     p=false
    end
   end
   w=w..c
  end
 end

end

function m:edt()
 local l,i={}
 if self.l[self.lp+1][1]=='e' then
  if self.l[self.lp+1][2]=='<cp' then
   self:clip(stat(4))  
  elseif self.l[self.lp+1][2]=='>cp' then
  	printh(self.cmd,'@clip')
  elseif self.l[self.lp+1][2]=='clr' then
		 for i=1,#self.l do
	   if self.l[i][1]=='e' then
		   add(l,self.l[i])
		  end
		 end
		 self.l=l
		 self.lp=0
  end
 elseif self.l[self.lp+1][3]!='' then
  self.m=3
 end
end

function m:dec()
 local v=self.l[self.lp+1][3]
 if type(v)=='number' then
  if v>-99 then
   self.l[self.lp+1][3]-=1
  end
 else
  if v=='b' then v='a' end
  if v=='c' then v='b' end
  self.l[self.lp+1][3]=v 
 end
end

function m:inc()
 local v=self.l[self.lp+1][3]
 if type(v)=='number' then
  if v<999 then
   self.l[self.lp+1][3]+=1
  end
 else
  if v=='b' then v='c' end
  if v=='a' then v='b' end
  self.l[self.lp+1][3]=v
 end
end

function m:update()
 if self.m==1 then
  if btnp(1) then self.m=2 end
  if btnp(2) and self.ip>0 then self.ip-=1 end
  if btnp(3) and self.ip<#self.i-1 then self.ip+=1 end
  if btnp(4) then
   mg.m=0
   mg.o[mg.op][3]=self.cmd
  end
  if btnp(5) then self:add() end
 elseif self.m==2 then
  if btnp(0) then self.m=1 end
  if btnp(2) and self.lp>0 then self.lp-=1 end
  if btnp(3) and self.lp<#self.l-1 then self.lp+=1 end
  if btnp(4) then self:del() end
  if btnp(5) then self:edt() end
 elseif self.m==3 then
  if btnp(0) then self:dec() end
  if btnp(1) then self:inc() end
  if btnp(4) or btnp(5) then self.m=2 end 
 end
 
 self.cmd=''
 for i=1,#self.l do
	 if self.l[i][1]!='e' then
		 if self.l[i][1]!='o' then
		  self.cmd=self.cmd..self:rep(self.l[i][2],self.l[i][3])..' '
		 else
		  self.cmd=self.cmd..self.l[i][2]..' '
		 end 
  end
 end

 if self.cmd!=self.mem then
  mc:cls()
  self.vm=i:new({t=t:new({x=90})})
  self.vm:eval(self.cmd)
  self.mem=self.cmd
  self.sp=''
 end
 
end
--
g={m=0,op=1,sp='',o={
	{'sandbox',1,'',''},
	{'1:20 fd',0,'','20 fd'},
	{'2:90 tr',0,'',':a 1 - 20 fd 90 tr # ?a ; 4 a'},
	{'3:a...;',0,'',':a 1 - 20 fd 90 tr # ?a ; :b 4 a 90 tr ; b b b b'},
 {'4:flwr1',0,'',':a 1 - 20 fd 90 tr # ?a ; :b 4 a 36 tr ; :c 1 - # b >a ?c ; 10 c '},
 {'5:polyg',0,'',':a 15 fd <b tr ; :b 1 - # a ?b ; :c 90 hd >a 360 <a / >b <a b <a 1 - # ?c ; 8 c'},
 {'6:spirl',0,'',':a # fd 90 tr 1 + # 45 < ?a ; 1 a'},
 {'7:decse',0,'',':a # # fd bd 90 tr 1 fd 90 tl 1 - # ?a ; pu 10 24 mv pd 90 tr 60 a'},
 {'8:leaf',0,'',':a 3 fd 10 tr 1 - # ?a ; 12 a 60 tr 12 a'},
 {'9:flwr2',0,'',':a 3 fd 10 tr 1 - # ?a ; :b 12 a >a 60 tr 12 a >a 1 - # ?b ; 6 b'},
 {'a:spark',0,'',':a 1 - # ?a 5 fd <a tr ; :b pu 44 53 mv 90 hd pd >a 10 a <a 4 + # 22 < ?b ; -20 b'},
 {'b:koch3',0,'',':a >a # >b 1 = # ! ?c ?b ; :b <a fd ; :c <b 1 - >b <a 3 / >a <b <a <b <a a >a >b 60 tl <b <a <b <a a >a >b 120 tr <b <a <b <a a >a >b 60 tl <b <a <b <a a >a >b ; pu 44 100 mv pd 3 80 a'},
 {'c:koch4',0,'',':a >a # >b 1 = # ! ?c ?b ; :b <a fd ; :c <b 1 - >b <a 3 / >a <b <a <b <a a >a >b 60 tl <b <a <b <a a >a >b 120 tr <b <a <b <a a >a >b 60 tl <b <a <b <a a >a >b ; pu 44 100 mv pd 4 80 a'},
 {'d:tree',0,'',':a # 2 - # fd 45 tl # ?a 90 tr # ?a 45 tl bd ; 14 a'},
 {'e:head',0,'',':a >a # <a / flr # b >b <a * - <a 2 / flr # ?a ; :b 5 * cl 4 c ; :c 1 - # 3 fd 3 bd 90 tr pu 1 fd pd 90 tl ?c ; pu 24 20 mv pd 62 128 a pu 24 24 mv pd 127 128 a pu 24 28 mv pd 73 128 a pu 24 32 mv pd 127 128 a pu 24 36 mv pd 62 128 a pu 24 40 mv pd 42 128 a'},
	}}
function g:new(o)
 o=o or {}
 setmetatable(o,self)
 self.__index=self
 return o
end

function g:spck(v)
 local l,s,n,r,x,y='',false,0
 for y=8,127 do
	 for x=44,127 do
	  if s then
	   r=pget(x,y)>v
	  else
	   r=pget(x,y)<=v
	  end
	  if r then
	   n+=1
	  else
	   l=l..':'..n
	   n=1
	   s=not s
	  end
	 end
 end
	l=l..':'..n
 return sub(l,2,#l)
end

function g:draw()
 if self.m==0 then
	 local i,oi
	 cls()
	 if #vg.t.l>1 then vg.t:draw() end	 
	 rectfill(0,0,127,6,0)
	 print('i_c●re',0,0,6)
	 print('●',12,0,8)
	 pset(16,1,10)
	 line(0,7,127,7,6)
	 line(43,8,43,127,13)
	 rectfill(0,8,42,127,1)
	
	 oi=flr((self.op-1)/15)*15+1
	 for i=0,14 do
	  if oi+i==self.op then
	   print('➡️',0,10+8*i,7)
	  end
	  if self.o[oi+i] then
	  print(self.o[oi+i][1],8,10+8*i,iif(self.o[oi+i][2]!=0,iif(oi+i==1,3,11),iif(self.o[oi+i][3]=='',6,9)))
	  end
	 end
 elseif self.m==1 then
  mm:draw()
  mc:draw()
 end
end

function g:update()
 if self.m==0 then
	 local op=self.op
	 if btnp(2) then self.op-=1 end
	 if btnp(3) then self.op+=1 end
	 if self.op<1 then self.op=1 end
	 if self.op>#self.o then self.op=#self.o end
	 if op!=self.op then
	   vg=i:new({t=t:new({x=90})})
				vg:eval(self.o[self.op][4])
	   vg:exec()
	 end	 
	 if btnp(5) then
	  self.m=1
	  self.sp=self:spck(0)
			mc=c:new()
			mc:cls()
			vm=i:new({t=t:new({x=90})})
			mm=m:new({vm=vm})
			mm:clip(self.o[op][3])  
	 end
 elseif self.m==1 then
  mm:update()
 end
end
--
function _init()
 vg=i:new({t=t:new({x=90})})
 mg=g:new()
end

function _draw()
 mg:draw()
end

function _update()
 mg:update()
end
__label__
66600000066000888000666066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0600000060000888a800606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000600008888800660066000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
06000000600008888800606060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66606660066000888000606066600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
66666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666666
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1777771113313331331133113331133131311111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7711777131113131313131313131313131311111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7711177133313331313131313311313113111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7711777111313131313131313131313131311111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1777771133113131313133313331331131311111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166111111666166611111666166111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116111611116161611111611161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116111111666161611111661161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116111611611161611111611161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666166611111611166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666166611111666166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611616161611111161161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666161611111161166111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611116161611111161161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111116166611111161161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611616111111111111116111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116611111666111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611616111111111111116111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111616116111611161161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611111666161116161666166111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611611161116161616116111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111661161116161661116111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611611161116661616116111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611111611166616661616166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666116616111616116611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611616161616111616161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666161616111666161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611611161616111116161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111611166116661666166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111111166166616661666161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611611161611611616161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666166611611661161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611116161111611616161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111661161116661616166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111661166611661166166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611616161116111611161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611111616166116111666166111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611616161116111116161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611111666166611661661166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111611166616661666111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611611161116161611111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111611166116661661111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611611161116161611111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666166616161611111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666161116161666166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611611161116161616111611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111661161116161661166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611611611161116661616161111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111611111611166616661616166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111166166616661666161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611611161616161616161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111666166616661661166111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611116161116161616161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611111661161116161616161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111616116611661616166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611616161616111616111611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166111111661161616111666116611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611616161616111616111611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111616166111661616166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116611111616116611661616161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611616161616111616161611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111111661161616111666166611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611616161616111616111611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111116611111616166111661616111611111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166111111666166616661666111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611161161616111611111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611111161166116611661111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161611611161161616111611111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111161161616661666111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111616166616661661111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611616161116161616111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166111111666166116661616111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111161111611616161116161616111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111166611111616166616161666111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000
1111111111111111111111111111111111111111111d000000000000000000000000000000000000000000000000000000000000000000000000000000000000

