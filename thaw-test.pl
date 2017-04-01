#!/usr/bin/perl -I lib

# Run this script via either:
# /usr/bin/perl -I lib
# ... or:
# /usr/bin/perl -I lib -d:Trace

### Setting up the environment in which the script will run:

# - Install Intuit QuickBooks Premier 2016 Non-Profit
# - Download and install the QuickBooks SDK version 13
# - From the SDK: Copy QBSDKRP2.dll to C:\Windows\System32
# - In a Command Prompt window (cmd.exe) that is running as Administrator, run: C:\Windows\SysWOW64\RegSvr32.exe C:\Windows\System32\QBSDKRP2.dll /S
# - Install the 32-bit version of Cygwin. We need the 32-bit version because QBSDKRP2.dll is a 32-bit DLL, and the 64-bit version of the Cygwin / Perl / Win32::OLE stack can't talk to a 32-bit COM DLL such as QBSDKRP2.dll. In general, 64-bit apps cannot use 32-bit DLLs.
# - Run the 32-bit Cygwin setup and install the following packages:
#   - gcc-g++
#   - make
#   - libcrypt-devel
#   - libxml2-devel
#   - perl-XML-LibXML
#   - perl-XML-LibXML-debuginfo
#   - perl-XML-LibXSLT
#   - perl-XML-LibXSLT-debuginfo
# - In the Cygwin terminal:
#   - Run the following commands to install the needed Perl modules:
#     - cpan Win32::OLE failed, so I did this:
#		cpan
#		look Win32::OLE
#		# Use the vi text editor to replace stricmp with strcasecmp in OLE.xs, then run:
#		make Win32::OLE
#		test Win32::OLE
#		force install Win32::OLE (because "install Win32::OLE" failed)
#     - cpan -i Moose
#     - cpan -i HTML::Element::Library
#     - cpan -i XML::Element
#     - cpan -f -i -T XML::Writer::Compiler (it failed without -f -T)
#     - cpan -i Log::Log4perl
#     - cpan -i Log::Dispatch::Screen
#     - cpan -i Log::Dispatch::FileRotate
#     - cpan -i Devel::Trace
#     - cpan -i MooseX::Log::Log4perl (perhaps we didn't need to install Log::Log4perl above)
#   - git clone https://github.com/metaperl/XML--Quickbooks.git
#   - Copy this file (thaw-test.pl) into the XML--Quickbooks directory
#   - Launch QuickBooks; log in, and ensure that a company file is open
#   - You may need to ensure that QuickBooks is in single-user mode and multi-currency mode.
#   - ./thaw-test.pl

###

use strict;
use warnings;
use Moose::Role; # This prevents the error: "Undefined subroutine &Class::MOP::load_class called at ./thaw-test.pl line 95."

### BEGIN : From http://www.perl.com/pub/2002/09/11/log4perl.html :

use Log::Log4perl qw(get_logger :levels);

# my $foo_logger = get_logger("Groceries::Food");
# my $foo_logger = get_logger(__PACKAGE__);
my $foo_logger = get_logger($0);

# From http://log4perl.sourceforge.net/releases/Log-Log4perl/docs/html/Log/Log4perl/Level.html

# Log::Log4perl::Level simply exports a predefined set of Log4perl log levels into the caller's name space. It is used internally by Log::Log4perl. The following scalars are defined:

    # $OFF
    # $FATAL
    # $ERROR
    # $WARN
    # $INFO
    # $DEBUG
    # $TRACE
    # $ALL

# $foo_logger->level($INFO);
$foo_logger->level($ALL);

my $appender = Log::Log4perl::Appender->new(
    "Log::Dispatch::File",
    filename => "foo.log",
    mode     => "append",
);

$foo_logger->add_appender($appender);

my $layout = Log::Log4perl::Layout::PatternLayout->new("%d %p> %F{1}:%L %M - %m%n");

$appender->layout($layout);

### END : From http://www.perl.com/pub/2002/09/11/log4perl.html .

my $data = { Name => 'John Smith' };
my $operation = 'CustomerAdd';
my $class = "XML::Quickbooks::Writer::$operation";
Class::MOP::load_class($class);
my $operationObject = $class->new(data => $data);
$operationObject->process;
