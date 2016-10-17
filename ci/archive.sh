#!/bin/bash
set -e

[[ -f "$scripts/setup.sh" ]] && source "$scripts/setup.sh"

pushd "$(dirname "$0")/.." > /dev/null
root=$(pwd -P)
popd > /dev/null

ins="$root/documents"
outs="$root/out"
scripts="$root/documents/userguide/scripts"

hostname="geointservices.io"

hash asciidoctor >/dev/null 2>&1 || gem install asciidoctor
hash asciidoctor-pdf >/dev/null 2>&1 || gem install --pre asciidoctor-pdf

echo "testing installed tools"
which asciidoctor
which asciidoctor-pdf
echo "test done"

source "$root/ci/vars.sh"


function build_docs {
    indir=$1
    outdir=$2

    aaa=$(dirname "$indir/index.txt")
    bbb=$(basename "$aaa")
    echo "Processing: $bbb/index.txt"

    # insert build date
    dat=`date "+%Y-%m-%d"`
    dattim=`date "+%Y-%m-%d %H:%M:%S %Z"`
    sed "s/__DATE__/$dat/g" "$indir/index.txt" > "$indir/index.txt.2"

    # txt -> html
    asciidoctor -o "$outdir/index.html" "$indir/index.txt.2"  &> errs.tmp
    if [[ -s errs.tmp ]] ; then
        echo "FAIL: asciidoctor"
        cat errs.tmp
        exit 1
    fi

    # txt -> pdf
    asciidoctor -r asciidoctor-pdf -b pdf -o "$outdir/index.pdf" "$indir/index.txt.2"  &> errs.tmp
    if [[ -s errs.tmp ]] ; then
        echo "FAIL: asciidoctor-pdf"
        cat errs.tmp
        exit 1
    fi

    # if errs.tmp is empty, remove it
    [[ -s "errs.tmp" ]] || rm "errs.tmp"

    # copy images directory to out dir
    cp -R "$indir/images" "$outdir"

    # copy scripts directory to out dir
    cp -R "$indir/scripts" "$outdir"
}

function run_tests {
    # verify the example scripts
    echo
    echo "Testing started"

    cp "$scripts/terrametrics.tif" "$root"

    echo ; echo ; echo TEST START ; echo ; echo
    pushd $scripts
    ./runall.sh
    popd
    echo ; echo ; echo TEST END ; echo ; echo

    rm -f "$root/terrametrics.tif"

    echo "Testing completed"
}


#sh $root/etc/spellcheck.sh


[[ -d "$outs" ]] && rm -rf "$outs"
mkdir "$outs"


build_docs "$ins" "$outs"
build_docs "$ins/userguide"   "$outs/userguide"
build_docs "$ins/devguide"    "$outs/devguide"


sh $root/ci/replace-hostname.sh $hostname


mkdir "$outs/presentations"
cp -f $ins/presentations/*.pdf "$outs/presentations/"

# Can't run the tests because Jenkins doesn't have an API key.
#run_tests

echo Done.

tar -czf "$APP.$EXT" -C "$root" out
