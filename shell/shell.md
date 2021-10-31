# conditions
## Folders or files
- -e: exist
- -d: is directory
- -f: is file
example:
- `[ -e shell.md ] && echo "file exist"`
- `[ -e not_exist.md ] || touch not_exist.md`
- `[ -d /home/ ] && echo "folder!"`
- `[ -f ~/test.txt ] && echo "file!"`

## Readable writable or executable
- r: readable
- w: writable
- x: executable

## Compare of integers (not float)
-eq: equal
-ne: not equal
-gt: greater than
-lt: less than
-ge: greater or equal
-le: less or equal

example
- `[ 1 -gt -1 ] && echo "greater than"`
- `[ -1 -lt 1.0 ] && echo "less than" # Error: bash: [: -1.0: integer expression expected`

## Compare of strings
=: equal
!=: not equal

example:
- `[ "kk" != "kkkk" ] && echo "yes"`

## Compare of float
we must use `bc` calculator to compare float.
- ```[ $(echo "1.2 > 0.5" | bc) -eq 1 ] && echo "yes"```


# `grep`, `cut`, `awk` and `sed`
## grep - handle lines
`-v`: reverse selection
`-i`: ignore case
`-w`: accurate match
`-n`: show line number of result
`-E`: match a regex


## cut - handle rows
`-d`: specify seperator, default is `\t`
`-f`: which line you want, like `1,2,3,5` or `1-4`(line 1 to line 4) or `2-`(line 2 to the end) 
`-c`: seperate by character

example
- `cut -d ":" -f 1,3 /etc/passwd`
- `cut -d ":" -f 1- /etc/passwd`

## awk - handle rows
### use
- ```awk 'condition1 {dosomething} condition2 {dosomething}'```
### tools
#### printf: output formatted string, no `\n` at the end
- $ns: string, n means how many characters
- $ni: integer, n means how many digits
- $.nf: float, n means how many digits after `.`
example:
- `printf "%s%s%s\n" 1 2 3 4 5 6`
- `df -h | grep /dev/nvme | awk '{printf "Used rate of %s is %s\n",$1,$5}'`: how much space is used on each NVME disk
#### print: print virable
#### `-F` for input separator
example: ```cat /etc/passwd | awk -F ":" '{print $1}'```
#### BEGIN and END
In begin, we can modify some built-in virables to make awk work differently.
`FS`: input file separator```awk 'BEGIN{FS=":";}{print $1}' /etc/passwd```

#### conditions exmaple
NR!=1 means if line number is not 1, this will filter out header of a table
```df -h | awk 'BEGIN{FS=" ";}NR!=1{printf "usage of %15s is %.2f%%\n",$1,$5}'```



## sed - edit text
`-n`: print output to screen
`p`: select line
They usually use together.
- example: `df -h | sed -n '2p'` - print second line to screen

`d`: delete line
- example: `df -h | sed '2d'` - delete 2ed line

Why don't need `-n` for `d`? 
- official doc: By default sed prints all processed input (except input that has been modified/deleted by commands such as d). Use -n to suppress output, and the p command to print specific lines. 
 
`a`: insert below a line
example: `df -h | sed '2a 123456'`

`i`: insert above a line
example: `df -h | sed '2i 123456'`

`c`: replace a line with specified string'
example: `df -h | sed '1c 123456'`

`s/stra/strb/g`: replace stra with strb

`-i`: edit the source file

`/strA/g`: print all lines containing strA


# if clause
## single condition
example:
```
if [ $1 -eq 1 ];
then
echo "input is 1"
else
echo "input is not 1"
fi 
```
## multiple conditions
example:
```
if [ $1 -eq 1 ]
then
echo "input is 1"
elif [ $1 -eq 2 ]
then
echo "input is 2"
else
echo "invalid input"
fi
```

# for clause
example - print all files ends with .py
```
for f in `ls`;
do
if [ "$f" == *.py ]
then 
echo "$f"
fi
done
```

example - c style for clause
```
for (( i=1; i<11; i++ ))
do
echo $i
sleep 1
done
```

# case clause
example
```
case $1 in
"print1")
echo "1"
;;
"print2")
echo "2"
;;
*)
echo "wrong input"
esac
```

# while clause
```
i=1
while [ $i -ne 10 ]
do
i=$(($i+1))
sleep 1
done
```

# Exercise
## Check memory usage
```
#!/bin/bash
# check memory usage and print warning
mem_total=$(free -m | sed -n '2p' | awk '{print $2}')
mem_used=$(free -m | sed -n '2p' | awk '{print $3}')
mem_free=$(free -m | sed -n '2p' | awk '{print $4}')

used_rate=$(echo "scale=2; $mem_used/$mem_total*100" | bc | awk '{printf "%.0f",$1}')
free_rate=$(echo "scale=2; $mem_free/$mem_total*100" | bc | awk '{printf "%.0f",$1}')

curr_time=$(date +"%Y-%m-%d %H:%M:%S %A")

echo ""

echo -e "Memory usage rate: $used_rate%"
echo -e "Memory free  rate: $free_rate%"

if [ $used_rate -gt 1 ]
then
echo -e "\033[31mWarning: usage of memory use is $used_rate%\033[0m"
fi
```























