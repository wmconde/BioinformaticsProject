#Mike Conde, Nicholas Buhay, Connor Hinkes
#bash ProjectScript (user’s path to ref_sequences) (user’s path to muscle and hmmr) (users path to proteomes folder)
#This for loop aims to compile all the reference sequences for hsp70gene into a single file
for refseq in $1/hsp70gene*
do
  cat $refseq >> hsp70geneCompile.fasta
done

#This for loop aims to compile all the reference sequences for mcrAgene into a single file
for refseq in $1/mcrAgene*
do
  cat $refseq >> mcrAgeneCompile.fasta
done

#These compiled files then are aligned by muscle for analysis. It then asks the user for the path to the directory that muscle is in and saves it as variable $2
$2/muscle -align hsp70geneCompile.fasta -output aligned_hsp70gene.fasta
$2/muscle -align mcrAgeneCompile.fasta -output aligned_mcrAgene.fasta

#This creates a hmm using hmmbuild tool
$2/hmmbuild hsp70geneCompile.hmm aligned_hsp70gene.fasta
$2/hmmbuild mcrAgeneCompile.hmm aligned_mcrAgene.fasta

#This uses hmmsearch with our hmm we created to find the compatibility between the proteome and reference sequence
echo "Proteome , HSP70count , mcrAcount" >FinalOutput.csv
for file in $3/*.fasta
do
  $2/hmmsearch --tblout hsp70.output hsp70geneCompile.hmm $file
  $2/hmmsearch --tblout mcrA.output mcrAgeneCompile.hmm $file

#count the number of matches for each of the genes. Put the numbers into variables, so we can make an output table, then make names of the proteomes using cut to take out the path
  gene1count=$(cat hsp70.output | grep -v '#' | wc -l)
  gene2count=$(cat mcrA.output | grep -v '#' | wc -l)
  name=$(echo $file | cut -d / -f 10 |cut -d . -f 1)

#We then take these 3 variables and output them into a final .csv file
  echo "$name , $gene1count , $gene2count" >>FinalOutput.csv
done
