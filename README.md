# README

このプロジェクトでは[`Cadence`](https://developers.flow.com/cadence/language/index)言語のParserを作るための文法を開発します。  
Parserの生成には[`ANTLR`](https://www.antlr.org/)を利用します。

--- English is as follows

This project will develop a grammar for creating Parsers for the [`Cadence`](https://developers.flow.com/cadence/language/index) language.  
Parser generation will use [`ANTLR`](https://www.antlr.org/).

_Translated with www.DeepL.com/Translator (free version)_

# Related Project

- AST
  - [cadence-ast](https://github.com/meganepro/cadence-ast)
- Prettier Plugin (this repository)
  - [prettier-plugin-cadence](https://github.com/meganepro/prettier-plugin-cadence)
- VSCode Prettier Plugin
  - [prettier-cadence-formatter](https://github.com/meganepro/prettier-cadence-formatter)

# For Develop

<!-- - python: ^3.9.2 -->
- java: 11.0.10
- antlr: 4.8.1

## Install Java

<!-- - https://qiita.com/seijikohara/items/56cc4ac83ef9d686fab2 -->

- use jenv
```sh
jenv local 11.0.10
jenv rehash
java -version
```

## Install antlr

- Download from [here](https://repo1.maven.org/maven2/org/antlr/antlr4/4.8-1/)

<!-- ## python and antlr

- https://github.com/antlr/antlr4/blob/master/doc/getting-started.md

```sh
pipenv install --python 3.9
pipenv install antlr4-tools
pipenv shell

antrl4
``` -->

## Run

### Display on VSCode

- VSCode extensions
  - [mike-lischke.vscode-antlr4](https://marketplace.visualstudio.com/items?itemName=mike-lischke.vscode-antlr4)

<!-- ### Display on Command Line

```sh
antlr4-parse CadenceParser.g4 CadenceLexer.g4 top_level -gui input.cdc
``` -->

## Export Parser/Printer/Listener

### Command Line
```sh
java -jar antlr4-4.8-1-complete.jar CadenceLexer.g4 CadenceParser.g4  \
  -Dlanguage=JavaScript \
  -o parser
```

or 

### VSCode Extension

- In the .vscode/settings.json
```json
{
  "antlr4.generation": {
    "mode": "external",
    "language": "JavaScript",
    "listeners": true,
    "visitors": false,
    "alternativeJar": "antlr4-4.8-1-complete.jar",
    "outputDir": "parser"
  }
}
```

<!-- ```sh
antlr4 CadenceLexer.g4 CadenceParser.g4  \
  -Dlanguage=JavaScript \
  -o parser
```
-->
