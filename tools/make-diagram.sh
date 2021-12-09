#!/bin/sh

INFORMATS=`pandoc --list-input-formats | sort`
OUTFORMATS=`pandoc --list-output-formats | sort`

echo "digraph Pandoc {"
echo "rankdir=LR;"
echo "ranksep=10;"
echo "bgcolor=\"white\";"

printf "{rank=same; "
for r in $INFORMATS; do
  printf "${r}reader "
done
echo ";}"

printf "{rank=same; "
for w in $OUTFORMATS; do
  printf "${w}writer "
done
echo ";}"

for r in $INFORMATS; do
  echo "${r}reader [label=${r}, fontsize=14, width=2, height=1];"
done

for w in $OUTFORMATS; do
  echo "${w}writer [label=${w}, fontsize=14, width=2, height=1];"
done

for r in $INFORMATS; do
  for w in $OUTFORMATS; do
    echo "${r}reader -> ${w}writer [color=\"gray\"];"
  done
done

echo "}"
