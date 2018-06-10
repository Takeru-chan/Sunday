#! /bin/sh
if test "$1" == ""; then
  echo "TOC file is not specified."
  exit 1
elif test ! -e $1; then
  echo "$1 is not exist."
  exit 1
fi
PATHFILE=${1%.*} #パス付きファイル名（拡張子削除）
OPF="$PATHFILE.opf"
TOC="${PATHFILE}-toc.html"
CONTENT="$PATHFILE.html"
STYLESHEET="$PATHFILE.css"
while read LINE
do
  KEY=${LINE%:*}
  VALUE=${LINE##*:}
  case $KEY in
    'identifier')
    ID=$VALUE;;
    'title')
    TITLE=$VALUE;;
    'cover')
    COVER=$VALUE;;
    'body')
    BODY="${BODY} ${VALUE}";;
    'vertical')
    if test "$VALUE" == "on"; then
      VERTICAL="body{-epub-writing-mode:vertical-rl}"
      PAGENATION=" page-progression-direction='rtl'"
    fi;;
  esac
done < $1
# --- Manifest Code ---
cat << EOM > $OPF
<?xml version="1.0" encoding="utf-8"?>
<package xmlns="http://www.idpf.org/2007/opf" version="3.0" unique-identifier="pub-id">

<metadata>
  <dc-metadata xmlns:dc="http://purl.org/dc/elements/1.1/">
    <dc:identifier id="pub-id">${ID}</dc:identifier>
    <dc:title>${TITLE}</dc:title>
    <dc:language>ja</dc:language>
    <meta property="dcterms:modified">2011-01-01T12:00:00Z</meta>
  </dc-metadata>
</metadata>

<manifest>
  <item id="cover-image" media-type="image/jpg" href="${COVER}" properties="cover-image" />
  <item id="toc" properties="nav" href="${TOC}" media-type="application/xhtml+xml" />
  <item id="content" media-type="application/xhtml+xml" href="${CONTENT}" />
</manifest>

<spine${PAGENATION}>
  <itemref idref="cover-image" />
  <itemref idref="toc" />
  <itemref idref="content" />
</spine>

<nav epub:type="landmarks">
  <ol>
    <li><a epub:type="cover-image" href="${COVER}">表紙</a></li>
    <li><a epub:type="toc" href="${TOC}">目次</a></li>
  </ol>
</nav>

</package>
EOM
# --- Manifest Code ---
# --- TOC Code ---
cat << TOCH > $TOC
<!doctype html>
<html lang='ja'>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="${STYLESHEET}">
</head>
<body>
<h1 id="index">${TITLE}</h1>
<h2>目次</h2>
<nav epub:type="toc">
<ol id="toc">
TOCH
for INDEX in $BODY
do
if test ! -e ${INDEX}.txt; then
  echo "${INDEX}.txt is not exist."
  exit 1
else
  while read LINE
  do
    if test "`echo $LINE | grep -e '^# '`"; then
      HEADLINE=`echo $LINE | cut -d ' ' -f 2-`
    fi
  done < ${INDEX}.txt
  echo "  <li><a epub:type="toc" href=\"${CONTENT}#${INDEX}\">${HEADLINE}</a></li>" >> $TOC
fi
done
cat << TOCT >> $TOC
</ol>
</nav>
</body>
</html>
TOCT
# --- TOC Code ---
# --- Body Code ---
cat << BODYH > $CONTENT
<!doctype html>
<html lang='ja'>
<head>
<meta http-equiv="content-type" content="text/html; charset=UTF-8">
<link rel="stylesheet" type="text/css" href="${STYLESHEET}">
</head>
<body>
BODYH
for INDEX in $BODY
do
if test ! -e ${INDEX}.txt; then
  echo "${INDEX}.txt is not exist."
  exit 1
else
  while read LINE
  do
    INITIAL=`echo $LINE | cut -c 1`
    if test "$INITIAL" == "#"; then
      FIRST=`echo $LINE | cut -d ' ' -f 1`
      if test "$FIRST" == "#"; then
        LINE=`echo $LINE | sed "s/^# \(.*\)/<h2 id=\"$INDEX\">\1<\/h2>/"`
      elif test "$FIRST" == "##"; then
        LINE=`echo $LINE | sed 's/^## \(.*\)/<h3>\1<\/h3>/'`
      elif test "$FIRST" == "###"; then
        LINE=`echo $LINE | sed 's/^### \(.*\)/<h4>\1<\/h4>/'`
      fi
    elif test "$INITIAL" == '~'; then
      LINE=`echo $LINE | sed 's/^~\(.*\)/<p style="margin-left:1em;">\1<\/p>/'`
    elif test "$INITIAL" == '{'; then
      LINE=`echo $LINE | sed 's/{\(.*\)!\(.*\)}/<tr><th class="character">\1<\/th><td class="dialogue">\2<\/td><\/tr>/g'`
    elif test "$INITIAL" != '<'; then
      LINE=`echo $LINE | echo "<p>${LINE}</p>"`
    fi
    echo $LINE | sed 's/\[\([^|]*\)\|\([^]]*\)\]/<ruby>\1<rp>（<\/rp><rt>\2<\/rt><rp>）<\/rp><\/ruby>/g' >> $CONTENT
  done < ${INDEX}.txt
echo "<p style='page-break-after:always'><a epub:type='toc' href='${TOC}#index'>もくじにもどる</a></p>" >> $CONTENT
fi
done
cat << BODYT >> $CONTENT
</body>
</html>
BODYT
# --- Body Code ---
# --- Style Code ---
cat << STYLE > $STYLESHEET
p {text-indent:1em;}
#toc {
  border:solid 1px #ccc;
  background:#eee;
  padding:1em 2em;
  list-style:none;
}
.character {
  width:3em;
  padding-left:1em;
  padding-right:0.5em;
  border-right:solid 1px #aaa;
}
.dialogue {
  padding-left:0.5em
}
${VERTICAL}
STYLE
# --- Style Code ---
