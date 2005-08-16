=head1 NAME

Text::Record::Deduper - Separate complete, partial and near duplicate text records

=head1 SYNOPSIS

    use Text::Record::Deduper;

    my $deduper = new Text::Record::Deduper;

    # Find and remove entire lines that are duplicated
    $deduper->dedupe_file("orig.txt");

    # Dedupe comma separated records, duplicates defined by several fields
    $deduper->field_separator(',');
    $deduper->add_key(field_number => 1, ignore_case => 1 );
    $deduper->add_key(field_number => 2, ignore_whitespace => 1);

    # Find 'near' dupes by allowing for given name aliases
    my %nick_names = (Bob => 'Robert',Rob => 'Robert');
    my $near_deduper = new Text::Record::Deduper();
    $near_deduper->add_key(field_number => 2, alias => \%nick_names) or die;
    $near_deduper->dedupe_file("names.txt");

    # Now find 'near' dupes in an array of records
    my ($uniqs,$dupes) = $near_deduper->dedupe_array(\@some_records);



=head1 DESCRIPTION

This module allows you to take a text file of records and split it into 
a file of unique and a file of duplicate records.

Records are defined as a set of fields. Fields may be separated by spaces, 
commas, tabs or any other delimiter. Records are separated by a new line.

If no options are specifed, a duplicate will be created only when all the
fields in a record (the entire line) are duplicated.

By specifying options a duplicate record is defined by which fields or partial 
fields must not occur more than once per record. There are also options to 
ignore case sensitivity, leading and trailing white space.

Additionally 'near' or 'fuzzy' duplicates can be defined. This is done by creating
aliases, such as Bob => Robert.

This module is useful for finding duplicates that have been created by
multiple data entry, or merging of similar records


=head1 METHODS

=head2 new

The C<new> method creates an instance of a deduping object. This must be
called before any of the following methods are invoked.

=head2 field_separator

Sets the token to use as the field delimiter. Accepts any character as well as
Perl escaped characters such as "\t" etc.  If this method ins not called the 
deduper assumes you have fixed width fields .

    $deduper->field_separator(',');


=head2 add_key

Lets you add a field to the definition of a duplicate record. If no keys
have been added, the entire record will become the key, so that only records 
duplicated in their entirity are removed.

    $deduper->add_key
    (
        field_number => 1, 
        key_length => 5, 
        ignore_case => 1,
        ignore_whitespace => 1,
        alias => \%nick_names
    );

=over 4

=item field_number

Specifies the number of the field in the record to add to the key (1,2 ...). 
Note that this option only applies to character separated data. You will get a 
warning if you try to specify a field_number for fixed width data.

=item start_pos

Specifies the position of the field in characters to add to the key. Note that 
this option only applies to fixed width data. You will get a warning if you 
try to specify a start_pos for character separated data. You must also specify
a key_length.

Note that the first column is numbered 1, not 0.


=item key_length

The length of a key field. This must be specifed if you are using fixed width 
data (along with a start_pos). It is optional for character separated data.

=item ignore_case 

When defining a duplicate, ignore the case of characters, so Robert and ROBERT
are equivalent.

=item ignore_whitespace

When defining a duplicate, ignore white space that leasd or trails a field's data.

=item alias

When defining a duplicate, allow for aliases substitution. For example

    my %nick_names = (Bob => 'Robert',Rob => 'Robert');
    $near_deduper->add_key(field_number => 2, alias => \%nick_names) or die;

Whenever field 2 contains 'Bob', it will be treated as a duplicate of a record 
where field 2 contains 'Robert'.

=back


=head2 dedupe_file

This method takes a file name F<basename.ext> as it's only argument. The file is
processed to detect duplicates, as defined by the methods above. Unique records
are place in a file named  F<basename_uniq.ext> and duplicates in a file named 
F<basename_dupe.ext>. Note that If either of this output files exist, they are 
over written The orignal file is left intact.

    $deduper->dedupe_file("orig.txt");


=head2 dedupe_array

This method takes an array reference as it's only argument. The array is
processed to detect duplicates, as defined by the methods above. Two array
references are retuned, the first to the set of unique records and the second 
to the set of duplicates.

Note that the memory constraints of your system may prvent you from processing 
very large arrays.

    my ($unique_records,duplicate_records) = $deduper->dedupe_array(\@some_records);

=head1 EXAMPLES

=head2 Dedupe an array of single records 

