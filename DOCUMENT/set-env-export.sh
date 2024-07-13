set env export的关系和区别
set 用来显示本地变量，环境变量
env 用来显示环境变量
export 用来显示和设置环境变量

set 显示当前shell的变量（本地变量），包括当前用户的变量（ 环境变量）

env 显示当前用户的变量  (环境变量）

export 显示当前导出成用户变量的shell变量 (环境变量）
每个shell有自己特有的变量，这个和用户变量是不同的，

当前用户变量和你用什么shell无关，不管你用什么shell都在

,比如HOME,SHELL等这些变量。


      但shell自己的变量不同，比如BASH_ARGC， BASH等，

这些变量只有set才会显示，是bash特有的。


      export不加参数的时候，显示哪些变量被导出成了用户变量，

因为一个shell自己的变量可以通过export "导出" 变成一个用户变量。

env是查看所有的环境变量，即通过export导出的变量

而set是查看所有的变量，包含env和用户自定义的变量，因此env是set的子集

在Shell中有三种变量：内部变量,环境变量,用户变量。
内部变量：系统提供，不用定义，不能修改
环境变量：系统提供，不用定义，可以修改,可以利用export将用户变量转为环境变量.
用户变量：用户定义，可以修改

(1)内部变量(系统变量,环境变量,参数变量,预定义变量)
 内部变量是Linux所提供的一种特殊类型的变量，这类变量在程序中用来作出判断。在shell程序内这类变量的值是不能修改的。
   表示方法     描述
   $n     $1 表示第一个参数，$2 表示第二个参数 ...
   $#     命令行参数的个数
   $0     当前程序的名称
   $?     前一个命令或函数的返回码
   $*     以"参数1 参数2 ... " 形式保存所有参数
   $@     以"参数1" "参数2" ... 形式保存所有参数
   $$     本程序的(进程ID号)PID
(2) 环境变量
  Linux环境（也称为shell环境）由许多变量及这些变量的值组成，由这些变量和变量的值决定环境外观。这些变量就是环境变量。
 包括两部分,一是,由系统设置的,主要包括： HOME,LOGNAME,MAIL,PATH,PS1,PWD,SHELL,TERM
 二是,用户在命令行中设置的,使用export命令,但是用户注销时值将丢失
(3)用户变量(私有变量,本地变量)
  在命令行中自己设定的.

env, export,set和declare命令的区别
  
env显示用户的环境变量；（包括了 export 显示出来的 和一些没有被导出为环境变量的系统变量）
set 显示当前shell定义的变量，包括环境变量，按变量名称排序；( 也就是整个shell中的所有变量 )
export 显示当前导出为环境变量的shell变量，并显示变量的属性(是否只读)，按变量名称排序；（export 显示出来的一部分是系统环境变量被导出来作为环境变量，一部分是用户 执行 export 或者 declare +x 自定义的变量手动导出为环境变量）
declare 同set 一样 ( 也就是整个shell中的所有变量 )

export 定义的变量
export使变量在"子Shell"也起作用
只在本控制台本次会话起效, 另开一个控制台无效
关闭控制台(关闭本次会话,exit)后失效,
子shell中export的变量,不会在父Shell起作用,制作子子Shell,子子孙孙Shell中起作用
declare -x等效export
设值时: export name=value效果等同declare -x name=value
查看时: declare -x和export 列出的内容相同
export的作用是将局部变量导出为环境变量,或直接定义环境变量, 环境变量与局部变量的区别就是:

环境变量可以在子子孙孙Shell中继续发挥作用,
局部变量只在本Shell中起作用

shell局部变量
局部变量在脚本或命令中定义，仅在当前shell实例中有效，其他shell启动的程序不能访问局部变量。
通过赋值语句定义好的变量，可以通过如下方法定义shell变量

A1="1234"
delcare A2="2345"
2. 用户的环境变量
所有的程序，包括shell启动的程序，都能访问环境变量，有些程序需要环境变量来保证其正常运行。必要的时候shell脚本也可以定义环境变量。
通过export语法导出的shell私有变量，可以通过如下方法导出用户环境变量

A1="1234"
export A1  #先定义再导出
export A3="34"
显示shell变量
env 这是一个工具，或者说一个Linux命令，显示用户的环境变量。
set 显示用户的局部变量和用户环境变量。
export 显示导出成用户变量的shell局部变量，并显示变量的属性；就是显示由局部变量导出成环境变量的那些变量 （比如可以 export WWC导出一个环境变量，也可通过 declare -X LCY导出一个环境变量）
declare 跟set一样，显示用户的shell变量 （局部变量和环境变量）

declare 命令
declare命令用于声明 shell 变量。
declare WWC="wangwenchao"
也可以省略declare
WWC="wangwenchao"

source 命令
source命令用法：
source FileName
作用:在当前bash环境下读取并执行FileName中的命令。
注：该命令通常用命令“.”来替代。
如：source .bash_rc 与 . .bash_rc 是等效的。

source命令与shell scripts的区别是，source在当前bash环境下执行命令，而scripts是启动一个子shell来执行命令。这样如果把设置环境变量（或alias等等）的命令写进scripts中，就只会影响子shell,无法改变当前的BASH,所以通过文件（命令列）设置环境变量时，要用source 命令。

source跟./xxx.sh或bash xxx.sh最大的不同就是前者在文件中设置的变量对当前shell是可见的，而后者设置的变量对当前shell是不可见的。要知道./xxx.sh和bash xxx.sh都是在当前shell的子shell中执行的，子shell中的变量不会影响父shell，而source是把文件中的命令都读出来一个个执行，所有的变量其实就是在父shell中设置的。

总结:

　　1.declare var=value   可以声明一个shell变量(与之等价的是 var=value,typeset var=value)，也可以直接用declare -x var=value 声明一个变量并直接输出到环境变量，也可以加上-r参数表示只读变量。

　　2.unset var 可以删除变量，包括shell变量和环境变量(当前用户变量)，不能够删除具有只读属性的shell变量和环境变量。

　　3.set -a var  可以将var变量输出到环境变量

　　4.env可以查看所有的环境变量，可以加管道命令与grep命令过滤变量

 　   5.export var=value用于定义一个环境变量，修改环境变量也是这个，等价于 declare -x var=name

　　　export -n var 用于从环境变量删除此变量，但是shell变量中此变量仍然存在。
