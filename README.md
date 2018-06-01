# Sunday
Kindle book preprocessor for KindleGen  

## What's this?｜これはなに？
KindleGenコマンドを使ってKindle本を作るためのプリプロセッサです。htmlタグを書いたり目次リンクなどを気にすることなく、本文の執筆に集中することができます。  

## Usage｜使い方
### 構成ファイルを用意する
書籍情報をまとめたファイルを用意します。ファイル名、拡張子ともに任意ですが、構成ファイルのファイル名が中間ファイルを含めた電子書籍ファイルのファイル名になります。  

例）  
- 構成ファイル：book.structure  
- 本文ファイル（中間ファイル）：book.html  
- 目次ファイル（中間ファイル）：book-toc.html  
- 出版物ヘッダファイル（中間ファイル）：book.opf
- スタイルシートファイル（中間ファイル）：book.css  
- 電子書籍ファイル（Kindle本）：book.mobi  

構成ファイルで以下の情報を指定します。
- 識別ID文字列（ISBN番号など一意な文字列）  
- 書籍タイトル  
- 表紙画像ファイル名  
- 原稿データファイル名（拡張子は指定しない）  
- 縦書き指定（指定しなければ横書き）  

それぞれの情報はキーワードと値をコロンで区切って１行ごとに指定します。  

原稿データファイル名以外は複数指定不可。（最後の指定以外は無視されます）原稿データは複数指定が可能ですが、指定順がそのまま電子書籍の表示順になります。  

たとえばこんな感じ。  

```
identifier:sample-data
title:This is a sample book
cover:/path/cover.jpg
body:introduction
body:chapter_1
body:chapter_2
body:chapter_3
body:postscript
vertical:on

```

### 原稿ファイルを用意する
原稿ファイルの拡張子は.txt固定です。ファイル名は英字で始める必要があります。（途中で数字やハイフン、アンダースコアを入れるのは可）  

章ごとにファイルを分けてください。  

簡単なマークダウンらしきものが使えます。  

- 章見出し：行頭に&#35;をひとつ。見出し語との間を半角スペースで区切る  
- 小見出し：行頭に&#35;&#35;または&#35;&#35;&#35;。見出し語との間を半角スペースで区切る  
- 段落：１行が１段落。改行するまでは同一段落内です
- ルビ：&#91;&#124;&#93;で囲む。&#91;例&#124;れい&#93;→<ruby>例<rp>（</rp><rt>れい</rt><rp>）</rp></ruby>

章見出しは章（１ファイル）にひとつだけ指定します。小見出しは複数指定可。&#35;の数が少ないほど上位見出しになります。  

ルビはiOS版Kindleアプリでは「例（れい）」のような表示になります。  

### 表紙画像ファイルを用意する
[Kindle Format 8](http://kindlegen.s3.amazonaws.com/AmazonKindlePublishingGuidelines_JP.pdf)によるとKindleの表紙画像は長辺2560px、短辺1600px以上で50MB以下のJPEGファイルです。  

なおこの制約は販売用のカバー画像のようなので、適当に野良Kindle本を作るだけならもっと小さい画像で大丈夫。  

### コンパイルする
sunday.shはシェルスクリプトです。unixらしきもののターミナル上で実行してください。上記構成ファイルを引数に与えて実行します。  

※いまのところWindows版のGit Bashではルビの変換がうまくいきません。

```
$ ./sunday.sh book.structure

```

エラーがなければ中間ファイルが生成されます。これら中間ファイルのうちの出版物ヘッダファイル（book.opf）をkindlegenに与えて実行します。  

```
$ kindlegen book.opf

```

エラーがなければ電子書籍ファイルbook.mobiが生成されます。  

[マニュアル](https://gumroad.com/l/kindle-sunday)をGumroadに置いておきます。  

## License
This script has released under the MIT license.  
[http://opensource.org/licenses/MIT](http://opensource.org/licenses/MIT)