Given an array of strings:

    my @emails = 
    (
        'John.Smith@xyz.com',
        'Bob.Smith@xyz.com',
        'John.Brown@xyz.com.au,
        'John.Smith@xyz.com'
    );

    use Text::Record::Deduper;

    my $deduper = new Text::Record::Deduper();
    my ($uniq,$dupe);
    ($uniq,$dupe) = $deduper->dedupe_array(\@emails);

The array reference $uniq now contains

    'John.Smith@xyz.com',
    'Bob.Smith@xyz.com',
    'John.Brown@xyz.com.au'

The array reference $dupe now contains

    'John.Smith@xyz.com'



=head2 Dedupe a file of fixed width records 

Given a text file F<names.txt> with space separated values and duplicates defined 
by the second and third columns:

    100 Bob      Smith    
    101 Robert   Smith    
    102 John     Brown    
    103 Jack     White   
    104 Bob      Smythe    
    105 Robert   Smith    


    use Text::Record::Deduper;

    my %nick_names = (Bob => 'Robert',Rob => 'Robert');
    my $near_deduper = new Text::Record::Deduper();
    $near_deduper->field_separator(' ');
    $near_deduper->add_key(field_number => 2, alias => \%nick_names) or die;
    $near_deduper->add_key(field_number => 3) or die;
    $near_deduper->dedupe_file("names.txt");

Text::Record::Deduper will produce a file of unique records, F<names_uniqs.txt>

    101 Robert   Smith    
    102 John     Brown    
    103 Jack     White   
    104 Bob      Smythe    

and a file of duplicates, F<names_dupes.txt>

    100 Bob      Smith    
    105 Robert   Smith   

The original file, F<names.txt> is left intact.



=head1 TO DO

    Allow for multi line records
    Add batch mode driven by config file or command line options
    Allow option to warn user when over writing output files
    Allow user to customise suffix for uniq and dupe output files


=head1 SEE ALSO

sort(3), uniq(3), L<Text::ParseWords>, L<Text::RecordParser>, L<Text::xSV>


=head1 AUTHOR

Text::Record::Deduper was written by Kim Ryan <kimryan at cpan d o t org>


=head1 COPYRIGHT AND LICENSE

Copyright (C) 2005 Kim Ryan. 


This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.4 or,
at your option, any later version of Perl 5 you may have available.


=cut

package Text::Record::Deduper;
use FileHandle;
use File::Basename;
use Text::ParseWords;
use Data::Dumper;



use 5.008004;
use strict;
use warnings;

require Exporter;

our @ISA = qw(Exporter);
our $VERSION = '0.04';


#-------------------------------------------------------------------------------
# Create a new instance of a deduping object. 

sub new
{
    my $class = shift;
    my %args = @_;

    my $deduper = {};
    bless($deduper,$class);


    # Default to no separator, until we find otherwise
    $deduper->{field_separator} = '';

    return ($deduper);
}
#-------------------------------------------------------------------------------
# Create a new instance of a deduping object. 

sub field_separator
{
    my $deduper = shift;

    my ($field_separator) = @_;

    # Escape pipe symbol so it does get interpreted as alternation character
    # when splitting fields in _get_key_fields
    $field_separator eq '|' and $field_separator = '\|';

    # add more error checking here

    $deduper->{field_separator} = $field_separator;
    return($deduper);
}
#-------------------------------------------------------------------------------
#  
sub add_key
{
    my $deduper = shift;
    my %args = @_;


    $deduper->{key_counter}++;

    if ( $args{field_number} )
    {
        unless ( $deduper->{field_separator} )
        {
            warn "Cannot use field_number on fixed width lines";
            return;
        }
    }
    elsif ( $args{start_pos} )
    {
        if ( $deduper->{field_separator} )
        {
            warn "Cannot use start_pos on character separated records";
            return;
        }
        else
        {
            unless ( $args{key_length} )
            {
                warn "No key_length defined for start_pos: $args{start_pos}";
                return;
            }
        }
    }

    foreach my $current_key (keys %args)
    {
        if ($current_key eq 'ignore_case' )
        {
            $deduper->{ignore_case}{$deduper->{key_counter}} = 1;
        }
        if ($current_key eq 'ignore_whitespace' )
        {
            $deduper->{ignore_whitespace}{$deduper->{key_counter}} = 1;
        }
        if ($current_key eq 'alias' )
        {
            if ( $args{ignore_case} )
            {
                # if ignore case, fold all of alias to upper case
                my %current_alias = %{ $args{$current_key} };
                my %corrected_alias;
                foreach my $current_alias_key ( keys %current_alias )
                {
                    $corrected_alias{uc($current_alias_key)} = uc($current_alias{$current_alias_key});
                    
                }
                $deduper->{alias}{$deduper->{key_counter}} = \%corrected_alias;
            }
            else
            {
                $deduper->{alias}{$deduper->{key_counter}} = $args{$current_key};
            }
        }
        if ($current_key =~ /field_number|start_pos|key_length/ )
        {
            $deduper->{key}{$deduper->{key_counter}}{$current_key} = $args{$current_key};
        }
    }

    return ($deduper);
}
#-------------------------------------------------------------------------------
# 
sub dedupe_file
{
    my $deduper = shift;
    my ($input_file_name) = @_;

    my($files_ok,$file_handles_ref) = _open_files($input_file_name);
    unless ( $files_ok )
    {
        return;
    }

    _dedupe($deduper,'file',undef,$file_handles_ref);
    # Close off all files
    foreach my $file ( keys %$file_handles_ref )
    {
        $file_handles_ref->{$file}->close;
    }
}

