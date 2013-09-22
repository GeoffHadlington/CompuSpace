#! usr/bin/perl
use strict;
use diagnostics;
use warnings;
use Path::Class;

#Start by showing them where they are, and then enable input.
Look();
my $active=1;
my $rootName=dir()->parent->absolute;
Prompt(dir());

sub Prompt{
	#this isn't what I want. I need to take the passed parameter, which should be an absolute value for a directory.
	my $curDir = dir(@_);
	my $curDirName = $curDir->absolute;
	#print "$curDirName is the current directory.\n";
	my $input = <>;	
	#Strip the newline.
	chomp $input;
	$_ = $input;
	#Figure out how to do verbose output. Just a bool switch, right?
	print "You typed $input.\n";
	#Input handling in elsif tree.
	if (/look/) { Look($curDir); }
	elsif (/quit/) { 
		print "Goodbye.\n"; 
		$active=0;
		return;}
	#This is where we need to start being able to pull variables. Pick up here tomorrow.
	elsif (/help/) { 
		print "Type \"look\" to see the contents of this room/dir.\n".
		"Type \"quit\" to leave the game.\n".
		"Type \"help\" if you have short term memory problems.\n".
		"Type \"go \$DESTINATION\" to go to a sub or parent directory.\n".
		"Type \"open \$DESTINATION\" to do the same.\n".
		"Type \"pull \$FILENAME\" to open a file using whatever protocol your computer has available.\n";
		}
	elsif (/go back/) {
		my $parentName=$curDir->parent->absolute;
		if ($parentName eq $rootName){
			print "We can't stop there, that's root country.";
		}
		else{
			my $targetDir=dir("$parentName") or print "Can't back out.";
			print "$targetDir is the targetDir.\n";
			$curDir = dir($targetDir);
			#print "$curDir is curdir.\n";
		}
		Look($curDir);	
	}
	elsif (/go (.+)/) {
		my $targetDir=dir($curDir,$1);
		
		#eval{
		if(-d $targetDir){
			if ($curDirName->contains($targetDir)){
				if($targetDir->is_dir()){
					$curDir = dir($targetDir->absolute);
					Look($curDir);
				}
			}
			else{
				print "Can't find a folder named $1.\n";
				Look($curDir);
			}
		}
		#};
		#if($@){
		else{
			if ($curDirName->contains($targetDir)){
			print("Ya dun goofed, that there's a lever.\n");}
			else{
			print("Can't find $targetDir here.\n");}
			Look($curDir);
		}
	}
	elsif (/pull (.+)/) {
		my $leverInput = $1;
		if($^O =~ /MSWin/){
			my $targetFile=file($curDir,$leverInput);
			#print $curDir;
			#print $targetDir;
			if ($curDirName->contains($targetFile)){
				if(!-d $targetFile){
					system("start $targetFile");
					#print "$curDir is curdir.\n";
					Look($curDir);
				}
				else{
					print("This doesn't seem to be a lever.\n");
					Look($curDir);
				}
			}
			else{
				print "Can't find a file named $leverInput.\n";
				Look($curDir);
			}
		}
		else{
			print("Sorry, levers can only be pulled in a Windows environment.\n");
		}
	}
	else{
		print "$input is not a recognized command.\n";
	}
	Prompt($curDir);
}

sub Look{
	#First, we want to store the room we're looking at.
	my $lookDir = dir(@_); #includes the name of dir, though?
	#next, we make an array of things to list.
	my @contents = $lookDir->relative->children;
	my @refs = $lookDir->absolute->children;
	#print @contents;
	my $dirName = $lookDir->absolute;
	#print $dirName;
	#$_ = $dirName;	
	#Then, we want to list off files and folders in the room as either levers or doors.
	print "\nYou are in $dirName. \n";
	#list objects first
	#I'm going to try writing this loop explicitly.
	#print "@refs\n";
	foreach my $child (@refs){
		#Only handle end files.
		if(!$child->is_dir()){
			#Tell them there's a lever here.
			my $childName = $child->basename;
			print "There is a lever labeled $childName. \n";
		}
	}
	#--------------------------------------------
	#my $child=$contents[$#contents];
	#while($#contents>=0){
	#	if(!$child->is_dir()){
	#		print "There's a lever labered $child. ";
	#		pop(@contents);
	#		my $child=$contents[$#contents];
	#	}
	#}
	
	#Separate levers and rooms for readability. 
	print "\n";
	foreach my $file (@contents){
		#Only handle directories.
		if($file->is_dir()){
			#Tell them there's a door here.
			my $fileName = $file->basename;
			print "There is a door labeled $fileName.\n";
		}
	}
	print "There is a door labeled BACK.\n";
}
