use Test::More tests => 4;
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
print Dumper($ann);

# check the command
is($ann->{'cmd'}, $expected_command, "Command matches expected");

# run the command to generate the desired output
system($ann->{'cmd'});

# compare the output from the command with the expected output
my $expected_snpeff_vcf = "$Bin/example/output.ann.expected.vcf";
compare_ok($ann->{'output'}, $expected_snpeff_vcf, "VCF file matches expected output");
my $expected_genes = "$Bin/example/snpEff_genes_expected.txt";
compare_ok($ann->{'genes'}, $expected_genes, "Gene file matches expected");

# can't compare the summary html file as the data prevents an exact replica

# clean up files
unlink($ann->{'output'});
unlink($ann->{'genes'});
unlink($ann->{'summary'});

