#!/bin/bash

mkdir -p compiled images
rm -f ./compiled/*.fst ./images/*.pdf

# ############ Compile source transducers ############
for i in sources/*.txt tests/*.txt; do
	echo "Compiling: $i"
    fstcompile --isymbols=syms.txt --osymbols=syms.txt $i | fstarcsort > compiled/$(basename $i ".txt").fst
done

# ############ CORE OF THE PROJECT  ############

# 2

fstconcat compiled/aux_day.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_day.fst # dia + / = dia/
fstconcat compiled/mmm2mm.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_month.fst # mes + / = mes/

fstconcat compiled/tmp_month.fst compiled/tmp_day.fst | fstarcsort > compiled/tmp_monthday.fst # mes/ + dia/ = mes/dia/
fstconcat compiled/tmp_monthday.fst compiled/aux_year.fst | fstarcsort > compiled/mix2numerical.fst # mes/dia/ + ano = mes/dia/ano

# 3

fstconcat compiled/month_pt2en.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_pt2en1.fst
fstconcat compiled/aux_day.fst compiled/aux_slash.fst | fstarcsort > compiled/tmp_pt2en2.fst
fstconcat compiled/tmp_pt2en1.fst compiled/tmp_pt2en2.fst | fstarcsort > compiled/tmp_pt2en3.fst
fstconcat compiled/tmp_pt2en3.fst compiled/aux_year.fst | fstarcsort > compiled/pt2en.fst

# 4

fstreverse compiled/pt2en.fst > compiled/en2pt.fst # not working for some reason...


#8

fstconcat compiled/month.fst compiled/aux_slash2.fst | fstarcsort > compiled/tmp_month.fst
fstconcat compiled/day.fst compiled/aux_slash3.fst | fstarcsort > compiled/tmp_day.fst
fstconcat compiled/tmp_month.fst compiled/tmp_day.fst | fstarcsort > compiled/tmp_monthday.fst
fstconcat compiled/tmp_monthday.fst compiled/year.fst | fstarcsort > compiled/datenum2text.fst




# ############ generate PDFs  ############
echo "Starting to generate PDFs"
for i in compiled/*.fst; do
	echo "Creating image: images/$(basename $i '.fst').pdf"
   fstdraw --portrait --isymbols=syms.txt --osymbols=syms.txt $i | dot -Tpdf > images/$(basename $i '.fst').pdf
done

# TESTING

#3 - presents the output with the tokens concatenated (uses a different syms on the output)
fst2word() {
	awk '{if(NF>=3){printf("%s",$3)}}END{printf("\n")}'
}

trans=mix2numerical.fst
echo "***********************************************************"
echo "Testing mix2num  (output is a string  using 'syms-out.txt')"
echo "***********************************************************"
for w in "NOV/19/2020"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

trans=datenum2text.fst
echo "***********************************************************"
echo "Testing datenum2text  (output is a string  using 'syms-out.txt')"
echo "***********************************************************"
for w in "11/19/2020"; do
    res=$(python3 ./scripts/word2fst.py $w | fstcompile --isymbols=syms.txt --osymbols=syms.txt | fstarcsort |
                       fstcompose - compiled/$trans | fstshortestpath | fstproject --project_type=output |
                       fstrmepsilon | fsttopsort | fstprint --acceptor --isymbols=./scripts/syms-out.txt | fst2word)
    echo "$w = $res"
done

echo "The end"