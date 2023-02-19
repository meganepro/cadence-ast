# install

- python: ^3.9.2
- java: 11.0.10

## java

- https://qiita.com/seijikohara/items/56cc4ac83ef9d686fab2

```sh
jenv local 11.0.10
jenv rehash
java -version
```

## python and antlr

- https://github.com/antlr/antlr4/blob/master/doc/getting-started.md

```sh
pipenv install --python 3.9
pipenv install antlr4-tools
pipenv shell

antrl4
```

# how

## show

- use vscode extensions
  - mike-lischke.vscode-antlr4

- use command

```sh
# show
antlr4-parse CadenceParser.g4 CadenceLexer.g4 top_level -gui input.cdc
```

## export

- ~~python~~

```sh
antlr4 CadenceLexer.g4 CadenceParser.g4  \
  -Dlanguage=JavaScript \
  -o js
```

- execute directory from java
  - [dl](https://repo1.maven.org/maven2/org/antlr/antlr4/4.8-1/)

```sh
java -jar antlr4-4.8-1-complete.jar CadenceLexer.g4 CadenceParser.g4  \
  -Dlanguage=JavaScript \
  -o js
```


 