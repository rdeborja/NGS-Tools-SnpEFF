use Test::More tests => 2;
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

my $ann = $annotate->annotate_vcf(
    vcf => 'example/test.vcf',
    genome => 'mm10',
    output => 'output.ann.vcf',
    snpeff => '/usr/local/sw/snpeff/4.3i/snpEff.jar'
    );

my $expected_command = join(' ',
    'java -Xmx8g',
    '-Djava.io.tmpdir=./tmp',
    '-jar /usr/local/sw/snpeff/4.3i/snpEff.jar',
    '-v -download',
    'mm10',
    'example/test.vcf',
    '>',
    'output.ann.vcf'
    );
is($ann->{'cmd'}, $expected_command, "Command matches expected");
print Dumper($ann);
