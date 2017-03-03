#!/usr/bin/perl -w 

use Tk; 
$Tk::strictMotif = 1; 
$main = MainWindow->new(); 
$button1 = $main->Button(-text => "Exit",
                         -command => \&exit_button,
                         -foreground => "orangered" ); 
$button1->pack();
$button1->configure(-background => "white" );
$button2 = $main->Button(-text => "Push Me",
                         -command => \&change_color,
                         -foreground => "black", 
                         -background => "steelblue");
$button2->pack(); 
MainLoop(); 
sub exit_button { 
    print "You pushed the button!\n"; 
    exit; 
} 
sub change_color { 
    $button1->configure(-background => "red", 
                        -foreground => "white"); 
    $button2->configure(-background => "maroon", 
                        -foreground => "white", 
                        -font       => "-*-times-bold-r-normal-20-140-*"); 
}
