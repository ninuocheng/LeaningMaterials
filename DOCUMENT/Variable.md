${变量名-新的变量值} 或者 ${变量名=新的变量值}
变量没有被赋值：会使用“新的变量值“ 替代
变量有被赋值（包括空值）： 不会被替代

> echo ${abc-123}
> abc=hello
> echo ${abc-444}
> echo $abc
> abc=
> echo ${abc-222}

${变量名:-新的变量值} 或者 ${变量名:=新的变量值}
变量没有被赋值或者赋空值：会使用“新的变量值“ 替代
变量有被赋值： 不会被替代

> echo ${ABC:-123}
> ABC=HELLO
> echo ${ABC:-123}
> ABC=
> echo ${ABC:-123}

${变量名:+新的变量值}
变量没有被赋值：不会使用“新的变量值“ 替代
变量有被赋值（包括空值）： 会被替代

> echo ${abc=123}
> echo ${abc:=123}

> unset abc
> echo ${abc:+123}

> abc=hello
> echo ${abc:+123}
123
> abc=
> echo ${abc:+123}

${变量名+新的变量值}
变量没有被赋值或者赋空值：不会使用“新的变量值“ 替代
变量有被赋值： 会被替代
> unset abc
> echo ${abc+123}

> abc=hello
> echo ${abc+123}
123
> abc=
> echo ${abc+123}
123

${变量名?新的变量值}
变量没有被赋值:提示错误信息
变量被赋值（包括空值）：不会使用“新的变量值“ 替代

> unset abc
> echo ${abc?123}
-bash: abc: 123

> abc=hello
> echo ${abc?123}
hello
> abc=
> echo ${abc?123}

${变量名:?新的变量值}
变量没有被赋值或者赋空值时:提示错误信息
变量被赋值：不会使用“新的变量值“ 替代
说明：?主要是当变量没有赋值提示错误信息的，没有赋值功能

> unset abc
> echo ${abc:?123}
-bash: abc: 123
> abc=hello
> echo ${abc:?123}
hello
> abc=
> echo ${abc:?123}
-bash: abc: 123
