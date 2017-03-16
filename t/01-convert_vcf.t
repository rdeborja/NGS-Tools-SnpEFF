use Test::More tests => 1;
use Test::Moose;
use Test::Exception;
use MooseX::ClassCompositor;
use Test::Files;
use FindBin qw($Bin);
use lib "$Bin/../lib";
use File::Temp qw(tempfile tempdir);
use Data::Dumper;

# setup the class creation process
my $test_class_factory = MooseX::ClassCompositor->new(
	{ class_basename => 'Test' }
	);

# create a temporary class based on the given Moose::Role package
my $test_class = $test_class_factory->class_for('NGS::Tools::SnpEFF::Roles::Annotate');

# instantiate the test class based on the given role
my $annotate;
lives_ok
	{
		$annotate = $test_class->new();
		}
	'Class instantiated';

my $test_vcf = "$Bin/example/output.ann.expected.vcf";
my $vcf_table = $annotate->convert_vcf_to_table(
	vcf => $test_vcf
	);

