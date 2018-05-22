#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

DONGRICOIND=${DONGRICOIND:-$SRCDIR/dongrid}
DONGRICOINCLI=${DONGRICOINCLI:-$SRCDIR/dongri-cli}
DONGRICOINTX=${DONGRICOINTX:-$SRCDIR/dongri-tx}
DONGRICOINQT=${DONGRICOINQT:-$SRCDIR/qt/dongri-qt}

[ ! -x $DONGRICOIND ] && echo "$DONGRICOIND not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
DNGRVER=($($DONGRICOINCLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$DONGRICOIND --version | sed -n '1!p' >> footer.h2m

for cmd in $DONGRICOIND $DONGRICOINCLI $DONGRICOINTX $DONGRICOINQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${DNGRVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${DNGRVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m