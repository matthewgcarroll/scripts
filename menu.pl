#!/usr/bin/perl
# Author: Ian McGowan <ian@simbian.org>
# Date  : 2016-09-02
# Desc  : A perl menu script, no more manual updates and no more tears!
# Changelog:
# ----------
# 2016-09-02:MCGOWJ01:Initial version
# 2016-09-02:MCGOWJ01:Improve cursor positioning/layout with Term::Cap
# 2016-09-02:MCGOWJ01:Replace perl Find::Files with canned list of accounts

# Called as menu.pl <dept or project>
# Reads main menu from /info/menu2bin/menu_global
#       dept menu from /info/menu2bin/menu_<dept>
#       user menu from ~/menu_<$LOGNAME>
# E.g. "menu.pl india", "menu.pl accounting", "menu.pl basel", "menu.pl cap"

use Term::Cap;  # Used for cursor positioning
my $t = Term::Cap->Tgetent;

# Loop forever, until the user quits, or the heat-death of the Universe
while (1) {
  init(); # Wasteful to re-read everything, but helps with user menus
  display_menu();
  get_input();
  process_input();
}

sub init {
  # Some environmental junk
  $host=qx/hostname/;
  chomp($host);
  $user=qx/echo \$USER/;
  chomp($user);
  $dept=$ARGV[0];
  $ctr=1;
  %menu=();
  
  # Global menu is shared by all users, die if it's not there
  $menu_file="/info/menu2bin/menu_global";
  open(FH, $menu_file) or die "$menu_file:$!\n";
  # Read in lines one at a time
  while ($line=<FH>) {
    chomp ($line);
    # Menu is a hash table (key-value pair), with a key of the menu number
    # and value is an array with two strings:
    #  String1 = type of entry, String2 = path to account
    $menu{$ctr++}=["GLOBAL",$line];
  }
  close(FH);
  
  # dept menu is specific to each dept/project, passed in ARGS
  # Only display options if file exists
  $menu_file="/info/menu2bin/menu_$dept";
  if (-e $menu_file) {
    open(FH,$menu_file) or die "$menu_file:$!\n";
    while ($line=<FH>) {
      chomp ($line);
      $menu{$ctr++}=["DEPT",$line];
    }
    close(FH);
  }
  
  # User menu is specific to each user, stored in ~/menu_$USER
  $user_menu_file="/home/$user/menu_$user";
  if (-e $user_menu_file) {
    open(FH, $user_menu_file) or die "$user_menu_file:$!\n";
    while ($line=<FH>) {
      chomp ($line);
      $menu{$ctr++}=["USER",$line];
    }
    close(FH);
  }
  
  # Set the max number by counting how many keys there are (scalar context)
  $menu_max=keys %menu;
  
  # Get a list of accounts to search.  To rebuild the list run: 
  # find /info -type f -name VOC -exec dirname {} \;| grep -Ev "SQL|INFO|SYS.9F" > /info/menu2bin/menu_accounts
  $menu_file="/info/menu2bin/menu_accounts";
  %acc = ();
  $ctr=1;
  if (-e $menu_file) {
    open(FH,$menu_file) or die "$menu_file:$!\n";
    while ($line=<FH>) {
      chomp ($line);
      # Could probably use an array, but use a hash to be consistent
      $acc{$ctr++}=$line;
    }
    close(FH);
  }
}

sub display_menu {
  system("clear");
  printf "%-40s%40s","Welcome to $host:$user", scalar localtime;
  print "\n\n";
  print "Global Options\n";
  print "--------------\n";

  # Print just the global options in numeric order ({$a<=>$b} forces numeric)
  foreach my $key ( sort {$a<=>$b} keys %menu )
  {
    if ($menu{$key}[0] eq "GLOBAL") {
      printf "%2d) %s\n", $key, $menu{$key}[1];
    }
  }

  # If there are any dept menu options, print under the global
  if (-e "/info/menu2bin/menu_$dept") {
    print "\n";
    print ucfirst($dept)." Options\n";
    print "-" x (length($dept)+8);
    print "\n";

    # Print just the dept options
    foreach my $key ( sort {$a<=>$b} keys %menu )
    {
      if ($menu{$key}[0] eq "DEPT") {
        printf "%2d) %s\n", $key, $menu{$key}[1];
      }
    }
  }
  
  # Print the user menu options to the top right
  print $t->Tgoto("cm", 40, 2);
  print "Saved Options";
  print $t->Tgoto("cm", 40, 3);
  print "-------------";
  $ctr=1;

  # Print just the dept options
  foreach my $key ( sort {$a<=>$b} keys %menu )
  {
    if ($menu{$key}[0] eq "USER") {
      print $t->Tgoto("cm", 40, 3+$ctr++);
      printf "%2d) %s\n", $key, $menu{$key}[1];
    }
  }
}

sub get_input {
  print $t->Tgoto("cm", 0, 22); # Move cursor Col#1, Row#23
  print "Choice (1-$menu_max), e edit, r rebuild, x exit, or search:";
  $input = <STDIN>;
  chomp ($input);
}

sub process_input {
  # Process each option, then return
  
  # ENTER
  if ($input eq "") {return;}
  
  # Exit - match x, X or /
  if ($input =~ m/^x|\/$/i){exit;}

  # Edit
  if ($input =~ m/^e$/i) {
    system("\$VISUAL $user_menu_file");
    return;
  }

  # Rebuild - need this because a) we don't have gnu find and
  # b) accounts are scattered everywhere under /info
  if ($input =~ m/^r$/i) {
    $s="find /info -type f -name VOC -exec dirname {} \\;| grep -Ev 'SQL|INFO|SYS.9F' > /info/menu2bin/menu_accounts&";
    system("clear");
    print $s,"\n";
    system($s);
    $pause=<STDIN>;
    return;
  }
  
  # Pick one of the menu choices
  if (exists $menu{$input}) {
    $acc=$menu{$input}[1];
    system("cd $acc;udt");
    return;
  }
  
  # Anything else means we search
  system("clear");
  foreach my $key ( sort {$a<=>$b} keys %acc )
  {
    if ($acc{$key} =~ m/$input/) {
      printf "%2d) %s\n", $key, $acc{$key};
    }
  }
  print "\nPick an account:";
  $input=<STDIN>;
  chomp($input);
  if ($input eq "") {return;}
  $account=$acc{$input};
  system("cd $account;udt");
  system("clear");
  print "Add $account to your list of accounts? (Y/N):";
  $input=<STDIN>;
  if ($input =~ m/Y/i) {
    system("echo $account >> $user_menu_file");
  }
}