#-------------------------------------------------------------------------------
# 
sub _open_files
{
    my ($input_file_name) = @_;

    unless ( -T $input_file_name and -s $input_file_name )
    {
        warn("Could not open input file: $input_file_name"); 
        return(0);
    }

    my $input_fh = new FileHandle "<$input_file_name";
    unless ($input_fh)
    {
        warn "Could not open input file: $input_file_name";
        return(0);
    }

    my ($file_name,$path,$suffix) = File::Basename::fileparse($input_file_name,qr{\..*});

    my $file_name_unique_records    = "$path/$file_name\_uniqs$suffix";
    my $file_name_duplicate_records = "$path/$file_name\_dupes$suffix";

    # TO DO!!! test for overwriting of previous Deduper output
    my $unique_fh = new FileHandle ">$file_name_unique_records";
    unless($unique_fh)
    {
        warn "Could not open file: $file_name_unique_records: $!";
        return(0);
    }

    my $dupes_fh = new FileHandle ">$file_name_duplicate_records";
    unless ( $dupes_fh )
    {
        warn "Could not open file: $file_name_duplicate_records: $!";
        return(0);
    }
    my $file_handles_ref = {};
    $file_handles_ref->{input} = $input_fh;
    $file_handles_ref->{output_unique} = $unique_fh;
    $file_handles_ref->{output_dupe} = $dupes_fh;
    return(1,$file_handles_ref);
}
#-------------------------------------------------------------------------------

sub _rewind_file
{
    my ($storage_type,$file_handles_ref) = @_;
    if ( $storage_type eq 'file' )
    {
        my $input_fh = $file_handles_ref->{input};
        $input_fh->seek(0,0); # rewind file
    }
}

#-------------------------------------------------------------------------------
#                  
sub dedupe_array
{
    my $deduper = shift;

    my ($input_array_ref) = @_;
    my ($uniq,$dupe) = _dedupe($deduper,'array',$input_array_ref,undef);
    return($uniq,$dupe);
}
#-------------------------------------------------------------------------------
#                  
sub _dedupe
{
    my ($deduper,$storage_type,$input_array_ref,$file_handles_ref) = @_;

    my $record_number = 0;
    my $current_line;
    my $finished = 0;


    my %alias_candidates;
    if ( $deduper->{alias} )
    {
        my %all_alias_values = _get_all_alias_values($deduper);
        while ( not $finished )
        {
            ($current_line,$finished) = _read_one_record($storage_type,$record_number,$input_array_ref,$file_handles_ref);
            $record_number++;
            if ( my $alias_candidate_key = _alias_candidate($deduper,$current_line,%all_alias_values) )
            {
                $alias_candidates{$alias_candidate_key} = $record_number;
            }
        }
    }

    my %seen_exact_dupes;
    my $unique_ref = [];
    my $dupe_ref = [];
    $record_number = 0;

    $finished = 0;
    _rewind_file($storage_type,$file_handles_ref);
    while ( not $finished )
    {
        ($current_line,$finished) = _read_one_record($storage_type,$record_number,$input_array_ref,$file_handles_ref);
        $record_number++;

        my $dupe_type;
        my %record_keys = _get_key_fields($deduper,$current_line);
        

        %record_keys =_transform_key_fields($deduper,%record_keys);
        my $full_key = _assemble_full_key(%record_keys);
        if ( _alias_dupe($deduper,\%alias_candidates,%record_keys) )
        {
            $dupe_type = 'alias_dupe';
        }
        # add soundex dupe
        # add string approx dupe
        elsif ( _exact_dupe($current_line,$full_key,%seen_exact_dupes) )
        {
            $dupe_type = 'exact_dupe';
        }
        else
        {
            $dupe_type = 'unique';
            # retain the record number of dupe, useful for detailed reporting and grouping
            $seen_exact_dupes{$full_key} = $record_number;
        }

        _write_one_record($storage_type,$dupe_type,$current_line,$file_handles_ref,$unique_ref,$dupe_ref);
    }
    return($unique_ref,$dupe_ref);
}

