#!/bin/bash

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############

fstconcat compiled/aux_day.fst compiled/aux_slash.fst | fstrmepsilon | fstarcsort > compiled/tmp_day.fst
fstdraw --isymbols=syms.txt --osymbols=syms.txt --portrait compiled/tmp_day.fst | dot -Tpdf > images/tmp_day.pdf

fstconcat compiled/mmm2mm.fst compiled/aux_slash.fst | fstrmepsilon | fstarcsort > compiled/tmp_month.fst
fstdraw --isymbols=syms.txt --osymbols=syms.txt --portrait compiled/tmp_month.fst | dot -Tpdf > images/tmp_month.pdf

fstconcat compiled/tmp_month.fst compiled/tmp_day.fst | fstrmepsilon | fstarcsort > compiled/tmp_monthday.fst
fstconcat compiled/tmp_monthday.fst compiled/aux_year.fst | fstrmepsilon | fstarcsort > compiled/mix2numerical.fst

fstdraw --isymbols=syms.txt --osymbols=syms.txt --portrait compiled/mix2numerical.fst | dot -Tpdf > images/mix2numerical.pdf


# ############ generate PDFs  ############
echo "Starting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done