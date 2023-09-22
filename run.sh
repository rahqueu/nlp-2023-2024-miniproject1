#!/bin/bash

mkdir -p compiled images

rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############

fstconcat compiled/aux_day.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_day.fst # dia + / = dia/
fstconcat compiled/mmm2mm.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_month.fst # mes + / = mes/

fstconcat compiled/tmp_month.fst compiled/tmp_day.fst | fstarcsort > compiled/tmp_monthday.fst # mes/ + dia/ = mes/dia/
fstconcat compiled/tmp_monthday.fst compiled/aux_year.fst | fstarcsort > compiled/mix2numerical.fst # mes/dia/ + ano = mes/dia/ano

# ############ generate PDFs  ############
echo "Starting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done