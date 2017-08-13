# aea-way

ScadaJS does not enforce any editors or platform, but we prefer Linux and some other nice tools. In order to follow this way, you need to

### Install

* Install a 64bit Linux distro (preferably Debian)
* install https://atom.io

### Follow

* https://github.com/gkz/LiveScript-style-guide


# Why these technologies, languages? 

## Why Livescript? 

A programmer should read codes more than he/she writes. So, we should make it easier to read a code. 

For example, [following piece of](https://github.com/aktos-io/scada.js/blob/master/src/lib/aea/merge.ls#L70-L255) "documentation" is actually a running test code: 

```ls
'simple merge': ->
    a=
      a: 1
      b: 2

    b=
      c: 5

    result = a `merge` b

    expected =
        a: 1
        b: 2
        c: 5

    {result, expected}

'merge lists': ->
    a=
      a: 1
      b: 2
      c: [1, 2]
    b=
      b: 8
      c: [1, 4]

    result = a `merge` b

    expected =
        a: 1
        b: 8
        c: [1, 2, 4]

    {result, expected}

'merge lists of objects': ->
    a=
      a: 1
      b: 2
      c: [{a: 1, b: 2}, {a: 3, b: 4}]
    b=
      b: 8
      c: [{a: 1, b: 2}, {a: 5, b: 6}]

    result = a `merge` b

    expected =
        a: 1
        b: 8
        c: [{a: 1, b: 2}, {a: 3, b: 4}, {a: 5, b: 6}]

    {result, expected}
    
...
```