#-------------------------------------------------------------------------------
sub _alias_candidate
{
    my ($deduper,$current_line,%all_alias_values) = @_;

    my %record_keys = _get_key_fields($deduper,$current_line);
    %record_keys = _transform_key_fields($deduper,%record_keys);
    
    my $alias_candidate_key = '';
    foreach my $current_key ( sort keys %record_keys )  
    {

        my $current_key_data = $record_keys{$current_key};
        if ( $deduper->{alias}{$current_key} )
        {
            not $all_alias_values{$current_key} and next;
            if ( grep(/^$current_key_data$/,@{ $all_alias_values{$current_key} }) )
            {
                $alias_candidate_key .= $current_key_data . ':';
            }
            else
            {
                return(0);
            }
        }
        else
        {
            $alias_candidate_key .= $current_key_data . ':';
        }
    }
    return($alias_candidate_key); 
}
#-------------------------------------------------------------------------------
# 
sub _get_all_alias_values
{
    my ($deduper) = @_;

    my %all_alias_values;

    foreach my $key_number ( sort keys %{$deduper->{alias}} )
    {
        my %current_alias =  %{ $deduper->{alias}{$key_number} };
        my (@current_alias_values,%seen_alias_values);
        foreach my $current_alias_value ( values %current_alias )
        {
            unless ( $seen_alias_values{$current_alias_value} )
            {
                push(@current_alias_values,$current_alias_value);
                $seen_alias_values{$current_alias_value}++;
            }
        }
        $all_alias_values{$key_number}= [ @current_alias_values ];
    }
    return(%all_alias_values)
}

#-------------------------------------------------------------------------------
# 

