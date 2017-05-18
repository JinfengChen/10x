#!/usr/bin/perl

use FindBin qw ($Bin);
use Getopt::Long;


GetOptions(\%opt,"fasta:s","output:s","reverse:s","help:s");

my $help=<<USAGE;
Rename header by rank number
perl rename_by_num.pl -f RAP3.fa -o nohit.fa > log  

USAGE

if (exists $opt{help} or !-f $opt{fasta}){
   print $help;
   exit;
}


### store id into hash %id
#my %id;
#open IN, "$opt{list}" or die "$!";
#while(<IN>){
#    chomp $_;
#    next if ($_ eq "");
#    my @unit=split("\t",$_);
#    $id{$unit[0]}=1;    
#}
#close IN;


### read fasta file and output fasta if id is found in list file
$/=">";
my $count = 0;
open IN,"$opt{fasta}" or die "$!";
open OUT, ">$opt{output}" or die "$!";
while (<IN>){
    next if (length $_ < 2);
    my @unit=split("\n",$_);
    my $temp=shift @unit;
    my @temp1=split(" ",$temp,2);
    my $head=$temp1[0];
    my $anno=$temp1[1];
    #print "$temp\n";
    #my @temp2=split /"\|",$temp/;
    #my $head1=$temp2[0];
    #$head1=~s/|//g;
    #print "$head1\n";
    my $seq=join("\n",@unit);
    $seq=~s/\>//g;
    $count += 1;
    $head = $count;
    if (exists $opt{reverse}){
        #if (!exists $id{$head}){
        print OUT ">$head\n$seq";
        #}
    }else{
        #if (exists $id{$head}){
        print OUT ">$head\n$seq";
        #}
    }
    #elsif(exists $id{$head1}){
    #  print OUT ">$head1\n$seq";
    #}
    
 
}
close OUT;
close IN;
$/="\n";