sub _get_key_fields
{
    my ($deduper,$current_line) = @_;

    my %record_keys;


    if ( $deduper->{key} )
    {
        if ( $deduper->{field_separator} )
        {

            # The ParseWords module will not handle single quotes within fields, 
            # so add an escape sequence between any apostrophe bounded by a
            # letter on each side. Note that this applies even if there are no
            # quotes in your data, the module needs balanced quotes.        
            if (  $current_line =~ /\w'\w/ )
            {
                # check for names with apostrophes, like O'Reilly
                $current_line =~ s/(\w)'(\w)/$1\\'$2/g;
            }

            # Use ParseWords module to spearate delimited field. 
            # '0' option means don't return any quotes enclosing a field
            my (@field_data) = &Text::ParseWords::parse_line($deduper->{field_separator},0,$current_line);

        
            foreach my $key_number ( sort keys %{$deduper->{key}} )
            {
                my $current_field_data = $field_data[$deduper->{key}->{$key_number}->{field_number} - 1];
                unless ( $current_field_data )
                {
                    # A record has less fields then we were expecting, so no
                    # point searching for anymore.
                    print("Short record\n");
                    print("Current line : $current_line\n");
                    print("All fields   :", @field_data,"\n");
                    last;
                    # TO DO, add a warning if user specifies records that must have 
                    # a full set of fields??
                }

                if ( $deduper->{key}->{$key_number}->{key_length} )
                {
                    $current_field_data = substr($current_field_data,0,$deduper->{key}->{$key_number}->{key_length});
                }
                $record_keys{$key_number} = $current_field_data;
            }
        }
        else
        {
            foreach my $key_number ( sort keys %{$deduper->{key}} )
            {
                my $current_field_data = substr($current_line,$deduper->{key}->{$key_number}->{start_pos} - 1,
                    $deduper->{key}->{$key_number}->{key_length});
                if ( $current_field_data )
                {
                    $record_keys{$key_number} = $current_field_data;
                }
                else
                {
                    print("Short record\n");
                    print("Current line : $current_line\n");
                    last;
                    # TO DO, add a warning if user specifies records must have 
                    # a full set of fields??
                }
            }
        }
    }
    else
    {
        # no key fileds defined, use whole line as key
        $record_keys{1} = $current_line;
    }
    return(%record_keys);
}
#-------------------------------------------------------------------------------
# 

sub _transform_key_fields
{
    my ($deduper,%record_keys) = @_;

    if ( $deduper->{ignore_whitespace} )
    {
        foreach my $key_number ( keys %{$deduper->{ignore_whitespace}} )
        {
            # strip out leading and/or trailing whitespace
            $record_keys{$key_number} =~ s/^\s+//;
            $record_keys{$key_number} =~ s/\s+$//;
        }
    }

    if ( $deduper->{ignore_case} )
    {
        # Transform every field where ignore_case was specified

        foreach my $key_number ( keys %{$deduper->{ignore_case}} )
        {
            # If this key is case insensitive, fold data to upper case
            $record_keys{$key_number} = uc($record_keys{$key_number});
        }
    }
    return(%record_keys);
}
#-------------------------------------------------------------------------------
# 

sub _assemble_full_key
{
    my (%record_keys) = @_;
    my $full_key;
    foreach my $current_key ( sort keys %record_keys )
    {
        $full_key .= $record_keys{$current_key} . ':';
    }
    return($full_key);

}
#-------------------------------------------------------------------------------
# 

sub _alias_dupe
{
    my ($deduper,$alias_candidates_ref,%record_keys) = @_;


    my $alias_dupe = 0;
    if ( $deduper->{alias} )
    {
        my $alias_was_substituted = 0;

        foreach my $key_number ( keys %{$deduper->{alias}} )
        {
            my %current_alias =  %{ $deduper->{alias}{$key_number} };
            foreach my $current_alias_key ( keys  %current_alias )
            {
                if ( $record_keys{$key_number} eq $current_alias_key )
                {
                    $alias_was_substituted = 1;
                    $record_keys{$key_number} = $current_alias{$current_alias_key};
                    last;
                }
            }
        }
        if ( $alias_was_substituted )
        {
            my $full_key;
            foreach my $current_key ( sort keys %record_keys )
            {
                $full_key .= $record_keys{$current_key} . ':';
            }
            # print("full key: ",Dumper($full_key));
            if ( $alias_candidates_ref->{$full_key} )
            {
                $alias_dupe = 1;
            }
        }
    }
    return($alias_dupe);
}
#-------------------------------------------------------------------------------
# 

sub _exact_dupe
{
    my ($deduper,$full_key,%seen_exact_dupes) = @_;
    # problem with unitialized value, set to undef??
    if ( $seen_exact_dupes{$full_key} )
    {
        return(1);
    }
    else
    {
        return(0);
    }
}

#-------------------------------------------------------------------------------
# 

sub _read_one_record
{
    my ($storage_type,$record_number,$input_array_ref,$file_handles_ref) = @_;

    my $finished = 0;
    my $current_line;

    if ( $storage_type eq 'file' )
    {
        my $input_fh = $file_handles_ref->{input};
        if ( $current_line = $input_fh->getline )
        {
            chomp($current_line);
            if ( $input_fh->eof )
            {
                $finished = 1;
            }
        }
        else
        {
            warn "Could not read line from input file";
            $finished = 1;
        }
    }
    elsif ( $storage_type eq 'array' )
    {
        $current_line =  @$input_array_ref[$record_number];
        my $last_element =  @$input_array_ref - 1;
        if ( $record_number == $last_element )
        {
            $finished = 1;
        }
        elsif ( $record_number > $last_element )
        {
            warn "You are trying to access beyond the input array boundaries";
            $finished = 1;
        }
    }
    else
    {
        warn "Illegal storage type";
        $finished = 1;
    }
    return($current_line,$finished);
}

#-------------------------------------------------------------------------------
# 

sub _write_one_record
{
    my ($storage_type,$dupe_type,$current_line,$file_handles_ref,$unique_ref,$dupe_ref) = @_;

    if ( $storage_type eq 'file' )
    {
        if ( $dupe_type eq 'unique' )
        {
            $file_handles_ref->{output_unique}->print("$current_line\n");
        }
        elsif ( $dupe_type =~ /dupe/ )
        {
            # TO DO!!! separate out to alias, soundex dupes etc if needed
            $file_handles_ref->{output_dupe}->print("$current_line\n");
        }
    }
    elsif ( $storage_type eq 'array' )
    {
        if ( $dupe_type eq 'unique' )
        {
            push(@$unique_ref,$current_line);
        }
        elsif ( $dupe_type =~ /dupe/ )
        {
            # TO DO!!! separate out to alias, soundex dupes etc if needed
            push(@$dupe_ref,$current_line);
        }
    }
 

}
1;

